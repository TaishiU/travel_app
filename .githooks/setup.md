## セットアップ（初回のみ）

1. ターミナルを起動する
2. 現在のパスがtravel_appディレクトリにいることを確認（pwdコマンド）
3. 下記コマンドを実行

```bash
git config core.hooksPath .githooks chmod +x .githooks/post-merge .githooks/pre-commit
```

```bash
.githooks/pre-push
```

ただし chmod +x は macOS/Linux のみ有効。Windows メンバーがいる場合は別途対応が必要。