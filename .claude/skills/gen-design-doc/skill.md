---
name: gen-design-doc
description: 新規機能開発のデザインドック・タスク分割ドキュメント一式を生成する
argument-hint: "<feature_id>"
---

# gen-design-doc

新機能開発の設計・計画ドキュメントを `docs/adr/{feature_id}/` 配下に生成するスキル。

**生成対象:**
- `design_doc.md` — マスターデザインドック（目的・設計方針・タスク分解・リスク等）
- `index.md` — ナビゲーション索引
- `{phase_dir}/overview.md` — フェーズ概要（実装可否・最小スコープ・残課題）
- `{phase_dir}/{FEATURE}_NNN.md` — タスクスケルトン（着手時に実装方針を書き込む）
- `kickoff_prompts.md` — タスク着手時コピペ用プロンプト集

---

## Step 0: 引数チェック・情報収集

### 引数パース

`$ARGUMENTS` から `feature_id` を取得する。

| 項目 | 説明 | 例 |
|---|---|---|
| `feature_id` | ディレクトリ名に使う snake_case 識別子 | `braze_push_notification` |
| タスクIDプレフィックス | feature_id の先頭セグメントを大文字化 | `BRAZE` |

**引数が空の場合**: 処理を止め、ユーザーに以下を伝える。

```
feature_id が指定されていません。以下の形式で実行してください:

/gen-design-doc <feature_id>

例: /gen-design-doc braze_push_notification
```

### 追加情報の収集

AskUserQuestion で以下3点を確認する（1回の呼び出しで3問まとめて聞く）:

1. **機能概要**: 何を実現する機能か。使用する外部SDK/APIがあれば併記
2. **現在の制約**: 既存実装の有無・前提条件（例: "認証は実装済み、予約ドメインは未実装"）
3. **外部ドキュメントURL**: 実装時に参照するURL（任意、複数可）

---

## Step 1: 既存コード読み込み（並列実行）

以下を並列で読み込む:

- `docs/architecture/architecture.md`
- `docs/architecture/libraries.md`
- `pubspec.yaml`
- `lib/main.dart`
- `lib/router/router.dart`（存在する場合）
- 機能概要から影響を受ける可能性が高いファイル（認証・Router・Notifier等）

読み込んだ内容をもとに「既存コードへの影響調査」セクションと「チケット別実装可否」の根拠を構成する。

---

## Step 2: design_doc.md 生成

`docs/adr/{feature_id}/design_doc.md` を生成する。

### タスクIDの採番ルール

- 先頭セグメント大文字 + アンダーバー + 3桁ゼロ埋め: `{FEATURE}_001`, `{FEATURE}_002`, ...
- Phase をまたいでも連番を継続する（Phase 1 が `001`〜`005` なら Phase 2 は `010` から開始して間隔を確保する）
- Phase間の間隔: 10番おき（Phase 1: 001〜009、Phase 2: 010〜019、Phase 3: 020〜029、...）

### 合格ライン・失格ラインの解像度ルール

**設計の核心: "形容詞でなく外の証拠で締める"**

完了条件・失格条件を記述する際は以下の基準を守る:

| NG（抽象的） | OK（外の証拠ベース） |
|---|---|
| Push権限が正しく取得できる | `flutter test` が全件グリーン、かつ実機でダイアログが表示される |
| SDK初期化が成功する | Brazeダッシュボードにテスト端末が表示されている |
| 遷移が正しく動作する | ADB `am start -d "travelapp://profile"` 実行後にProfileScreenが表示される |

- **完了条件** = 「このコマンドを実行し、この出力が確認できたら合格」という形式
- **失格条件** = 「こうなっていたら不合格（修正が必要）」という具体的な判定基準
- 抽象的な形容詞（"正しく"、"適切に"、"正常に"）は使わない

### フェーズ分割の基準

機能の複雑度・依存関係から自動でPhaseを決定する。一般的なパターン:

