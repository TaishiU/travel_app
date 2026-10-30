---
name: task-intake
description: PMからタスク依頼を受けた時点でユーザー課題・KPI・仮説・成功指標を構造化して docs/adr/{feature_id}/intake_doc.md に記録する
argument-hint: "<feature_id>"
---

# task-intake

PMからタスク依頼を受けた時点で、ユーザー課題・ビジネス課題・KPI・PMの仮説・成功指標を構造化して記録するスキル。
`AI時代_リードエンジニア立ち回りテンプレート.md` のシーン1「背景確認・要件自己定義」を skill 化したもの。

**生成対象:**
- `docs/adr/{feature_id}/intake_doc.md` — タスク受領メモ（gen-design-doc への構造化入力）

---

## Step 0: 引数チェック

`$ARGUMENTS` から `feature_id` を取得する。

**引数が空の場合**: 処理を止め、ユーザーに以下を伝える。

```
feature_id が指定されていません。以下の形式で実行してください:

/task-intake <feature_id>

例: /task-intake braze_push_notification
```

---

## Step 1: AskUserQuestion（1回で7項目を確認）

AskUserQuestion で以下7項目を確認する（2回に分けて実行する）。

**1回目（4項目）:**

1. **ユーザー課題**: どんなユーザーが何に・なぜ困っているか
   （例: お気に入り登録したユーザーが再来訪せず予約を忘れる）
2. **ビジネス課題・KPI**: 改善したい指標と目標値
   （例: リピート予約率・CVRを改善したい / 再来訪率+10%が目標）
3. **PMの仮説**: なぜこの機能で課題を解決できると考えているか
   （例: パーソナライズ通知で再来訪・予約完了を促せる）
4. **成功指標**: 何が達成されたらビジネス的に成功か（外の証拠ベース）
   （例: リリース2週間後にGA4で再来訪率+10%確認 / 通知CTR 5%以上）

**2回目（3項目）:**

1. **スコープ外**: 今回含めないこと
   （例: 通知文面のA/Bテスト機能、バックエンド側のセグメント変更）
2. **制約・前提**: API状況・デザイン有無・期日・バックエンド対応状況
   （例: Braze実装済み・デザインカンプあり・次スプリント内に着手したい）
3. **なぜ今か**: 他機能より優先する根拠
   （例: 先週のGA4確認でお気に入り後7日以内の再来訪率が20%以下と判明）

---

## Step 2: intake_doc.md 生成

`docs/adr/{feature_id}/intake_doc.md` を以下の構成で生成する。

ディレクトリが存在しない場合は作成する。

```markdown
# {feature_id} タスク受領メモ

## 1. ユーザー課題
（→ gen-design-doc §1 ユーザー課題 に転記）

{Step 1 で確認した内容を記述}

## 2. ビジネス課題・KPI
（→ gen-design-doc §1 ビジネス課題・KPI に転記）

{Step 1 で確認した内容を記述}

## 3. PMの仮説
（→ gen-design-doc §2 ソリューション仮説 に転記）

{Step 1 で確認した内容を記述}

## 4. 成功指標
（→ gen-design-doc §4 ビジネス成功指標 に転記）

{Step 1 で確認した内容を記述}

## 5. スコープ外
（→ gen-design-doc §3 スコープ外 に転記）

{Step 1 で確認した内容を記述}

## 6. 制約・前提
（→ gen-design-doc §5 リスク に転記）

{Step 1 で確認した内容を記述}

## 7. なぜ今か
（→ gen-design-doc §1 なぜ今か に転記）

{Step 1 で確認した内容を記述}
```

---

## 完了時の案内

```
docs/adr/{feature_id}/intake_doc.md を生成しました。

次のステップ:
/gen-design-doc {feature_id}
  → intake_doc.md を参照して実行する
  → 生成された design_doc.md を PM に共有し合意を取る
  → PM合意後は /gen-impl-doc {feature_id} で実装計画一式を生成する
```
