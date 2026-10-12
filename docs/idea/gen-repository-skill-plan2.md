# gen-repository Skill 設計メモ（セッション2）

日付: 2026-10-08

---

## 確定した方針

### Skill 基本情報

| 項目 | 内容 |
|---|---|
| Skill名 | `gen-repository` |
| 格納パス | `.claude/skills/gen-repository/SKILL.md` |
| 前提 | `gen-service-web-api` 実行済み（service.dart / dto.dart が存在すること） |

### 呼び出し形式（暫定）

```
/gen-repository auth
/gen-repository area
/gen-repository plan --pattern=A
```

### 生成ファイル

```
lib/domain/entities/{feature}/{entity}.dart              ← Freezed Entity
lib/domain/interfaces/{feature}/{name}_repository.dart   ← Interface
lib/data/repositories/{feature}/{name}_repository_impl.dart ← Impl + Provider
```

`lib/domain/interfaces/` は現存しない → Skill 内で新規作成。

### 名前導出ルール（確定）

**Repository名は Entity名から派生させず、feature-path の単数形ドメイン名を独立ルールで導出する。**

理由: DTO がリストラッパー型（`AreasDto`）の場合、Entity名は `Areas` になるが Repository名は `AreaRepository` が望ましいため。

| 変換パターン | 例 |
|---|---|
| 末尾 `ies` → `y` | `activities → Activity`, `categories → Category` |
| 末尾 `s` を除去 | `areas → Area`, `plans → Plan`, `todos → Todo` |
| 変化なし | `auth → Auth` |

| 対象 | 規則 | 例 |
|---|---|---|
| Entity名 | `XxxDto → Xxx`（Dto サフィックスを除去） | `UserDto → User` |
| Repository名 | `{単数ドメイン名}Repository` | `AreaRepository` |
| RepositoryImpl名 | `{単数ドメイン名}RepositoryImpl` | `AreaRepositoryImpl` |
| Provider名 | `{lowerCamel(Repository名)}Provider` | `areaRepositoryProvider` |

### 多対1構造（確定）

`gen-service-web-api` で同一ドメイン配下に生成されたすべての Service を 1 つの Repository に集約する。凝集度を高めるため、これをデフォルトとする。

**例: Auth ドメイン**

```
web_api/auth/register/  → AuthRegisterApiService
web_api/auth/login/     → AuthLoginApiService
web_api/auth/refresh/   → AuthRefreshApiService
web_api/auth/logout/    → AuthLogoutApiService
web_api/auth/me/        → AuthMeApiService
```

→ `AuthRepository` が 5 つの Service を束ねる（多対1）

**クロスドメインケース（確定）**

`/activities/:activityId/plan` は `activities/` 配下の Service だが、返却 schema が `PlanWithMeetingPoints` のため `PlanRepository` に集約するのが適切。

→ ディレクトリの親子関係だけで機械的に判定するのは不十分。返却 entity のドメインでユーザーが判断する。

### パターン選択（確定）

| パターン | 優先度 | 使用条件 |
|---|---|---|
| A: シンプル fetch | **メイン** | 単一画面・キャッシュ不要（デフォルト） |
| B: メモリキャッシュ + Stream | 低 | 複数画面でデータ同期が必要 |
| C: LocalDB Stream | 低 | DB がリアクティブな場合 |
| D: ChangeNotifier | 最低 | GoRouter リダイレクト専用（Auth のみ） |

---

## 課題への解決策（確定）

### 課題1: 複数 Service 包含の指定方法 → **案C: 自動スキャン + 確認ステップ**

**解決策:**

`lib/data/services/web_api/{domain}/` を自動スキャンしてサービスファイルを収集し、結果をユーザーに提示して追加・除外を確認する。

```
以下の Service を {Domain}Repository に含めます:

  [1] lib/data/services/web_api/{domain}/service.dart
      → {XxxApiService}（fetch, fetchById, ...）
  [2] lib/data/services/web_api/{domain}/{sub}/service.dart
      → {YyyApiService}（login, ...）

追加・除外がある場合は指示してください。
ない場合はそのまま続行します。
```

クロスドメインケース（例: `PlanRepository` が `ActivitiesApiService` の一部メソッドを使う場合）はユーザーが追加指示する運用。

**採用理由:**

- 案A（自動スキャンのみ）: クロスドメインに対応不可のため却下
- 案B（明示指定）: 引数が冗長でユーザー負担大のため却下
- 案C: 自動スキャンで大半をカバーしつつ、クロスドメインは確認ステップで吸収できる

将来100件規模になっても、スキャン対象は `{domain}/` 配下のみ（1ドメイン分）に限定されるためトークン負担は小さい。

---

### 課題2: Entity が複数種類になるケース → **「主概念単位」でファイル分割**

**解決策:**

「1 Repository = 1 Entity ファイル」（案A）は却下。`auth.dart` に `User` が同居するのは不適切（`User` は将来 Auth 以外でも参照される可能性があり、ファイルの意味が曖昧になる）。