| パターン | フェーズ構成 |
|---|---|
| 外部SDK連携 | Phase 1: 調査・設計 / Phase 2: 基盤実装 / Phase 3: 機能実装 / Phase 4: 検証・リリース |
| UI機能追加 | Phase 1: 設計 / Phase 2: 実装 / Phase 3: テスト・リリース |
| データ基盤整備 | Phase 1: 設計 / Phase 2: スキーマ・モデル実装 / Phase 3: UI連携 / Phase 4: 検証 |

依存関係が少ないシンプルな機能は2〜3フェーズで十分。過度なフェーズ分割はしない。

### 構成テンプレート

```markdown
# {機能名} デザインドック

## 1. タスクの目的

### 目的
（機能が解決する課題・実現すること）

### スコープ
- （含む内容の箇条書き）

### スコープ外
- （含まない内容の箇条書き）

---

## 2. 設計・実装方針

### 基本方針
- （箇条書き）

### 責務分離
| 担当 | 責務 |
|---|---|
（Flutter / 外部サービス / バックエンド / 運用など）

---

## 3. {機能固有の設計}

（機能の性質に応じて構成を決定する）

**外部サービス連携の場合:** 「画面/タイミング別データ設計」テーブル
  | 画面 / 状態 | タイミング | 取得するデータ | 外部サービスへ送るデータ | 目的 |

**UI機能追加の場合:** 「画面遷移フロー」と「状態設計」

**バックグラウンド処理の場合:** 「処理フロー」とトリガー条件

---

## 4. タスク・チケット分解

### Phase 1: {フェーズ名}

| チケット | 内容 | 完了条件 | 失格条件 |
|---|---|---|---|
| `{FEATURE}_001` {タスク名} | ... | （外の証拠ベースで記述） | （こうなっていたら不合格） |

### Phase 2: {フェーズ名}

| チケット | 内容 | 完了条件 | 失格条件 |
|---|---|---|---|
| `{FEATURE}_010` {タスク名} | ... | ... | ... |

（以降、必要なフェーズ数だけ繰り返す）

---

## 8. 各フェーズの合格ライン

フェーズ全体の完了を判定するための合格基準。個別タスクの完了条件とは別に定義する。

| フェーズ | 合格の定義 | 検証方法 | 失格条件 |
|---|---|---|---|
| Phase 1: {フェーズ名} | （フェーズ全体として何が達成されていれば合格か） | （どのコマンド・手順で確認するか） | （こうなっていたら次フェーズに進んではいけない） |

---

## 5. 既存コードへの影響調査

| 調査対象 | 確認内容 | 影響 |
|---|---|---|
（Step 1 の読み込み結果から記述）

---

## 6. 代替案と採用理由

| 案 | 内容 | 採用 / 不採用 | 理由 |
|---|---|---|---|

---

## 7. リスクと注意点

### セキュリティ・プライバシー
- （箇条書き）

### ストア審査・外部サービス
- （箇条書き）

### 実装リスク
- （箇条書き）
```

---

## Step 2 完了後: Step 2.5〜5 を sub-agent に移譲

design_doc.md の生成が完了したら、**Agent ツール**でフレッシュな sub-agent を起動し、Step 2.5〜5 を移譲する。

### sub-agent に渡すプロンプト

以下のテンプレートを埋めて Agent ツールの `prompt` 引数に指定する（`subagent_type` は指定しない）:

```
以下の作業を実行する。

前提:
- feature_id: {feature_id}
- 設計ドック: docs/adr/{feature_id}/design_doc.md（必ず読み込むこと）
- スキル仕様: /Users/taishiutsunomiya/StudioProjects/travel_app/.claude/skills/gen-design-doc/skill.md（必ず読み込むこと）
{外部ドキュメントURLがある場合: - 外部ドキュメントURL: {urls}}

実行対象ステップ:
- Step 2.5: test_plan.md 生成
- Step 3: index.md + Phase 1 overview.md の生成（並列実行）
- Step 4: タスクスケルトンファイル生成（並列実行）
- Step 5: kickoff_prompts.md 生成

各ステップの詳細仕様はスキル仕様を参照すること。
完了後はスキル仕様の「完了時の出力」セクションに従いディレクトリツリーとネクストアクションをユーザーに伝えること。
```

