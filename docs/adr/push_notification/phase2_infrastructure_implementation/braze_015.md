# BRAZE-015 属性送信Repository

## 概要

Braze属性・カスタムイベント送信を `BrazeAnalyticsService` + `NotificationAnalyticsRepository` に集約し、UseCase が Braze SDK を直接参照しない構成を作る。

BRAZE-016 が各 UseCase に接続するまでの「骨格」実装を行う。

---

## 完了条件

- `BrazeAnalyticsService`（interface / impl / stub）が実装されている
- `BrazeEventKey` 定数クラスが定義されている
- `NotificationAnalyticsRepository`（domain interface）が定義されている
- `NotificationAnalyticsRepositoryImpl` が `BrazeAnalyticsService` 経由で Phase 2 最小スコープのメソッドを実装している

---

## 設計決定

### 1. `UserIdentityService` との責務分離

| Service | 責務 |
|---|---|
| `UserIdentityService`（BRAZE-014） | ユーザー識別ライフサイクル（`changeUser` / `logoutSession` / 識別属性の `setStringCustomAttribute`） |
| `BrazeAnalyticsService`（本チケット） | イベントログ・属性設定（`logCustomEvent` / `set*Attribute` / `requestImmediateDataFlush`） |

両 Service でメソッドシグネチャが重複する箇所（`setStringAttribute`）は、`UserIdentityService` が `anonymous_id` 属性専用のまま維持し、`BrazeAnalyticsService` を汎用的な属性設定窓口とする。

### 2. `NotificationAnalyticsRepository` の配置

| レイヤー | パス |
|---|---|
| Domain Interface | `lib/domain/interfaces/notification/notification_analytics_repository.dart` |
| Data Impl | `lib/data/repositories/notification/notification_analytics_repository_impl.dart` |

`permission/notification/` 配下には置かない。通知権限（permission）と通知分析（analytics）は別関心。

### 3. Phase 2 最小スコープのメソッド

BRAZE-016 が接続するまでの骨格。以下 5 メソッドのみ定義する。

| メソッド | 送信内容 | 呼び出し元（BRAZE-016 で接続） |
|---|---|---|
| `trackLoginCompleted()` | `login_completed` イベント | `AuthUseCase.login()` |
| `trackLogoutCompleted()` | `logout_completed` イベント | `AuthUseCase.logout()` |
| `trackPushPermissionRequested()` | `push_permission_requested` イベント | `NotificationPermissionUseCase` |
| `trackPushPermissionGranted()` | `push_permission_granted` イベント | `NotificationPermissionUseCase` |
| `updatePushPermissionStatus({required String status})` | `push_permission_status` 属性 | `NotificationPermissionUseCase` |

### 4. `BrazeEventKey` 定数クラスの新設

`BrazeAttributeKey`（BRAZE-014 で新設）と対にする形で `braze_event_key.dart` を新設する。Phase 2 スコープのイベント名のみ定義し、Phase 3 以降のイベントは実装時に追加する。

### 5. `BrazeAttributeKey` に `pushPermissionStatus` を追加

既存の `anonymousId` に加え、Phase 2 で必要な `pushPermissionStatus` を追加する。

### 6. `notification_preferences` フォーマット（BRAZE-003 未決定事項②）

Phase 2 スコープ外のため保留。Phase 3 実装時に Nested Attribute vs フラット展開を決定する。

---

## 変更ファイル一覧

| 操作 | ファイル |
|---|---|
| **新規** | `lib/data/services/braze/analytics/braze_analytics_service.dart` |
| **新規** | `lib/data/services/braze/analytics/braze_analytics_service_impl.dart` |
| **新規** | `lib/data/services/braze/analytics/stub_braze_analytics_service_impl.dart` |
| **新規** | `lib/data/services/braze/braze_event_key.dart` |
| **新規** | `lib/domain/interfaces/notification/notification_analytics_repository.dart` |
| **新規** | `lib/data/repositories/notification/notification_analytics_repository_impl.dart` |
| **修正** | `lib/data/services/braze/braze_attribute_key.dart` |

`braze_event_key.dart` は `analytics/` に入れず `braze/` root に置く。`notification_analytics_repository_impl.dart`（data層）からも参照されるため、特定サービスディレクトリに閉じない共有定数として管理する。

---

## 実装詳細

### `braze_event_key.dart`

```dart
abstract class BrazeEventKey {
  static const String loginCompleted = 'login_completed';
  static const String logoutCompleted = 'logout_completed';
  static const String pushPermissionRequested = 'push_permission_requested';
  static const String pushPermissionGranted = 'push_permission_granted';
}
```

---

### `braze_attribute_key.dart` 追加分

