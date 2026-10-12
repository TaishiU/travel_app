#!/bin/bash

REPO_ROOT="$(git rev-parse --show-toplevel)"
PUBSPEC_YAML_PATH="$REPO_ROOT/pubspec.yaml"
PYTHON_SCRIPT_PATH="$REPO_ROOT/scripts/sort_pubspec_dependencies.py"

echo "pubspec.yamlの依存関係をソートします: ${PUBSPEC_YAML_PATH}"

# Pythonスクリプトを実行
python3 "${PYTHON_SCRIPT_PATH}" "${PUBSPEC_YAML_PATH}"

# 終了コードを確認
if [ $? -ne 0 ]; then
  echo ""
  echo "--------------------------------------------------------"
  echo "エラーが発生しました。"
  echo "PyYAMLライブラリがインストールされているか確認してください。"
  echo "インストールされていない場合、以下のコマンドでインストールできます:"
  echo "  pip install PyYAML"
  echo "または"
  echo "  pip3 install PyYAML"
  echo "--------------------------------------------------------"
  exit 1
fi

echo "ソートが完了しました。"
exit 0
