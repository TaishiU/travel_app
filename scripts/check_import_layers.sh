#!/bin/sh
# check_import_layers.sh
#
# Dartファイルのimportがアーキテクチャ層ルールに違反していないかチェックする。
# analysis_options.yaml の import_rules をシェルで再現したもの。
#
# Usage:
#   # ファイルを引数で渡す
#   ./check_import_layers.sh lib/ui/home/view/home_screen.dart
#
#   # ファイルパスをstdinでパイプする（pre-push hookからの呼び出し想定）
#   git diff --name-only HEAD~1 -- '*.dart' | ./check_import_layers.sh

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RESET='\033[0m'

PACKAGE_NAME="travel_app"

# 違反ログ用テンポラリファイル（サブシェル越しに書き込むため）
VIOLATION_LOG=$(mktemp)
trap 'rm -f "$VIOLATION_LOG"' EXIT INT TERM

# ─────────────────────────────────────────────────────────────────────
# glob_to_regex <glob_pattern>
#   * → [^/]*  (パスセグメント内のみマッチ)
#   ** → .*    (ネストされたディレクトリを含む任意のパスにマッチ)
# ─────────────────────────────────────────────────────────────────────
glob_to_regex() {
  printf '%s' "$1" |
    sed \
      -e 's/\./\\./g' \
      -e 's|\*\*|__DSTAR__|g' \
      -e 's|\*|[^/]*|g' \
      -e 's|__DSTAR__|.*|g'
}

# path_matches <path> <glob_pattern>
#   $1 が $2 のパターンにマッチすれば 0 を返す
path_matches() {
  printf '%s' "$1" | grep -qE "^$(glob_to_regex "$2")"
}

# ─────────────────────────────────────────────────────────────────────
# check_file <dart_file_path>
#   1ファイルを全ルールに対してチェックし、違反があれば VIOLATION_LOG に記録する
# ─────────────────────────────────────────────────────────────────────
check_file() {
  local file="$1"

  # ファイルが存在しない場合はスキップ（削除されたファイル等）
  [ -f "$file" ] || return 0

  # コード生成ファイルはスキップ
  case "$file" in
  *.g.dart | *.freezed.dart | *.gen.dart | *.gr.dart | *.mocks.dart) return 0 ;;
  esac

  # package:PACKAGE_NAME/ を使ったimport行のみ抽出
  local imports
  imports=$(grep -E "^ *import ['\"]package:${PACKAGE_NAME}/" "$file" 2>/dev/null || true)
  [ -z "$imports" ] && return 0

  printf '%s\n' "$imports" | while IFS= read -r import_line; do
    # import先のパスを lib/ 形式に変換
    # 例) import 'package:travel_app/data/repositories/...'
    #   → lib/data/repositories/...
    local import_path
    import_path=$(printf '%s' "$import_line" |
      sed -n "s|.*['\"]package:${PACKAGE_NAME}/\([^'\"]*\)['\"].*|lib/\1|p")
    [ -z "$import_path" ] && continue

    # ── Rule 1 ────────────────────────────────────────────────────
    # target : lib/ui/*/view/**
    # disallow: lib/data/api/**, lib/data/repositories/**
    if path_matches "$file" "lib/ui/*/view/**"; then
      if path_matches "$import_path" "lib/data/api/**" ||
        path_matches "$import_path" "lib/data/repositories/**"; then
        printf '%s\t%s\t%s\n' \
          "$file" \
          "$import_line" \
          "UI層（View）はRepository/Service層に依存不可。ViewModel層のみ依存可。" \
          >>"$VIOLATION_LOG"
      fi
    fi

    # ── Rule 2 ────────────────────────────────────────────────────
    # target : lib/ui/*/view_model/**
    # disallow: lib/ui/*/view/**, lib/data/api/**
    if path_matches "$file" "lib/ui/*/view_model/**"; then
      if path_matches "$import_path" "lib/ui/*/view/**" ||
        path_matches "$import_path" "lib/data/api/**"; then
        printf '%s\t%s\t%s\n' \
          "$file" \
          "$import_line" \
          "UI層（ViewModel）はView層/Service層に依存不可。Repository層のみ依存可。" \
          >>"$VIOLATION_LOG"
      fi
    fi

    # ── Rule 3 ────────────────────────────────────────────────────
    # target : lib/data/repositories/**
    # disallow: lib/ui/*/view/**, lib/ui/*/view_model/**
    if path_matches "$file" "lib/data/repositories/**"; then
      if path_matches "$import_path" "lib/ui/*/view/**" ||
        path_matches "$import_path" "lib/ui/*/view_model/**"; then
        printf '%s\t%s\t%s\n' \
          "$file" \
          "$import_line" \
          "Repository層はUI層（View/ViewModel）に依存不可。Service層のみ依存可。" \
          >>"$VIOLATION_LOG"
      fi
    fi

    # ── Rule 4 ────────────────────────────────────────────────────
    # target : lib/data/api/**
    # disallow: lib/ui/*/view/**, lib/ui/*/view_model/**, lib/data/repositories/**
    if path_matches "$file" "lib/data/api/**"; then
      if path_matches "$import_path" "lib/ui/*/view/**" ||
        path_matches "$import_path" "lib/ui/*/view_model/**" ||
        path_matches "$import_path" "lib/data/repositories/**"; then
        printf '%s\t%s\t%s\n' \
          "$file" \
          "$import_line" \
          "Service（API）層はUI層/Repository層に依存不可。" \
          >>"$VIOLATION_LOG"
      fi
    fi
  done
}

# ─────────────────────────────────────────────────────────────────────
# 引数またはstdinからDartファイルリストを取得してチェック
# ─────────────────────────────────────────────────────────────────────
if [ "$#" -gt 0 ]; then
  for file in "$@"; do
    check_file "$file"
  done
else
  while IFS= read -r file; do
    [ -n "$file" ] && check_file "$file"
  done
fi

# ─────────────────────────────────────────────────────────────────────
# 結果出力
# ─────────────────────────────────────────────────────────────────────
if [ ! -s "$VIOLATION_LOG" ]; then
  printf "${GREEN} ✅ import層違反なし${RESET}\n"
  exit 0
fi

violation_count=$(wc -l <"$VIOLATION_LOG" | tr -d ' ')
printf "\n${RED} ❌ import層違反 %d件を検出${RESET}\n\n" "$violation_count"

while IFS='	' read -r vfile vimport vreason; do
  printf "${YELLOW}%s${RESET}\n" "$vfile"
  printf "  %s\n" "$vimport"
  printf "  → %s\n\n" "$vreason"
done <"$VIOLATION_LOG"

printf "${YELLOW}上記のimport違反を修正してから再実行してください。${RESET}\n\n"
exit 1
