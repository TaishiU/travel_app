#!/bin/sh

# --ci フラグ解析（pre-push から委譲される場合に指定）
CI_MODE=0
for arg in "$@"; do
  case "$arg" in
    --ci) CI_MODE=1 ;;
  esac
done

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
if [ -z "$REPO_ROOT" ]; then
  echo "エラー: gitリポジトリ内から実行してください。"
  exit 1
fi
cd "$REPO_ROOT"

# CI モードではスキップ（pre-commit が担保）
if [ "$CI_MODE" -eq 0 ]; then
  dart fix --apply .
  dart format .
fi

ANALYZE_OUTPUT=$(dart analyze 2>&1)
ISSUE_LINES=$(printf '%s\n' "$ANALYZE_OUTPUT" | grep -E '^\s*(error|warning|info)\s+-' || true)
ISSUE_COUNT=$(printf '%s\n' "$ISSUE_LINES" | grep -cE '^\s*(error|warning|info)\s+-' || true)

if [ "$ISSUE_COUNT" -gt 0 ]; then
  printf "${RED} ❌ dart analyze %d件の問題を検出${RESET}\n\n" "$ISSUE_COUNT"
  printf '%s\n' "$ISSUE_LINES" | while IFS= read -r line; do
    printf "${YELLOW}%s${RESET}\n" "$line"
  done
  exit 1
fi
printf "${GREEN} ✅ dart analyze 問題なし${RESET}\n"

echo "🔍 flutter analyze 実行中..."
FLUTTER_ANALYZE_OUTPUT=$(flutter analyze 2>&1)
FLUTTER_ISSUE_LINES=$(printf '%s\n' "$FLUTTER_ANALYZE_OUTPUT" | grep -E '^\s*(error|warning|info)\s+-' || true)
FLUTTER_ISSUE_COUNT=$(printf '%s\n' "$FLUTTER_ISSUE_LINES" | grep -cE '^\s*(error|warning|info)\s+-' || true)

if [ "$FLUTTER_ISSUE_COUNT" -gt 0 ]; then
  printf "${RED} ❌ flutter analyze %d件の問題を検出${RESET}\n\n" "$FLUTTER_ISSUE_COUNT"
  printf '%s\n' "$FLUTTER_ISSUE_LINES" | while IFS= read -r line; do
    printf "${YELLOW}%s${RESET}\n" "$line"
  done
  exit 1
fi
printf "${GREEN} ✅ flutter analyze 問題なし${RESET}\n"

if ! command -v lcov >/dev/null 2>&1 || ! command -v genhtml >/dev/null 2>&1; then
  printf "${YELLOW} ⚠️  lcov / genhtml が見つかりません。以下のコマンドでインストールしてください:${RESET}\n"
  printf "    brew install lcov\n\n"
  exit 1
fi

TEST_LOG=$(mktemp)
TEST_JSON=$(mktemp)
flutter test --coverage --file-reporter "json:$TEST_JSON" 2>&1 | tee "$TEST_LOG"
TEST_OUTPUT=$(cat "$TEST_LOG")
rm -f "$TEST_LOG"

lcov --extract coverage/lcov.info 'lib/presentation/**/notifier.dart' \
  --extract coverage/lcov.info 'lib/presentation/**/use_case.dart' \
  --extract coverage/lcov.info 'lib/domain/**/*_use_case.dart' \
  --extract coverage/lcov.info 'lib/data/**/*_repository_impl.dart' \
  --extract coverage/lcov.info 'lib/data/**/*_service_impl.dart' \
  --extract coverage/lcov.info 'lib/data/**/api_client.dart' \
  -o coverage/lcov_extract.info
lcov --remove coverage/lcov_extract.info 'lib/**/*.g.dart' \
  --remove coverage/lcov_extract.info 'lib/**/*.freezed.dart' \
  --remove coverage/lcov_extract.info 'lib/**/stub_*.dart' \
  -o coverage/lcov_extract.info
genhtml coverage/lcov_extract.info -o coverage/html

COVERAGE=$(grep -oE "headerCovTableEntry(Lo|Med|Hi)\">[0-9.]+&nbsp;%" coverage/html/index.html | head -n 1 | sed -E 's/.*\">([0-9.]+).*/\1%/')
FAIL_COUNT=$(printf '%s\n' "$TEST_OUTPUT" | grep -oE ' -[0-9]+:' | tail -1 | grep -oE '[0-9]+' || echo "0")

if [ "${FAIL_COUNT:-0}" -gt 0 ]; then
  printf "${RED} 📊 [テスト完了] 失敗: ${FAIL_COUNT}件 | カバレッジ: $COVERAGE${RESET}\n"
else
  printf "${GREEN} 📊 [テスト完了] カバレッジ: $COVERAGE${RESET}\n"
fi

if [ "${FAIL_COUNT:-0}" -gt 0 ] && [ -s "$TEST_JSON" ]; then
  printf "${RED}\n 失敗したテスト:${RESET}\n"
  python3 - "$TEST_JSON" <<'PYEOF'
import json, sys, os

with open(sys.argv[1]) as f:
    lines = [json.loads(l) for l in f if l.strip()]

suites = {}
tests = {}
for e in lines:
    t = e.get("type")
    if t == "suite":
        s = e["suite"]
        suites[s["id"]] = s.get("path", "")
    elif t == "testStart":
        test = e["test"]
        tests[test["id"]] = {"name": test["name"], "suiteID": test.get("suiteID")}
    elif t == "testDone" and e.get("result") in ("failure", "error") and not e.get("hidden", False):
        test = tests.get(e["testID"], {})
        name = test.get("name", "?")
        if name.startswith("loading ") or "(setUp" in name:
            continue
        suite_id = test.get("suiteID")
        abs_path = suites.get(suite_id, "") if suite_id is not None else ""
        try:
            rel = os.path.relpath(abs_path) if abs_path else ""
        except ValueError:
            rel = abs_path
        print(f"   {rel}: {name}" if rel else f"   {name}")
PYEOF
fi
rm -f "$TEST_JSON"

UNCOVERED=$(awk -F: '
  /^SF:/{file=$2}
  /^LF:/{lf=$2}
  /^LH:/{lh=$2}
  /^end_of_record/{
    if(lf>0 && lh<lf){
      pct = lh/lf*100
      printf "   %s: %.1f%%\n", file, pct
    }
    file=""; lf=0; lh=0
  }
' coverage/lcov_extract.info)

if [ -n "$UNCOVERED" ]; then
  printf "${YELLOW}\n カバレッジ100%%未達:${RESET}\n"
  printf "${YELLOW}%s${RESET}\n" "$UNCOVERED"
fi

if [ "$CI_MODE" -eq 1 ]; then
  if [ "${FAIL_COUNT:-0}" -gt 0 ] || [ -n "$UNCOVERED" ]; then
    printf "\n💡 詳細は sh scripts/fix-and-test.sh を実行してブラウザで確認できます。\n"
    exit 1
  fi
  printf "${GREEN} ✅ カバレッジ 100%%${RESET}\n"
  echo "🚀 pushを続行します。"
  exit 0
fi

# ブラウザで開く
open coverage/html/index.html
