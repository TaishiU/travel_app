# アーキテクチャ層の責務

## 概要

このプロジェクトは3層構造のクリーンアーキテクチャを採用している。

```
View (Widget)
  ↓ ユーザーアクション
Notifier（AsyncNotifier）──────────────── プレゼンテーション層
  ↓ UseCase 呼び出し（直接データ層へのアクセス禁止）
  ├─ UseCase（画面ユースケース）─────── プレゼンテーション層（画面固有ロジック時のみ）
  └─ UseCase（ドメインユースケース）── ドメイン層
       ↓ Interface 経由
Interface（Repository 抽象クラス）──── ドメイン層
  ↑ implements
Repository（実装クラス）──────────────── データ層
  ↓
Service（API / LocalStorage）────────── データ層
  ↓
Web API / Device Storage
```

依存の方向: **プレゼンテーション層 → ドメイン層 ← データ層**

---

## 層の責務

### Entity

**役割**: ビジネスドメインの純粋なモデル

**責務**:
- ビジネス概念の表現
- 不変オブジェクト（Freezed 使用）

**重要なポイント**:
- `data/` や `presentation/` に依存しない（最上位層）
- Freezed で不変性・`copyWith` を保証
- Entity 自体は `fromJson` を持つが、API レスポンスのマッピングは Repository/DTO が担当

参照: `lib/domain/entities/`

---

### UseCase

UseCase は配置層によって**ドメインユースケース**と**画面ユースケース**の2種類に分類される。

---

#### ドメインユースケース

**役割**: 特定の画面に属さないドメイン概念の集約

**配置**: `lib/domain/use_cases/`

**責務**:
- 業務ロジックの実行
- Repository Interface 経由でのデータ取得・加工
- 複数 Repository の協調操作

**禁止事項**:
- state 更新
- Repository 実装クラスへの直接依存

**重要なポイント**:
- Notifier とデータ層の境界として**常に存在させる**（パススルーでも省略しない）
- 呼び出し元が1画面であっても「特定の画面に属さないドメイン概念」であれば domain 層に配置する

```dart
// ❌ Notifier からデータ層に直接アクセス（UseCase を省略）
// Notifier 内
final result = await ref.read(someRepositoryProvider).fetch();
```

参照: `lib/domain/use_cases/`

---

#### 画面ユースケース

**役割**: 特定の画面の関心事に属すロジックの集約

**配置**: `lib/presentation/{feature}/`

**責務**:
- 画面固有の業務ロジックの実行（フォームバリデーション・複数ステップ処理等）
- Notifier に書くには複雑すぎる処理の集約

**禁止事項**:
- state 更新
- Repository 実装クラスへの直接依存

**重要なポイント**:
- 画面固有の複雑なロジックが生じた場合にのみ作成する（YAGNI 適用）
- 単純な委譲のみであれば不要

参照: `lib/presentation/`（各 feature 配下）

---

### Repository

**役割**: データアクセスの境界・DTO/Entity 変換・エラー変換

**責務**:

必須:
- DTO → Entity 変換
- `ApiClientException`（インフラ概念）→ `AppError`（ドメイン概念）への変換
- 複数 DataSource（API・LocalStorage）の調整

任意（ユースケース次第）:
- メモリキャッシュ（重複リクエスト抑制）
- Stream 通知 + SSOT 管理（複数画面でデータを同期する必要がある場合）

**禁止事項**:
- UI 層・Notifier 層への依存
- ビジネスロジックの保持（フィルタリング・ソート・バリデーション）

**重要なポイント**:
- `ApiClientException` → `AppError` への変換はこの層が唯一の場所
- 変換ロジックは private ヘルパーで隠蔽
- パターン選択・SSOT 採用基準の詳細は [`docs/rule/repository_rule.md`](../rule/repository_rule.md) を参照

**Repository の分割基準（Service 層との役割分担）**:

| 層 | 分割の軸 | 理由 |
|---|---|---|
| **Service 層** | URL 構造（API の都合） | エンドポイントと 1:1 で対応し、HTTP 通信を忠実に抽象化する |
| **Repository 層** | Entity の所有権（ドメインの都合） | UseCase が扱うドメイン概念を中心に据え、URL 構造を隠蔽する |

URL とドメインが一致しないケースはこの分割で吸収する。例: `GET /activities/{activityId}/plans` は URL 上 `activities/` 配下だが、返却するのは `PlanWithMeetingPoints`（Plan ドメインの Entity）であるため `PlanRepository` に集約する。`ActivitiesApiService` を `PlanRepository` が呼び出す形になるが、これは意図した設計である。

参照: `lib/data/repositories/`

---

### Service

**役割**: 外部システム（API・LocalStorage）との通信を抽象化

**責務**:
- **Remote API Service**: HTTP 通信の抽象化・DTO の返却
- **Local Storage Service**: SecureStorage / SharedPreferences の抽象化
- **DTO（Data Transfer Object）**: API レスポンスの型定義・JSON 変換

**禁止事項**:
- ビジネスロジックの保持
- `AppError` への変換（変換は Repository が担う）

**ファイル命名規則**:
- `*.dart` = interface / abstract class、`*_impl.dart` = concrete class（IF有無に関わらず）

**重要なポイント**:
- Interface + Impl で依存逆転を実現（テスト時にスタブ実装と差し替え可能）
- DTO はこの層が所有（`lib/data/services/web_api/{feature}/dto.dart`）
- DTO の全フィールドは nullable（サーバー仕様の変動に対応）
- `ApiClient` は認証トークン付与・リトライ・401 リフレッシュを自動処理

**Service 層で IF を設ける基準**