**採用ルール: 「主概念（ドメインの中心 Entity）= 1ファイル、その Sub-entity は同居」**

| ファイル | 含める Entity クラス | 理由 |
|---|---|---|
| `auth/auth_token.dart` | `AuthToken` | Auth 固有のトークン情報。他ドメインに流出しない |
| `auth/user.dart` | `User` | 認証ユーザー情報。auth ドメイン所有だが独立ファイルで拡張に備える |
| `area/area.dart` | `Area`, `AreaChild` | `AreaChild` は `Area` の内部概念。同一ファイルが自然 |
| `category/category.dart` | `Category`, `CategoryChild` | 同上 |
| `activity/activity.dart` | `ActivitySummary`, `ActivityDetail`, `ActivityBase`, `ActivityImage` | すべて Activity ドメインの構成要素 |
| `plan/plan.dart` | `Plan`, `PlanWithMeetingPoints`, `PlanDetail`, `PlanBase`, `PlanPrice`, `MeetingPoint`, `PlanSchedule` | すべて Plan ドメインの構成要素 |

**ドメインをまたぐ参照（cross-domain import）は許容する。**

例: `ActivityDetail` が `PlanBase` を内包 → `activity.dart` が `plan.dart` を import する。  
Entity 同士の参照はドメイン間でも許容される（依存性の逆転を強制するのは UseCase→Repository の層境界であって、Entity 間の参照は禁止されていない）。

---

### 課題3: 不一致検知の実装範囲 → **Markdown レジストリ + 3重チェック**

**解決策:**

クラス名ベースの文字列マッチングによる自動検知（Step 1-2 の registry.md チェック）に加え、以下の3重チェック構造で整合性を担保する。

```
openapi.yaml（真実の源泉）
    ↓ 一致チェック
Service 層（lib/data/services/web_api/）
    ↓ 一致チェック
lib/data/repositories/registry.md
    ↓ 一致チェック
Repository 実装（lib/data/repositories/）
```

**registry.md の役割:**

- `gen-repository` Skill の終端で必ず書き込み・更新する
- PR レビュー Skill がこのファイルを読み、openapi.yaml・Service 層との整合をチェックする
- 手動編集禁止（Skill のみが更新する）

**registry.md フォーマット（`lib/data/repositories/registry.md`）:**

```markdown
# Repository Registry

> このファイルは `gen-repository` Skill が自動生成・更新する。手動編集不可。
> PR レビュー時に openapi.yaml・Service 層との整合チェックに使用する。

| Repository | Method | Return Entity | Source Service | Source Endpoint |
|---|---|---|---|---|
| AuthRepository | login | AuthToken | AuthLoginApiService | POST /auth/login |
| AuthRepository | me | User | AuthMeApiService | GET /auth/me |
| AreaRepository | fetch | Area | AreasApiService | GET /areas |
| PlanRepository | fetchByActivityId | PlanWithMeetingPoints | ActivitiesApiService | GET /activities/{activityId}/plans |
| PlanRepository | fetchById | PlanDetail | PlansApiService | GET /plans/{planId} |
```

**格納場所の選定理由（`lib/data/repositories/` 直下）:**

- レジストリの主語は Repository（メソッド・エンドポイント対応）
- `gen-repository` Skill がここを読み書きするため、実装と同一ディレクトリが最もアクセスしやすい
- Repository 追加・修正作業時に自然と目に入る
- `docs/` 配下は規約・設計ドキュメント専用とし、自動更新されるメタファイルは実装近傍に置く

**自動検知ロジック（Step 1-2 での簡易チェック）:**

1. service.dart の戻り値 DTO クラス名を取得（例: `PlanWithMeetingPointsDto`）
2. `Dto` を除いたベース名の先頭単語（`Plan`）と Repository のドメイン名（`Activity`）を比較
3. 不一致 → ユーザーに確認「このメソッドは `PlanRepository` に配置すべきではありませんか？」

誤検知は許容し、最終判断はユーザーに委ねる。

---

## 今後の設計・実装フロー

```
1. 上記3課題の解決策を SKILL.md に反映（完了）
      ↓
2. 動作確認（既存 feature で試し生成）
```

---

## 参照ファイル

| ファイル | 役割 |
|---|---|
| `docs/rule/repository_rule.md` | Repository 規約（4パターン・_toEntity ルール） |
| `docs/architecture/architecture_responsibilities.md` | アーキテクチャ全体像 |
| `docs/idea/gen-service-web-api-skill-plan.md` | Service Skill の設計参考 |
| `.claude/skills/gen-service-web-api/SKILL.md` | 既存 Skill のフォーマット参考 |
| `lib/data/repositories/user/user_repository.dart` | Pattern A 実装例 |
| `lib/data/repositories/todo/todo_repository.dart` | Pattern B 実装例 |
| `lib/data/repositories/auth/auth_repository.dart` | Pattern D 実装例 |
| `lib/domain/entities/user/user.dart` | Entity フォーマット参考 |
