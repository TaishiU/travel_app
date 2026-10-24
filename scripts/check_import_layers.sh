#!/bin/sh
# check_import_layers.sh
#
# Dartファイルのimportがアーキテクチャ層ルールに違反していないかチェックする。
#
# アーキテクチャ:
#   View → Notifier → UseCase（画面/ドメイン）→ Interface ← Repository → Service
#
# Usage:
#   # 全体実行
#   find lib -name "*.dart" | sh scripts/check_import_layers.sh
#
#   # ファイルを引数で渡す
#   ./check_import_layers.sh lib/presentation/login/screen.dart
#
#   # ファイルパスをstdinでパイプする（pre-push hookからの呼び出し想定）
#   git diff --name-only HEAD~1 -- '*.dart' | ./check_import_layers.sh

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RESET='\033[0m'

PACKAGE_NAME="travel_app"

VIOLATION_LOG=$(mktemp)
trap 'rm -f "$VIOLATION_LOG"' EXIT INT TERM

# ─────────────────────────────────────────────────────────────────────
# glob_to_regex <glob_pattern>
#   *  → [^/]*  (パスセグメント内のみマッチ)
#   ** → .*     (ネストされたディレクトリを含む任意のパスにマッチ)
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

log_violation() {
  printf '%s\t%s\t%s\n' "$1" "$2" "$3" >>"$VIOLATION_LOG"
}

# ─────────────────────────────────────────────────────────────────────
# check_impl_has_interface <impl_import_path>
#
# UseCase が *_repository_impl.dart をimportする場合、
# 対応する Interface が lib/domain/interfaces/ に存在するか確認する。
#
# 変換例:
#   lib/data/repositories/auth/auth_repository_impl.dart
#   → lib/domain/interfaces/auth/auth_repository.dart
#
# Interface が存在する = Provider が Interface 型を返すことで DIP が実現されている
# Interface が存在しない = DIP 未実現（違反）
# ─────────────────────────────────────────────────────────────────────
check_impl_has_interface() {
  local impl_path="$1"
  local interface_path
  interface_path=$(printf '%s' "$impl_path" |
    sed -e 's|lib/data/repositories/|lib/domain/interfaces/|' \
      -e 's|_impl\.dart$|.dart|')
  [ -f "$interface_path" ]
}