```dart
/// Push通知権限状態のカスタム属性キー。
static const String pushPermissionStatus = 'push_permission_status';
```

---

### `braze_analytics_service.dart`（interface）

```dart
abstract class BrazeAnalyticsService {
  /// カスタムイベントを送信する。
  void logCustomEvent({
    required String eventName,
    Map<String, dynamic>? properties,
  });

  /// String型カスタム属性を設定する。
  void setStringAttribute({required String key, required String value});

  /// Bool型カスタム属性を設定する。
  void setBoolAttribute({required String key, required bool value});

  /// Int型カスタム属性を設定する。
  void setIntAttribute({required String key, required int value});

  /// キューに積まれたデータをBrazeサーバーへ即時送信する。
  void requestImmediateDataFlush();
}
```

---

### `braze_analytics_service_impl.dart`（impl）

`BrazePlugin` をコンストラクタ注入。

| メソッド | 委譲先 |
|---|---|
| `logCustomEvent` | `_brazePlugin.logCustomEvent(eventName, properties: properties)` |
| `setStringAttribute` | `_brazePlugin.setStringCustomUserAttribute(key, value)` |
| `setBoolAttribute` | `_brazePlugin.setBoolCustomUserAttribute(key, value)` |
| `setIntAttribute` | `_brazePlugin.setIntCustomUserAttribute(key, value)` |
| `requestImmediateDataFlush` | `_brazePlugin.requestImmediateDataFlush()` |

Provider:
```dart
// lib/data/services/braze/analytics/braze_analytics_service_impl.dart
final brazeAnalyticsServiceImplProvider = Provider<BrazeAnalyticsService>(
  (ref) => BrazeAnalyticsServiceImpl(
    brazePlugin: ref.read(brazePluginProvider),
  ),
);
```

---

### `stub_braze_analytics_service_impl.dart`（stub）

全メソッド no-op。`requestImmediateDataFlush` は `Future.value()` を返す。

---

### `notification_analytics_repository.dart`（domain interface）

```dart
abstract class NotificationAnalyticsRepository {
  void trackLoginCompleted();
  void trackLogoutCompleted();
  void trackPushPermissionRequested();
  void trackPushPermissionGranted();
  void updatePushPermissionStatus({required String status});
}
```

---

### `notification_analytics_repository_impl.dart`（impl）

```dart
final notificationAnalyticsRepositoryProvider = Provider<NotificationAnalyticsRepository>(
  (ref) => NotificationAnalyticsRepositoryImpl(
    analyticsService: ref.read(brazeAnalyticsServiceImplProvider),
  ),
);

class NotificationAnalyticsRepositoryImpl implements NotificationAnalyticsRepository {
  NotificationAnalyticsRepositoryImpl({required this._analyticsService});

  final BrazeAnalyticsService _analyticsService;

  @override
  void trackLoginCompleted() =>
      _analyticsService.logCustomEvent(eventName: BrazeEventKey.loginCompleted);

  @override
  void trackLogoutCompleted() =>
      _analyticsService.logCustomEvent(eventName: BrazeEventKey.logoutCompleted);

  @override
  void trackPushPermissionRequested() =>
      _analyticsService.logCustomEvent(eventName: BrazeEventKey.pushPermissionRequested);

  @override
  void trackPushPermissionGranted() =>
      _analyticsService.logCustomEvent(eventName: BrazeEventKey.pushPermissionGranted);

  @override
  void updatePushPermissionStatus({required String status}) =>
      _analyticsService.setStringAttribute(
        key: BrazeAttributeKey.pushPermissionStatus,
        value: status,
      );
}
```

---

## テスト方針

| テストケース | 確認内容 |
|---|---|
| `trackLoginCompleted` | `logCustomEvent(eventName: 'login_completed')` が呼ばれる |
| `trackLogoutCompleted` | `logCustomEvent(eventName: 'logout_completed')` が呼ばれる |
| `trackPushPermissionRequested` | `logCustomEvent(eventName: 'push_permission_requested')` が呼ばれる |
| `trackPushPermissionGranted` | `logCustomEvent(eventName: 'push_permission_granted')` が呼ばれる |
| `updatePushPermissionStatus` | `setStringAttribute(key: 'push_permission_status', value: status)` が呼ばれる |

スタブ: `StubBrazeAnalyticsServiceImpl` を注入し、メソッド呼び出しを `verify`。

---

## スコープ外

| 内容 | チケット |
|---|---|
| UseCase への接続（`AuthUseCase` / `NotificationPermissionUseCase`） | BRAZE-016 |
| `notification_preferences` フォーマット決定（Nested vs フラット） | Phase 3 |
| booking系・trip系イベントの追加 | Phase 3 |
