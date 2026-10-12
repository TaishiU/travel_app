# CI 改善履歴

CI実行速度改善・品質向上の変更履歴。
今後の改善検討時や、設定を元に戻す必要が生じた際の参照用。

---

## [v1] オリジナル構成

> 記録日: 2026-10-02  
> ファイル: `.github/workflows/main.yml`  
> 実行時間: 約 2分20秒（コード規模が小さい段階での計測値）

### main.yml（オリジナル）

```yaml
name: Flutter CI

on: [ push ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: コードのチェックアウト
        uses: actions/checkout@v6

      - name: Flutterのセットアップ
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version-file: pubspec.yaml
          cache: true

      - name: Flutterバージョン確認
        run: flutter --version

      - name: Flutter SDKのパスを環境変数に追加
        run: echo "$HOME/flutter/bin" >> $GITHUB_PATH

      - name: Pubキャッシュの復元
        uses: actions/cache@v5
        with:
          path: ${{ env.PUB_CACHE }}
          key: ${{ runner.os }}-pub-${{ hashFiles('**/pubspec.lock') }}
          restore-keys: |
            ${{ runner.os }}-pub-

      - name: Flutterクリーン
        run: flutter clean

      - name: Dart/Flutterの依存関係を取得
        run: flutter pub get

      - name: widgetbookのDart/Flutterの依存関係を取得
        run: |
          cd widgetbook
          flutter pub get

      - name: Dartコードの修正
        run: dart fix --apply .

      - name: Dartコードのフォーマット
        run: dart format .

      - name: Dartコードの解析
        run: dart analyze

      - name: widgetbookのDartコードの解析
        run: |
          cd widgetbook
          dart analyze

      - name: Flutterコードの解析
        run: flutter analyze

      - name: テストの実行とカバレッジレポートの生成
        run: flutter test --coverage

      - name: Slack通知
        if: ${{ always() }}
        uses: slackapi/slack-github-action@v3.0.0
        with:
          webhook: ${{ secrets.SLACK_WEBHOOK_URL }}
          webhook-type: incoming-webhook
          payload: |
            text: "*GitHub Action build result*: ${{ job.status }}\n${{ github.event.pull_request.html_url || github.event.head_commit.url }}"
            blocks:
              - type: "section"
                text:
                  type: "mrkdwn"
                  text: "GitHub Action build result: ${{ job.status }}\n${{ github.event.pull_request.html_url || github.event.head_commit.url }}"
```

### 課題

| # | ステップ | 問題 |
|---|---|---|
| 1 | `flutter clean` | CIは毎回クリーンなワークスペースで起動するため完全に無駄。かつPubキャッシュ効果を損なう |
| 2 | `Flutterバージョン確認` | デバッグ用の情報出力でCIゲートに不要 |
| 3 | `Flutter SDKのパスを環境変数に追加` | `subosito/flutter-action`が内部で処理済みの重複 |
| 4 | `dart fix --apply .` | `--apply`はファイルを書き換えるだけでCIが失敗しない。ゲートとして機能していない。また`.githooks/pre-commit`で適用済み |
| 5 | `dart format .` | 同上。未フォーマット時にCIが失敗しない |
| 6 | `dart analyze` | `flutter analyze`がdart analyzeを内包しており完全な重複 |
| 7 | `flutter test --coverage` | `--coverage`はカバレッジ生成のためのオーバーヘッドだが、CI上でlcovによるレポート生成・アップロードを行っていないため無駄なオプション |
| 8 | 直列実行 | `flutter analyze`と`flutter test`は独立しているが直列実行。コード規模拡大で線形に遅くなる |
| 9 | concurrencyなし | 同一ブランチへの連続pushで古いrunがキャンセルされず無駄に実行される |
| 10 | paths-ignoreなし | docs変更などCI不要な変更でもrunが発火する |

---

## [v2] 改善構成

> 記録日: 2026-10-02  
> 背景: `.githooks`（pre-commit / pre-push）との役割分担整理、並列化によるスケーラビリティ確保

