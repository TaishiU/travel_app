---
name: find-defects
description: 業務ロジック層の実装を5つの攻撃視点でレビューし、Critical欠陥のみをレポートに出力する
argument-hint: "<adr-path> [<commit-hash>] | <commit-hash>"
---

# find-defects

Notifier / UseCase / Interface / Repository / Service の実装を攻撃者視点で精査し、Critical欠陥のみを報告する。

---

## 引数

| 引数 | 例 | 説明 |
|---|---|---|
| `<adr-path>` | `docs/adr/foo/bar.md` | 設計書 |
| `<commit-hash>` | `b7bdd80` | レビュー対象コミット |

- 両方指定 → 設計書 + diff でレビュー
- どちらか一方 → 指定されたもののみ
- 両方なし → ユーザーに確認

---

## 実行手順

### 1. 対象コードの取得

`<commit-hash>` が指定されている場合:

```bash
git show <commit-hash>
```

`<adr-path>` が指定されている場合: Read で読み込む。

---

### 2. 5視点レビュー

対象層: Notifier / UseCase / Interface / Repository / Service

以下5視点で精査する。**確信のない指摘は含めない。Critical以外は無視する。**

---

#### 視点1: 非原子性・並行呼び出し

「読んで → 判断して → 書く」3ステップが非原子なケース:
- 予約・決済・キャンセル等の重要アクションがUI連打・並行実行で二重発火したとき、二重書き込み・二重決済が起きないか
- `await A(); await B();` の間に同じメソッドが再度呼ばれ、状態が不正にならないか

#### 視点2: 異常系・部分失敗の中途状態

多段処理（決済API → 予約API → ローカル更新）で途中ステップが失敗したとき:
- 前ステップの副作用（課金・フラグ・ストレージ書き込み）が残留し、不整合な状態が確定しないか
- try-catch の範囲が広すぎて意図しない例外を握りつぶしていないか

#### 視点3: サイレント成功・サイレント失敗

呼び出し元が失敗に気づけないケース:
- メソッドが内部で例外をキャッチして成功として返している箇所はないか
- `SuccessResult` を返しているが、実際の API 呼び出し・書き込みが行われていない状態が生まれないか

#### 視点4: TOCTOU（Time-of-Check-Time-of-Use）

確認と実行の間に状態が変わるケース:
- `if (canBook) { await payment(); book(); }` のように await 中に前提条件が変化する箇所はないか
- 在庫・価格・セッション・クーポン有効期限を確認後 await が挟まり、実行時には状態が陳腐化していないか

#### 視点5: SSOT楽観的更新のロールバック保証

Repository が Stream に楽観的先行更新した後 API が失敗するケース:
- 失敗時に必ず元の値を Stream に再発行しているか
- rollback 処理が例外ハンドラの外に書かれていないか（例外が飲まれると rollback も走らない）
- 複数フィールドの SSOT（価格・在庫・予約状態）で一部だけロールバックされる中途半端な状態が生まれないか

---

### 3. 出力ファイル決定

```bash
mkdir -p docs/find_defects
TODAY=$(date +%Y-%m-%d)
N=$(ls docs/find_defects/defects_${TODAY}_*.md 2>/dev/null | wc -l)
N=$((N + 1))
```

出力先: `docs/find_defects/defects_${TODAY}_${N}.md`

---

### 4. レポート出力

Critical 欠陥のみ書き出す。欠陥ゼロなら「欠陥なし」のみ記載。

```markdown
# 欠陥レポート

**対象コミット**: `{commit-hash}`（指定なしの場合は省略）
**対象 ADR**: `{adr-path}`（指定なしの場合は省略）
**実施日**: {YYYY-MM-DD}

---

### {番号}. {タイトル}【Critical】
**箇所**: `{ファイルパス}` ({行番号}行目)
{欠陥の説明}
**影響シーケンス:**
1. {ステップ}
**影響**: {具体的な影響}

---

## 結論
Critical {N}件。
```

---

## 禁止事項

- コード・設定ファイルへの書き込み・編集は一切行わない（`docs/find_defects/` への Write のみ許可）
- 修正案・修正指示を書かない
- Critical 以外を出力しない
- 確信のない指摘を含めない