IF を設ける目的は1つ：**実I/O をスタブに差し替えてテストを可能にするため**。

```
Repository（呼び出し元） → Service Interface ← StubImpl（テスト時: インメモリ）
                                              ← ServiceImpl（本番時: http / flutter_secure_storage 等）
```

| 判断 | 基準 |
|---|---|
| **IF を設ける** | 実I/O（ネットワーク・ストレージ・デバイスAPI等）をクラス内で直接実行している |
| **IF 不要** | 別の Service に委譲しているだけで、自身は実I/O を持たない（下位 Service の IF があれば十分） |

**外部パッケージの依存はコンストラクタ注入で対応**

Firebase や Braze など外部SDKをServiceImpl内で使う場合、SDKインスタンスをコンストラクタ注入し、Provider 単位で差し替え可能にする。追加の IF は不要。

```dart
// ✅ Good: 外部SDKのインスタンスをコンストラクタ注入 → テスト時にProviderごと差し替え可能
final firebaseMessagingProvider = Provider<FirebaseMessaging>(
  (_) => FirebaseMessaging.instance,
);

final pushTokenServiceImplProvider = Provider<PushTokenService>(
  (ref) => PushTokenServiceImpl(
    brazePlugin: ref.read(brazePluginProvider),
    firebaseMessaging: ref.read(firebaseMessagingProvider), // ← テスト時にオーバーライド
    isAndroid: Platform.isAndroid,
  ),
);
```

**domain 層の IF との違い**

| IF の種類 | 目的 | 設ける層 |
|---|---|---|
| Repository Interface | DIP（依存性逆転）: UseCase がデータ層に依存しないようにする | domain 層 |
| Service Interface | スタブ注入: 実I/O をテストで差し替える | data 層（Service 層） |

domain 層の Repository Interface は UseCase → Repository の依存を逆転させるために**常に設ける**（パススルーでも省略しない）。Service 層の IF とは目的が異なるため混同しないこと。

参照: `lib/data/services/`

---

### Provider

**役割**: 依存注入の司令塔

**責務**:
- Repository・Service・Notifier のインスタンス生成・提供
- 依存関係の解決
- インスタンスのライフサイクル管理

**配置ルール**:
- **プロバイダー定義は必ずファイル上部（クラス定義の前）に配置する**
- 同一ファイルに提供先クラスが定義されている場合も同様（Dart はファイル内の前方参照を許容するため問題ない）

**重要なポイント**:
- `ref.watch` は変更検知・再構築が必要な場合
- `ref.read` は一度きりの読み取り・アクション実行時
- `autoDispose` で画面スコープの Provider は自動破棄

参照: `lib/presentation/`（各 notifier.dart）、`lib/data/repositories/`

---

### ViewModel（Notifier + UseCase）

ViewModel は **Notifier** と **UseCase（画面ユースケース）** の2コンポーネントで構成される。

#### Notifier（AsyncNotifier）

**責務**:
- UseCase 呼び出し
- state 更新

**禁止**:
- 業務ロジックの保持
- データ層（Repository 実装・Service）への直接アクセス

**補足**: `ref.listen` で他 Notifier の変更を監視し SSOT を維持

```dart
// ❌ データ層への直接アクセス（UseCase を経由すること）
final result = await ref.read(todoRepositoryProvider).fetch();

// ❌ Result<State> 二重ラップ（error_handling.md 参照）
class Notifier extends AsyncNotifier<Result<State>> { ... }
```

#### UseCase（画面ユースケース）

→ [UseCase セクション](#画面ユースケース) 参照

#### Repository Interface

依存性の逆転により、UseCase はデータ層の変更（Firebase→Supabase 切替等）の影響を受けない。
テスト時にモック実装を差し替え可能 → テスタビリティ向上

**重要なポイント**:
- `AsyncNotifier<State>` を使用する（`Result<State>` の二重ラップはしない）
- `FailureResult` は `throw error` で Riverpod の `AsyncError` に変換する
- `build()` 内で Stream を `watch` → Repository がデータを更新すると自動で再構築
- public メソッド名は View からのアクション名（`toggleTodo`, `refresh`, `logout`）
- データ取得・更新は UseCase 経由（`ref.read(useCaseProvider).method()`）
- エラーハンドリングの詳細は [error_handling.md](error_handling.md) を参照

参照: `lib/presentation/`

---

### State

**役割**: UI の表示状態を保持

**責務**:
- UI の描画に必要なデータの保持
- イミュータブルなデータクラス（Freezed 使用）
- SSOT から提供されるデータと UI 固有状態（検索クエリ等）を合わせて保持

**重要なポイント**:
- State は UI 固有の状態のみ持つ（データの真実は Repository の SSOT が持つ）

参照: `lib/presentation/`（各 feature 配下）

---

### View (Widget)

**役割**: UI コンポーネント・画面表示

**責務**:
- 状態を表示するのみ
- ユーザーアクションを Notifier に伝える

**禁止**:
- ビジネスロジックの保持
- UseCase / Repository への直接呼び出し

```dart
// ❌ AsyncData の中に Result の二重 switch
AsyncData(value: final result) => switch (result) {
  SuccessResult(value: final s) => _Body(state: s),
  FailureResult(:final error) => CoreError(...),
},
// → AsyncData / AsyncError のみで分岐する（error_handling.md 参照）

// ❌ View 内のビジネスロジック
final filtered = state?.todos.where((t) => !t.completed).toList();
// → Notifier / UseCase に移動する
```

エラーハンドリングの詳細は [error_handling.md](error_handling.md) を参照。

参照: `lib/presentation/`
