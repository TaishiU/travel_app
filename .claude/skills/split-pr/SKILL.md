---
name: split-pr
description: 実装済みブランチを infra層（PR-infra）と domain層（PR-domain）に分割し、2本のPRを作成する
argument-hint: "<domain> [--pattern=A|B|C|D]"
---

# split-pr

実装済みブランチ（全レイヤー）を受け取り、以下の2本のPRに分割する。

| PR | 対象レイヤー | レビュー主体 |
|---|---|---|
| PR-infra | Service / Repository / Entity / Interface | 🤖 review-skill（自動） |
| PR-domain | UseCase / Notifier / State / View | 👤 人間 |

---

## 引数パース

`$ARGUMENTS` から以下を抽出する:

| 呼び出し例 | domain | pattern |
|---|---|---|
| `/split-pr area` | `area` | A |
| `/split-pr plan --pattern=B` | `plan` | B |

---

## Step 1: 事前確認

以下を確認し、問題があれば中止してユーザーに報告する。

```bash
# 現在のブランチ名を取得
git branch --show-current

# 未コミットの変更確認
git status --short

# gh CLI の認証確認
gh auth status
```

確認項目:
- 現在のブランチが `feature/` または `fix/` で始まること（mainでないこと）
- 未コミット・未ステージのファイルがないこと
- `gh` CLI が認証済みであること

現在のブランチ名を `CURRENT_BRANCH` として保持する。

---

## Step 2: infra層ファイルの収集

以下のパスに存在するファイルを収集する（`domain` 変数を使用）:

```
lib/data/services/web_api/{domain}/
lib/domain/entities/{domain}/
lib/domain/interfaces/{domain}/
lib/data/repositories/{domain}/
```

```bash
# 存在するファイル一覧（生成ファイル除く）
find lib/data/services/web_api/{domain} \
     lib/domain/entities/{domain} \
     lib/domain/interfaces/{domain} \
     lib/data/repositories/{domain} \
     -name "*.dart" ! -name "*.freezed.dart" ! -name "*.g.dart" \
     2>/dev/null
```

収集したファイルパス一覧を `INFRA_FILES` として保持する。
対象ファイルが1件も見つからない場合はユーザーに確認して中止。

---

## Step 3: feature/xxx-infra ブランチ作成

```bash
INFRA_BRANCH="${CURRENT_BRANCH}-infra"

# main から infra ブランチを作成
git checkout main
git pull origin main
git checkout -b ${INFRA_BRANCH}
```

---

## Step 4: infra層ファイルを infra ブランチにコピー

`CURRENT_BRANCH` から infra層ファイルを checkout する:

```bash
git checkout ${CURRENT_BRANCH} -- {INFRA_FILESの各パス}
```

コミット:

```bash
git add {INFRA_FILES}
git commit -m "feat({domain}): add infra layer (service/repository)"
```

---

## Step 5: PR-infra 作成

```bash
git push origin ${INFRA_BRANCH}

gh pr create \
  --base main \
  --head ${INFRA_BRANCH} \
  --title "feat({domain}): infra layer [auto-review]" \
  --body "$(cat <<'EOF'
## 概要
{domain} の infra層（Service / Repository / Entity / Interface）

## review-skill 実行結果
<!-- split-pr skill が自動生成。CI実行後に結果を追記 -->
- /review-service-web-api {domain}: 実行待ち
- /review-repository {domain} --pattern={pattern}: 実行待ち

## 注意
このPRはCI（review-skill）がApproveした場合、自動マージされます。
EOF
)"
```

作成されたPR URLを `PR_INFRA_URL` として保持する。

---

## Step 6: 元ブランチに戻る

```bash
git checkout ${CURRENT_BRANCH}
```

---

## Step 7: PR-domain 作成

```bash
git push origin ${CURRENT_BRANCH}

gh pr create \
  --base main \
  --head ${CURRENT_BRANCH} \
  --title "feat({domain}): domain layer" \
  --body "$(cat <<'EOF'
## 概要
{domain} の domain層（UseCase / Notifier / View）

## 依存PR
PR-infra（自動マージ後、このPRの差分から Service/Repository が消えます）:
{PR_INFRA_URL}

## review-skill 実行済み（infra層）
PR-infraのCIで確認。Approveされ次第自動マージ予定。

## レビュー対象
- lib/domain/use_cases/{domain}/
- lib/presentation/{domain}/

## テスト
- [ ] flutter test 通過
- [ ] 動作確認（スクリーンショットまたは動画）
EOF
)"
```

作成されたPR URLを `PR_DOMAIN_URL` として保持する。

---

## Step 8: 完了通知

以下を出力する:

```
✅ split-pr 完了

PR-infra（自動レビュー）: {PR_INFRA_URL}
PR-domain（人間レビュー）: {PR_DOMAIN_URL}

次のステップ:
1. CI が PR-infra の review-skill を自動実行
2. Approve → PR-infra が自動マージ
3. PR-domain の差分が UseCase/Notifier/View のみになる
4. レビュアーに PR-domain のレビュー依頼
```

---

## 注意事項

- `*.freezed.dart` / `*.g.dart` はコピー対象外（build_runner で再生成）
- PR-infra / PR-domain 作成後はブランチを `CURRENT_BRANCH` に戻す
- `registry.md` は infra層ファイルとして PR-infra に含める
- CI auto-merge の設定が未整備の場合、PR-infra は手動マージで代替可
