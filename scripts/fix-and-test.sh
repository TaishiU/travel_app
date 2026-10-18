#!/bin/sh

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

dart fix --apply .
dart format .

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

# ユニットテストを実行する
TEST_LOG=$(mktemp)
flutter test --coverage 2>&1 | tee "$TEST_LOG"
TEST_OUTPUT=$(cat "$TEST_LOG")
rm -f "$TEST_LOG"

# カバレッジをhtml化する
lcov --extract coverage/lcov.info 'lib/presentation/**/notifier.dart' \
  --extract coverage/lcov.info 'lib/presentation/**/use_case.dart' \
  --extract coverage/lcov.info 'lib/domain/**/*_use_case.dart' \
  --extract coverage/lcov.info 'lib/data/**/*_repository_impl.dart' \
  --extract coverage/lcov.info 'lib/data/**/*_service_impl.dart' \
  --extract coverage/lcov.info 'lib/data/**/api_client.dart' \
  -o coverage/lcov_extract.info
# 自動生成ファイル・スタブを対象から除外
lcov --remove coverage/lcov_extract.info 'lib/**/*.g.dart' \
  --remove coverage/lcov_extract.info 'lib/**/*.freezed.dart' \
  --remove coverage/lcov_extract.info 'lib/**/stub_*.dart' \
  -o coverage/lcov_extract.info
# HTML生成
genhtml coverage/lcov_extract.info -o coverage/html
# カバレッジ率を抽出して表示
COVERAGE=$(grep -oE "headerCovTableEntry(Lo|Med|Hi)\">[0-9.]+&nbsp;%" coverage/html/index.html | head -n 1 | sed -E 's/.*\">([0-9.]+).*/\1%/')
FAIL_COUNT=$(printf '%s\n' "$TEST_OUTPUT" | grep -oE ' -[0-9]+:' | tail -1 | grep -oE '[0-9]+' || echo "0")

if [ "${FAIL_COUNT:-0}" -gt 0 ]; then
  printf "${RED} 📊 [テスト完了] 失敗: ${FAIL_COUNT}件 | カバレッジ: $COVERAGE${RESET}\n"
else
  printf "${GREEN} 📊 [テスト完了] カバレッジ: $COVERAGE${RESET}\n"
fi
# ブラウザで開く
open coverage/html/index.html
