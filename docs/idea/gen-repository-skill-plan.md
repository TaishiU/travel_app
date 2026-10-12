# セッションログ: Repository 設計相談 → 規約整備

日付: 2026-10-08

---

## セッションの目的

既存の `architecture_responsibilities.md` の Repository セクションが SSOT + Stream パターン（TodoRepository の「いいね同期」ユースケース）を汎用的な責務として記載してしまっていたため、本来の Repository の役割・責務・禁止事項を再整理し、詳細規約を別ファイルに分離した。

---

## アクセスしたファイル一覧

### 読み込み（参照）

| ファイルパス | 目的 |
|---|---|
| `docs/architecture/architecture_responsibilities.md` | 既存のRepository定義確認 |
| `lib/data/repositories/auth/auth_repository.dart` | Pattern D（ChangeNotifier）の実装確認 |
| `lib/data/repositories/task/task_repository.dart` | Pattern C（LocalDB Stream）の実装確認 |
| `lib/data/repositories/todo/todo_repository.dart` | Pattern B（SSOT + StreamController）の実装確認 |
| `lib/data/repositories/user/user_repository.dart` | Pattern A（シンプルfetch）の実装確認 |

### 編集・新規作成

| ファイルパス | 変更内容 |
|---|---|
| `docs/architecture/architecture_responsibilities.md` | Repositoryセクションを簡潔化（役割・必須/任意責務・禁止事項のみ）。詳細は repository_rule.md へ誘導 |
| `docs/rule/repository_rule.md` | 新規作成。詳細規約を記載 |

---

## 整理した主要ポイント

### 1. architecture_responsibilities.md の変更内容

- 役割を「SSOT管理者」→「データアクセスの境界・DTO/Entity変換・エラー変換」に改定
- 責務を「必須」（DTO変換・AppError変換・DataSource調整）と「任意」（キャッシュ・Stream）に分離
- 禁止事項にビジネスロジック禁止を追加
- 詳細は `docs/rule/repository_rule.md` へ誘導

### 2. repository_rule.md の内容（新規作成）

以下の6セクションで構成:

#### Interface と依存性の逆転
- Interface: `lib/domain/interfaces/{feature}/〇〇_repository.dart`
- Impl: `lib/data/repositories/{feature}/〇〇_repository_impl.dart`
- Entity: `lib/domain/entities/{feature}/〇〇.dart`
- Provider は Impl ファイルに定義し、**型は Interface** で提供
- 依存の方向: `UseCase → Interface ← RepositoryImpl`
- **Auth 特殊ケース（重要）**: `ChangeNotifier` の継承は Impl 側のみ。Interface（Domain層）は Flutter 非依存に保つ。Provider を2本構成（UseCase用・GoRouter用）にする

#### 4パターン一覧

| パターン | 典型例 | 使用条件 |
|---|---|---|
| A: シンプル fetch | `UserRepository` | 単一画面・キャッシュ不要 |
| B: メモリキャッシュ + StreamController | `TodoRepository` | 複数画面でデータ同期が必要 |
| C: LocalDB Stream パススルー | `TaskRepository` | DB がリアクティブな場合 |
| D: ChangeNotifier | `AuthRepository` | GoRouter リダイレクト専用 |

#### SSOT 採用基準
複数の独立した画面が同一データを同時に表示・更新する場合のみ Pattern B または C を選択。

#### `_toEntity`（腐敗防止層）
- DTO（nullable）→ Entity（non-nullable）への変換で null を排除
- 必須フィールド欠損時は `null` を返し、呼び出し元（fetch メソッド）で `FailureResult` に変換
- 型別デフォルト初期値あり（String→`''`、int→`0`、bool→`false`、List→`[]`）

#### 共通規約
- `ApiClientException` → `AppError` 変換は Repository が唯一
- ビジネスロジック・プレゼンテーション層の関心事は持たない

---

## 次セッションの目的

**Repository の実装を自動化する Claude Code Skill の作成**
- skill名: `gen-repository` Skill

### 参考にすべき既存 Skill

`gen-service-web-api` Skill（`docs/idea/gen-service-web-api-skill-plan.md`）が Service 層の自動生成 Skill として実装済み。Repository Skill もこれに準拠した設計にすることを検討する。

### Skill が生成すべきファイル

1. `lib/domain/interfaces/{feature}/〇〇_repository.dart`（Interface）
2. `lib/data/repositories/{feature}/〇〇_repository_impl.dart`（Impl + Provider）
3. `lib/domain/entities/{feature}/〇〇.dart`（Entity）

### 判断が必要な事項

- どのパターン（A〜D）を Skill の対象にするか（全パターン or 主要パターンのみ）
- openapi.yaml を入力とする `gen-service-web-api` と異なり、Repository Skill の入力（トリガー）を何にするか

### 読み込むべきファイル

- `docs/rule/repository_rule.md`（Repository 規約）
- `docs/architecture/architecture_responsibilities.md`（アーキテクチャ全体）
- `docs/idea/gen-service-web-api-skill-plan.md`（既存 Skill の設計参考）
- `lib/data/repositories/` 配下の既存実装4本（実装の参考）
- `lib/domain/interfaces/` 配下（存在すれば）