### メインはここで終了

sub-agent 起動後、メイン session はユーザーに以下を伝えて終了する:

```
docs/adr/{feature_id}/design_doc.md を生成しました。

まず design_doc.md を確認・修正してください。
残りのファイル生成（test_plan.md / index.md / overview.md / タスクスケルトン / kickoff_prompts.md）はサブエージェントが実行します。
```

---

## Step 2.5: test_plan.md 生成

`docs/test/{feature_id}/test_plan.md` を生成する。

**位置づけ:** 機能レベルのテスト設計文書。スタブ境界・ファイル構成・ProviderContainer骨格は設計時点で確定できる。各レイヤーの3条件テーブルは各タスク着手時に埋める。

### test_plan.md テンプレート

````markdown
# {機能名} テスト方針

参照: [test_guideline.md](../../test/test_guideline.md)

---

## スタブ境界

末端I/O（プロセス外と通信する箇所）のみスタブに置き換え、それ以外は実物を使う。
参照: [test_guideline.md レイヤー別テスト設計](../../test/test_guideline.md#レイヤー別テスト設計)

（機能のアーキテクチャから導出してフロー図を記述する）

```
Notifier → UseCase → Repository → [ServiceImpl] → [StubServiceImpl]
                                                          ↑
                                                   ここでスタブ注入 → 1プロセスで完結（Small）
```

---

## 新規作成ファイル候補

| ファイル | 用途 |
|---|---|
（着手時に確定）

---

## テストファイル構成

エントリーポイントにミラーする配置原則に従う。
参照: [test_guideline.md Integration テストのファイル配置原則](../../test/test_guideline.md#integration-テストのファイル配置原則)

| ファイル | エントリーポイント | 種別 |
|---|---|---|
（機能の各レイヤーに対応するテストファイルを記述 — 着手時に順次確定）

---

## ProviderContainer 構成

```dart
ProviderContainer buildContainer() {
  return ProviderContainer(
    overrides: [
      // 末端I/Oスタブのみオーバーライド
      // Repository・UseCase・Notifier は本物を使う
      // （着手時に確定）
    ],
  );
}
```

---

## 3条件・テストケース設計

各タスク着手時に、該当レイヤーの3条件をここに追記する。
参照: [test_guideline.md テスト仕様の設計原則](../../test/test_guideline.md#テスト仕様の設計原則契約による設計)

> **AI駆動テスト実装フロー（各タスクで必ず守る）**
> Step 1: 3条件を設計する（ここに記述）
> Step 2: 3条件をもとにテストコードを実装する（Given-When-Then形式）
> Step 3: テストをパスするようにプロダクションコードを実装する

### {レイヤー名} （{FEATURE}_NNN にて追記）

| ケース | 事前条件 | 事後条件 |
|---|---|---|
| 正常系: ... | ... | ... |
| 異常系: ... | ... | ... |
````

---

## Step 3: index.md + Phase 1 overview.md の生成（並列実行）

### フェーズディレクトリ名の命名規則

`phase{N}_{english_name}` 形式（N: フェーズ番号、english_name: フェーズ名の英語 snake_case）

例:
- Phase 1 「調査・設計」→ `phase1_research_and_design`
- Phase 2 「基盤実装」→ `phase2_infrastructure_implementation`
- Phase 3 「機能実装」→ `phase3_feature_implementation`
- Phase 4 「検証・リリース」→ `phase4_qa_and_release`

### index.md テンプレート

`docs/adr/{feature_id}/index.md` に生成する。

```markdown
# {機能名} ADR Index

## 概要

| Topic | Path |
|---|---|
| デザインドック（タスク分割・全体設計） | `docs/adr/{feature_id}/design_doc.md` |
| タスク着手プロンプト集 | `docs/adr/{feature_id}/kickoff_prompts.md` |
| テスト方針（スタブ境界・3条件） | `docs/test/{feature_id}/test_plan.md` |

## Phase 1: {フェーズ名}

| Topic | Path |
|---|---|
| Phase 1 概要 | `docs/adr/{feature_id}/{phase1_dir}/overview.md` |
| {FEATURE}_001 {タスク名} | `docs/adr/{feature_id}/{phase1_dir}/{FEATURE}_001.md` |
| {FEATURE}_002 {タスク名} | `docs/adr/{feature_id}/{phase1_dir}/{FEATURE}_002.md` |

## Phase 2: {フェーズ名}

| Topic | Path |
|---|---|
| Phase 2 概要 | `docs/adr/{feature_id}/{phase2_dir}/overview.md` |
| {FEATURE}_010 {タスク名} | `docs/adr/{feature_id}/{phase2_dir}/{FEATURE}_010.md` |

（以降、フェーズ数だけ繰り返す）
```

### Phase 1 overview.md テンプレート

**Phase 1 のみここで生成する。** Phase 1 はdesign_doc.md生成直後に着手するため、スキルのPhase 1で読み込んだコード状態が「着手時点の現状」と一致する。

**Phase 2以降は生成しない。** 前フェーズ完了後のコード状態を反映させるため、各フェーズ開始時に生成する（kickoff_prompts.mdの「Phase N 開始」プロンプトを参照）。

`docs/adr/{feature_id}/{phase1_dir}/overview.md` に生成する。

```markdown
# Phase N: {フェーズ名} 概要

> 各タスクチケット（{FEATURE}_NNN〜{FEATURE}_NNN）の親ドキュメント。
> 実装に着手する前にこのドキュメントで方針・スコープ・未決定事項を確認すること。

---

## 前提：コードの現状

| 項目 | 状態 |
|---|---|
（Step 1 の読み込み結果から記述）

---

## チケット別実装可否

| チケット | 可否 | 理由 |
|---|---|---|
（✅ 完全実装可 / ⚠️ 一部のみ / ❌ 不可 で記載）

---

## 最小実装スコープ

**方針:** （このフェーズで「必ず完成させること」を1行で）

### 含める

| 実装内容 | 変更・新規ファイル |
|---|---|

### 除外（次フェーズ以降）

- （箇条書き）

---

## 残課題（設計決定が必要な点）

| # | 課題 | 選択肢 | 仮決定チケット |
|---|---|---|---|

---

## 参照資料

（外部ドキュメントURL・ローカルサンプルコードパス等）

---

## チケット一覧

| チケット | ADRファイル | 状態 |
|---|---|---|
| {FEATURE}_NNN {タスク名} | `{FEATURE}_NNN.md` | 🔲 未着手 |
```

---

## Step 4: タスクスケルトンファイル生成（並列実行）

各タスクを `docs/adr/{feature_id}/{phase_dir}/{FEATURE}_NNN.md` に生成する。

スケルトンには「完了条件・失格条件」のみ design_doc.md から転記し、残りは着手時に埋める構造にする。

```markdown
# {FEATURE}_NNN {タスク名}

## 完了条件

（design_doc.md のタスク分解から転記 — 外の証拠ベースで記述されていること）

## 失格条件

（design_doc.md のタスク分解から転記 — 「こうなっていたら不合格」という具体的な判定基準）

---

## 概要

（着手時に記述）

---

## フロー図

（着手時に記述）

---

## 設計決定

（着手時に記述）

---

## 変更ファイル一覧

（着手時に記述）

---

## 実装詳細

（着手時に記述）

---

## 検証手順

（着手時に記述 — 「このコマンドを実行し、この出力が出たら完成」という手順。`flutter test`・ADB・実機確認など外の証拠で締めること）

---

## テスト計画（3条件）

参照: `docs/test/{feature_id}/test_plan.md`

（着手時に記述 — このタスクに関係するレイヤーの3条件を設計し test_plan.md にも追記すること）

| レイヤー | テスト種別 | 対象メソッド | 事前条件 | 事後条件 |
|---|---|---|---|---|
| （例: Notifier） | Integration × Small | （例: login） | （例: StubApi が SuccessResult を返す） | （例: state が AsyncData に遷移） |

---

## スコープ外

（着手時に記述）
```

---

## Step 5: kickoff_prompts.md 生成

`docs/adr/{feature_id}/kickoff_prompts.md` に全タスクの着手プロンプトを保存する。

### プロンプト生成ルール

| 条件 | 書き方 |
|---|---|
| 最初のタスク | `「（初回着手）」から「{FEATURE}_001 {タスク名}」に着手する` |
| 2番目以降 | `「{FEATURE}_NNN {前タスク名}」まで完了したので「{FEATURE}_NNN {このタスク名}」に着手する` |
| フェーズ開始（Phase 2以降） | 各フェーズ最初のタスクの前に「Phase N 開始」プロンプトを挿入する（overview.md を生成してからタスクに着手させる） |
| フェーズ境界（タスク内） | a: の overview.md パスをそのフェーズのものに切り替える |
| 外部ドキュメントURL | ユーザーが Phase 0 で提供した場合のみ `d:` 行を追加 |

### 各プロンプトに必ず以下の指示を追加する

```
実装方針をcに書き出す際、以下を守ること:
- 失格ライン: 「〜になっていたら不合格」という具体的な判定基準で記述する
- 検証手順: 「このコマンドを実行し、この出力が確認できたら完成」という外の証拠で締める
- 抽象的な形容詞（"正しく"、"適切に"、"正常に"）は使わない

テスト実装はTDDで行うこと（eを参照）:
1. このタスクに関係するレイヤーの3条件（事前条件・事後条件）を設計し cとeの両方に記述する
2. テストコードを先に実装する（Given-When-Then形式・スタブ注入）
3. テストをパスするようにプロダクションコードを実装する

e: docs/test/{feature_id}/test_plan.md
```

### ファイルテンプレート

````markdown
# {機能名} タスク着手プロンプト集

## ワークフロー

```
Step 1: /gen-design-doc {feature_id}          → design_doc.md 生成
Step 2: design_doc.md を確認・修正
Step 3: /review-design-doc {feature_id}       → 採点役AIが検品
Step 4: review_design_doc_report.md の致命的な問題のみ修正
Step 5: ↓ このファイルから各タスクのプロンプトをコピーして実行 ↓
```

> 各プロンプトは **新しい session** で実行する。前後の文脈なくタスクに集中できる。

---

各タスク着手時に、該当するプロンプトをコピーして Claude Code に貼り付ける。

---

## {FEATURE}_001: {タスク名}

```
以下a, b, eを理解して。「（初回着手）」から「{FEATURE}_001 {タスク名}」に着手する。
aは全体像の概要、bはindexとして必要な情報がある時に参照して。
eはテスト方針（スタブ境界・ファイル構成・3条件テーブル）。
着手にあたり、まずは内容を理解し、実装方針をcに書き出して。

a: docs/adr/{feature_id}/{phase1_dir}/overview.md
b: docs/adr/{feature_id}/index.md
c: docs/adr/{feature_id}/{phase1_dir}/{FEATURE}_001.md
e: docs/test/{feature_id}/test_plan.md
```

---

## {FEATURE}_002: {タスク名}

```
以下a, b, eを理解して。「{FEATURE}_001 {前タスク名}」まで完了したので「{FEATURE}_002 {タスク名}」に着手する。
aは全体像の概要、bはindexとして必要な情報がある時に参照して。
eはテスト方針（スタブ境界・ファイル構成・3条件テーブル）。
着手にあたり、まずは内容を理解し、実装方針をcに書き出して。

a: docs/adr/{feature_id}/{phase1_dir}/overview.md
b: docs/adr/{feature_id}/index.md
c: docs/adr/{feature_id}/{phase1_dir}/{FEATURE}_002.md
e: docs/test/{feature_id}/test_plan.md
```

---

（Phase 1の残タスクも同様に繰り返す）

---

## Phase 2 開始（{FEATURE}_010 着手前に実行）

```
以下a, bを読み、出力先パス（下記「出力:」行）のフェーズ overview.md を新規生成して。
直前フェーズ完了後のコードの現状を実際にファイルを読んで調査し、
design_doc.md の当該フェーズのチケット一覧を元に各チケットの実装可否を判定すること。

出力構成:
- ## 前提：コードの現状（テーブル: 項目 | 状態）
- ## チケット別実装可否（✅完全実装可 / ⚠️一部のみ / ❌不可 + 理由）
- ## 最小実装スコープ（「含める」「除外（次フェーズ以降）」の2セクション）
- ## 残課題（設計決定が必要な点）
- ## 参照資料
- ## チケット一覧（状態: 🔲未着手）

a: docs/adr/{feature_id}/design_doc.md
b: docs/adr/{feature_id}/index.md
出力: docs/adr/{feature_id}/{phase2_dir}/overview.md
```

---

## {FEATURE}_010: {タスク名}

```
以下a, b, eを理解して。「Phase 2 開始」から「{FEATURE}_010 {タスク名}」に着手する。
aは全体像の概要、bはindexとして必要な情報がある時に参照して。
eはテスト方針（スタブ境界・ファイル構成・3条件テーブル）。
着手にあたり、まずは内容を理解し、実装方針をcに書き出して。

a: docs/adr/{feature_id}/{phase2_dir}/overview.md
b: docs/adr/{feature_id}/index.md
c: docs/adr/{feature_id}/{phase2_dir}/{FEATURE}_010.md
e: docs/test/{feature_id}/test_plan.md
```

---

（以降、Phase 3以降も同様に「Phase N 開始」プロンプトを先頭に挿入してから各タスクを繰り返す）
````

**外部ドキュメントURLがある場合**の追加行（各プロンプトの末尾に追記）:

```
必要に応じてdを参考にして。

d: {external_url}
e: docs/test/{feature_id}/test_plan.md
```

---

## 完了時の出力

生成完了後、以下をユーザーに伝える:

```
生成完了。

docs/adr/{feature_id}/
├── design_doc.md         ← まずここを確認・修正する
├── index.md
├── kickoff_prompts.md    ← タスク着手時はここからコピー
├── {phase1_dir}/
│   ├── overview.md
│   ├── {FEATURE}_001.md
│   └── {FEATURE}_002.md
└── {phase2_dir}/
    └── {FEATURE}_010.md  ← overview.md はフェーズ開始時に生成（kickoff_prompts.md参照）

━━━ 次にすべきアクション ━━━

【Step 1: ✅ 完了】/gen-design-doc {feature_id}
  → docs/adr/{feature_id}/design_doc.md を生成

【Step 2: 今すぐ】design_doc.md を確認・修正する
  → スコープ・タスク分解・リスクに問題がないか確認
  → 完了条件が「外の証拠ベース」になっているか確認

【Step 3: 次に実行】/review-design-doc {feature_id}
  → 採点役AIが合格ライン・失格ラインの解像度を検品

【Step 4: Step 3 後】review_design_doc_report.md の致命的な問題のみ修正
  → 全指摘を修正する必要はない。棄却の判断も検品の一部

【Step 5: 実装着手】docs/adr/{feature_id}/kickoff_prompts.md を開く
  → 最初のタスクのプロンプトをコピーして Claude Code に貼り付ける
```