### ローカルhooksとCIの役割分担

改善にあたり、ローカル環境（`.githooks`）とCIの責務を以下のように整理した。

| チェック | pre-commit | pre-push | CI |
|---|---|---|---|
| `dart fix` | ✅ apply | — | 削除（pre-commitで保証済み） |
| `dart format` | ✅ apply | — | ✅ check-only（安全弁） |
| `dart analyze` | ✅ | — | 削除（flutter analyzeと重複） |
| `flutter analyze` | ✅ | — | ✅（環境差異の検出） |
| `flutter test` | — | ✅ | ✅（環境差異の検出） |
| カバレッジ100%確認 | — | ✅ | — |

**CIでflutter testを削除しない理由**  
ローカルでテストがパスしていても、開発者間の環境差異（SDKバージョン・依存関係の解釈差など）によりCI環境で失敗するケースがある。ローカルOK = リモートOKという構造は成り立たないため、CIでのテスト実行は維持する。

### 各ステップの判定まとめ

| ステップ | 判定 | 理由 |
|---|---|---|
| `flutter clean` | **削除** | CIは毎回クリーンなワークスペース。Pubキャッシュも正常に機能するようになる |
| `Flutterバージョン確認` | **削除** | CIゲートに不要 |
| `Flutter SDKパスを環境変数に追加` | **削除** | flutter-actionが処理済み |
| `dart fix --apply` | **削除** | ゲートにならない。flutter analyzeが残存問題を検出する |
| `dart format .` | **変更** | `--output=none --set-exit-if-changed`でcheck-onlyに変更 |
| `dart analyze` | **削除** | flutter analyzeに内包されている |
| `flutter analyze` | **維持** | 環境依存の問題をCIで保証 |
| widgetbook `dart analyze` | **維持** | 別パッケージとして独立した解析が必要 |
| `flutter test --coverage` | **変更** | `--coverage`を除去。CI上でlcovを使用しないため |
| Pubキャッシュ | **維持** | flutter cleanを削除することで効果が正常に発揮される |
| Flutter SDKキャッシュ | **維持** | flutter-actionの`cache: true`で対応済み |

### 並列化・キャッシュ戦略

**並列化（コード規模拡大時に最大の効果）**

`flutter analyze`（静的解析）と`flutter test`（テスト実行）は独立しているため並列ジョブに分割する。

```
改善前（直列）: [analyze] → [test]         合計 = analyze時間 + test時間
改善後（並列）: [analyze]                   合計 = max(analyze時間, test時間)
               [test    ]
```

テストケースが増えるほど並列化の恩恵が大きくなる。

**キャッシュ**

- Flutter SDKキャッシュ: `subosito/flutter-action`の`cache: true`（変更なし）
- Pubパッケージキャッシュ: `actions/cache@v5` + `pubspec.lock`ハッシュキー（変更なし）
- `flutter clean`削除により`.dart_tool/`が保持され、Pubキャッシュが本来の効果を発揮

### main.yml（改善後）