# ─────────────────────────────────────────────────────────────────────
# check_file <dart_file_path>
#
# レイヤールール一覧:
#   Rule 1  View          lib/presentation/** (notifier/state/use_case を除く)
#             NG: lib/data/**, lib/domain/use_cases/**, lib/domain/interfaces/**
#   Rule 2  Notifier      lib/presentation/**/notifier.dart
#             NG: lib/data/**
#   Rule 3  UseCase画面   lib/presentation/**/use_case.dart
#             NG: lib/data/services/**
#             CONDITIONAL: lib/data/repositories/**/*_impl.dart → Interface 存在確認
#   Rule 4  UseCase域     lib/domain/use_cases/**
#             NG: lib/presentation/**, lib/data/services/**
#             CONDITIONAL: lib/data/repositories/**/*_impl.dart → Interface 存在確認
#   Rule 5  Interface     lib/domain/interfaces/**
#             NG: lib/presentation/**, lib/data/**, lib/domain/use_cases/**
#   Rule 6  Entity        lib/domain/entities/**
#             NG: lib/presentation/**, lib/data/**, lib/domain/use_cases/**, lib/domain/interfaces/**
#   Rule 7  Repository    lib/data/repositories/**
#             NG: lib/presentation/**
#   Rule 8  Service       lib/data/services/**
#             NG: lib/presentation/**, lib/domain/use_cases/**, lib/domain/interfaces/**, lib/data/repositories/**
# ─────────────────────────────────────────────────────────────────────
check_file() {
  local file="$1"

  [ -f "$file" ] || return 0

  case "$file" in
  *.g.dart | *.freezed.dart | *.gen.dart | *.gr.dart | *.mocks.dart) return 0 ;;
  lib/presentation/debug/*) return 0 ;;
  esac

  local imports
  imports=$(grep -E "^ *import ['\"]package:${PACKAGE_NAME}/" "$file" 2>/dev/null || true)
  [ -z "$imports" ] && return 0

  printf '%s\n' "$imports" | while IFS= read -r import_line; do
    local import_path
    import_path=$(printf '%s' "$import_line" |
      sed -n "s|.*['\"]package:${PACKAGE_NAME}/\([^'\"]*\)['\"].*|lib/\1|p")
    [ -z "$import_path" ] && continue

    # ── Rule 1: View ──────────────────────────────────────────────────
    if path_matches "$file" "lib/presentation/**"; then
      case "$file" in
      */notifier.dart | */state.dart | */use_case.dart) ;;
      *)
        if path_matches "$import_path" "lib/data/**" ||
          path_matches "$import_path" "lib/domain/use_cases/**" ||
          path_matches "$import_path" "lib/domain/interfaces/**"; then
          log_violation "$file" "$import_line" \
            "View はデータ層・UseCase・Interface に依存不可"
        fi
        ;;
      esac
    fi

    # ── Rule 2: Notifier ──────────────────────────────────────────────
    if path_matches "$file" "lib/presentation/**/notifier.dart"; then
      if path_matches "$import_path" "lib/data/**"; then
        log_violation "$file" "$import_line" \
          "Notifier はデータ層に依存不可（UseCase 経由でアクセスすること）"
      fi
    fi

    # ── Rule 3: UseCase（画面）────────────────────────────────────────
    if path_matches "$file" "lib/presentation/**/use_case.dart"; then
      if path_matches "$import_path" "lib/data/services/**"; then
        log_violation "$file" "$import_line" \
          "UseCase（画面）は Service に直接依存不可"
      elif path_matches "$import_path" "lib/data/repositories/**"; then
        if path_matches "$import_path" "lib/data/repositories/**/*_impl.dart"; then
          if ! check_impl_has_interface "$import_path"; then
            log_violation "$file" "$import_line" \
              "UseCase が *_impl.dart をimportしているが、対応 Interface が lib/domain/interfaces/ に存在しない → DIP 未実現"
          fi
        else
          log_violation "$file" "$import_line" \
            "lib/data/repositories/ 配下の非 impl ファイルへの依存不可（Interface は lib/domain/interfaces/ に置くこと）"
        fi
      fi
    fi

    # ── Rule 4: UseCase（ドメイン）────────────────────────────────────
    if path_matches "$file" "lib/domain/use_cases/**"; then
      if path_matches "$import_path" "lib/presentation/**" ||
        path_matches "$import_path" "lib/data/services/**"; then
        log_violation "$file" "$import_line" \
          "UseCase（ドメイン）はプレゼンテーション層・Service に依存不可"
      elif path_matches "$import_path" "lib/data/repositories/**"; then
        if path_matches "$import_path" "lib/data/repositories/**/*_impl.dart"; then
          if ! check_impl_has_interface "$import_path"; then
            log_violation "$file" "$import_line" \
              "UseCase が *_impl.dart をimportしているが、対応 Interface が lib/domain/interfaces/ に存在しない → DIP 未実現"
          fi
        else
          log_violation "$file" "$import_line" \
            "lib/data/repositories/ 配下の非 impl ファイルへの依存不可（Interface は lib/domain/interfaces/ に置くこと）"
        fi
      fi
    fi

    # ── Rule 5: Interface ─────────────────────────────────────────────
    if path_matches "$file" "lib/domain/interfaces/**"; then
      if path_matches "$import_path" "lib/presentation/**" ||
        path_matches "$import_path" "lib/data/**" ||
        path_matches "$import_path" "lib/domain/use_cases/**"; then
        log_violation "$file" "$import_line" \
          "Interface はプレゼンテーション層・データ層・UseCase に依存不可"
      fi
    fi

    # ── Rule 6: Entity ────────────────────────────────────────────────
    if path_matches "$file" "lib/domain/entities/**"; then
      if path_matches "$import_path" "lib/presentation/**" ||
        path_matches "$import_path" "lib/data/**" ||
        path_matches "$import_path" "lib/domain/use_cases/**" ||
        path_matches "$import_path" "lib/domain/interfaces/**"; then
        log_violation "$file" "$import_line" \
          "Entity は他のいかなる層にも依存不可"
      fi
    fi

    # ── Rule 7: Repository ────────────────────────────────────────────
    if path_matches "$file" "lib/data/repositories/**"; then
      if path_matches "$import_path" "lib/presentation/**"; then
        log_violation "$file" "$import_line" \
          "Repository はプレゼンテーション層に依存不可"
      fi
    fi

    # ── Rule 8: Service ──────────────────────────────────────────────
    if path_matches "$file" "lib/data/services/**"; then
      if path_matches "$import_path" "lib/presentation/**" ||
        path_matches "$import_path" "lib/domain/use_cases/**" ||
        path_matches "$import_path" "lib/domain/interfaces/**" ||
        path_matches "$import_path" "lib/data/repositories/**"; then
        log_violation "$file" "$import_line" \
          "Service はプレゼンテーション層・UseCase・Interface・Repository に依存不可"
      fi
    fi
  done
}

# ─────────────────────────────────────────────────────────────────────
# 引数またはstdinからDartファイルリストを取得してチェック
# ─────────────────────────────────────────────────────────────────────
printf " 🔍 importチェック実行中...\n"

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
  printf "${GREEN} ✅ import違反なし${RESET}\n"
  exit 0
fi

violation_count=$(wc -l <"$VIOLATION_LOG" | tr -d ' ')
printf "\n${RED} ❌ import違反 %d件を検出${RESET}\n\n" "$violation_count"

while IFS='	' read -r vfile vimport vreason; do
  printf "${YELLOW}%s${RESET}\n" "$vfile"
  printf "  %s\n" "$vimport"
  printf "  → %s\n\n" "$vreason"
done <"$VIOLATION_LOG"

printf "${YELLOW}上記のimport違反を修正してから再実行してください。${RESET}\n\n"
exit 1