```yaml
name: Flutter CI

on:
  push:
    paths:
      - 'lib/**'
      - 'test/**'
      - 'widgetbook/**'
      - 'pubspec.yaml'
      - 'pubspec.lock'
      - 'analysis_options.yaml'
      - '.github/workflows/**'

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - name: コードのチェックアウト
        uses: actions/checkout@v5

      - name: Flutterのセットアップ
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version-file: pubspec.yaml
          cache: true

      - name: Pubキャッシュの復元
        uses: actions/cache@v5
        with:
          path: ${{ env.PUB_CACHE }}
          key: ${{ runner.os }}-pub-${{ hashFiles('**/pubspec.lock') }}
          restore-keys: |
            ${{ runner.os }}-pub-

      - name: 依存関係を取得
        run: flutter pub get

      - name: widgetbookの依存関係を取得
        run: cd widgetbook && flutter pub get

      - name: フォーマット確認
        run: dart format --output=none --set-exit-if-changed .

      - name: Flutter静的解析
        run: flutter analyze

      - name: widgetbook静的解析
        run: cd widgetbook && dart analyze

  test:
    runs-on: ubuntu-latest
    steps:
      - name: コードのチェックアウト
        uses: actions/checkout@v5

      - name: Flutterのセットアップ
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version-file: pubspec.yaml
          cache: true

      - name: Pubキャッシュの復元
        uses: actions/cache@v5
        with:
          path: ${{ env.PUB_CACHE }}
          key: ${{ runner.os }}-pub-${{ hashFiles('**/pubspec.lock') }}
          restore-keys: |
            ${{ runner.os }}-pub-

      - name: 依存関係を取得
        run: flutter pub get

      - name: テスト実行
        run: flutter test

  notify:
    runs-on: ubuntu-latest
    needs: [analyze, test]
    if: always()
    steps:
      - name: Slack通知
        uses: slackapi/slack-github-action@v3.0.0
        with:
          webhook: ${{ secrets.SLACK_WEBHOOK_URL }}
          webhook-type: incoming-webhook
          payload: |
            text: "*GitHub Action build result*: analyze=${{ needs.analyze.result }} / test=${{ needs.test.result }}\n${{ github.event.pull_request.html_url || github.event.head_commit.url }}"
            blocks:
              - type: "section"
                text:
                  type: "mrkdwn"
                  text: "GitHub Action build result: analyze=${{ needs.analyze.result }} / test=${{ needs.test.result }}\n${{ github.event.pull_request.html_url || github.event.head_commit.url }}"
```

### 変更サマリー

| 変更 | 期待効果 |
|---|---|
| 不要ステップ5件削除（flutter clean・バージョン確認・パス追加・dart fix・dart analyze） | セットアップ短縮 / Pubキャッシュ正常化 |
| `dart format` check-only化 | 未フォーマット時に正しくCIが失敗するようになる |
| `concurrency`追加 | 連続pushで古いrunを自動キャンセル |
| `paths-ignore` → `paths`（許可リスト）に変更 | 非Dartファイルが増えても追加不要。CIが必要なパスだけを明示し、それ以外は一切発火しない |
| analyze / test 並列化 | コード規模拡大時に最大の効果（合計時間 = 遅い方の時間） |
| Slack通知を`notify`ジョブに分離 | 両ジョブの結果を集約して通知 |
| `actions/checkout@v4` → `@v5` | Node.js 24対応。v4はNode.js 20使用でdeprecation警告が発生するため |

**`paths-ignore` vs `paths` の考え方**

`paths-ignore`（除外リスト）は「不要なパスを列挙して除外」する方式。docs・mdを追加しても他の非Dartファイル（画像・設定ファイル等）が増えるたびに追記が必要になり、漏れが生じやすい。

`paths`（許可リスト）は「CIが必要なパスだけを列挙」する方式。列挙したパス以外の変更ではCIが発火しないため、将来ファイルが増えても自動的に対象外となり保守コストが低い。

```
# CIが発火するパス（許可リスト）
lib/**                   # Dartソースコード
test/**                  # テストコード
widgetbook/**            # Widgetbook
pubspec.yaml             # 依存関係定義
pubspec.lock             # 依存関係ロック
analysis_options.yaml    # Lint設定（変更でanalyze結果が変わるため）
.github/workflows/**     # CI設定自体の変更
```

ローカルの`.githooks`（pre-commit / pre-push）も同様の思想で、`*.dart`や`pubspec`の変更がない場合は全処理をスキップする実装を追加済み。

---

## 今後の改善候補

コードが大規模になった段階で検討する。

| 候補 | 概要 |
|---|---|
| 差分テスト | PRの変更パッケージに対応するテストのみ実行。Approve後に全テストを実行する設計に分離 |
| ネイティブビルドの条件実行 | Dart/Flutterコードのみの変更時はビルドをスキップし、ネイティブコード変更時のみ実行 |
| Codecov連携 | CI上でカバレッジレポートをアップロードし、PRごとにカバレッジ変化を可視化 |
