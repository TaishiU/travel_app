# BRAZE-016 カスタムイベント送信（縮小版）

## 概要

BRAZE-015 で骨格実装した `NotificationAnalyticsRepository` を実際の UseCase に接続し、
Phase 2 最小スコープのカスタムイベントを発火させる。

---

## 完了条件

- `AuthUseCase.login()` 成功時に `login_completed` イベントを送信
- `AuthUseCase.logout()` 完了後に `logout_completed` イベントを送信
- `NotificationPermissionUseCase.requestPermission()` 呼び出し時に `push_permission_requested` イベントを送信
- `requestPermission()` 結果が `granted` の場合のみ `push_permission_granted` イベントを送信
- `checkStatus()` / `requestPermission()` 完了後に `push_permission_status` 属性を更新
- 各 UseCase の integration test が通ること

---

## 設計決定

### 1. `AuthUseCase` への接続方式

`AuthUseCase` は `ref: Ref` パターンを採用し、内部で `ref.read(authRepositoryProvider)` を呼ぶ。
`NotificationAnalyticsRepository` も同様に `ref.read(notificationAnalyticsRepositoryProvider)` で取得する。
constructor injection 追加は行わず、既存パターンとの一貫性を維持する。

### 2. `trackLoginCompleted` の発火タイミング

`login()` が `SuccessResult` を返した場合のみ発火。`FailureResult` では発火しない。

### 3. `trackLogoutCompleted` の発火タイミング

`logout()` は void return で例外を投げない前提。`await repo.logout()` 完了後に発火。

### 4. `checkStatus()` での属性更新

アプリ起動時に最新権限状態を Braze へ同期するため、`checkStatus()` 完了後にも
`updatePushPermissionStatus()` を呼ぶ。イベント送信（`trackPush*`）は行わない。

### 5. `status` 文字列変換

`NotificationPermissionStatus.name` プロパティを使用（Dart 標準）。

| enum 値 | 送信文字列 |
|---|---|
| `granted` | `"granted"` |
| `notDetermined` | `"notDetermined"` |
| `denied` | `"denied"` |
| `permanentlyDenied` | `"permanentlyDenied"` |

### 6. テスト用 Spy

`mockito` 未導入のため、手書きの Spy スタブを使用。
`SpyNotificationAnalyticsRepositoryImpl` を各 test ファイル内にインラインで定義し、
メソッド呼び出し回数・最後に渡された引数を記録する。

---

## 変更ファイル一覧

| 操作 | ファイル |
|---|---|
| **修正** | `lib/domain/use_cases/auth/auth_use_case.dart` |
| **修正** | `lib/domain/use_cases/permission/notification/notification_permission_use_case.dart` |
| **修正** | `test/domain/use_cases/auth/auth_use_case_integration_test.dart` |
| **修正** | `test/domain/use_cases/permission/notification/notification_permission_use_case_integration_test.dart` |

---

## 実装詳細

### `auth_use_case.dart`（修正）

追加 import:
```dart
import 'package:travel_app/data/repositories/notification/notification_analytics_repository_impl.dart';
```

`login()` — `SuccessResult` ブランチに1行追加:
```dart
case SuccessResult<void>():
  ref.read(notificationAnalyticsRepositoryProvider).trackLoginCompleted();
  return SuccessResult(repo.getAndClearPendingDeepLink());
```

`logout()` — `await` 完了後に1行追加:
```dart
Future<void> logout() async {
  await ref.read(authRepositoryProvider).logout();
  ref.read(notificationAnalyticsRepositoryProvider).trackLogoutCompleted();
}
```

---

### `notification_permission_use_case.dart`（修正）

追加 import:
```dart
import 'package:travel_app/data/repositories/notification/notification_analytics_repository_impl.dart';
import 'package:travel_app/domain/entities/permission/notification/notification_permission_status.dart';
import 'package:travel_app/domain/interfaces/notification/notification_analytics_repository.dart';
```

Provider にフィールド追加:
```dart
final notificationPermissionUseCaseProvider = Provider<NotificationPermissionUseCase>(
  (ref) => NotificationPermissionUseCase(
    repository: ref.read(notificationPermissionRepositoryProvider),
    analyticsRepository: ref.read(notificationAnalyticsRepositoryProvider),
  ),
);
```

クラス定義:
```dart
class NotificationPermissionUseCase {
  NotificationPermissionUseCase({
    required this.repository,
    required this.analyticsRepository,
  });

  final NotificationPermissionRepository repository;
  final NotificationAnalyticsRepository analyticsRepository;

  Future<NotificationPermissionStatus> checkStatus() async {
    final status = await repository.checkStatus();
    analyticsRepository.updatePushPermissionStatus(status: status.name);
    return status;
  }

  Future<NotificationPermissionStatus> requestPermission() async {
    analyticsRepository.trackPushPermissionRequested();
    final status = await repository.requestPermission();
    if (status == NotificationPermissionStatus.granted) {
      analyticsRepository.trackPushPermissionGranted();
    }
    analyticsRepository.updatePushPermissionStatus(status: status.name);
    return status;
  }
}
```

---

### `auth_use_case_integration_test.dart`（修正）

`buildContainer` に `brazeAnalyticsServiceImplProvider` オーバーライドを追加。
analytics はno-op スタブになるだけで既存テストケースの変更は不要。

```dart
// 追加 import
import 'package:travel_app/data/services/braze/analytics/braze_analytics_service_impl.dart';
import 'package:travel_app/data/services/braze/analytics/stub_braze_analytics_service_impl.dart';

// buildContainer の overrides に追加
brazeAnalyticsServiceImplProvider.overrideWithValue(StubBrazeAnalyticsServiceImpl()),
```

---

### `notification_permission_use_case_integration_test.dart`（修正）

#### Spy スタブ定義（テストファイル内にインライン定義）

```dart
class SpyNotificationAnalyticsRepositoryImpl
    implements NotificationAnalyticsRepository {
  int trackPushPermissionRequestedCount = 0;
  int trackPushPermissionGrantedCount = 0;
  String? lastPushPermissionStatus;

  @override
  void trackLoginCompleted() {}

  @override
  void trackLogoutCompleted() {}

  @override
  void trackPushPermissionRequested() => trackPushPermissionRequestedCount++;

  @override
  void trackPushPermissionGranted() => trackPushPermissionGrantedCount++;

  @override
  void updatePushPermissionStatus({required String status}) =>
      lastPushPermissionStatus = status;
}
```

#### `buildContainer` 変更

`notificationAnalyticsRepositoryProvider` を spy でオーバーライドできるよう引数を追加:

```dart
ProviderContainer buildContainer({
  NotificationPermissionStatus statusResult = NotificationPermissionStatus.notDetermined,
  NotificationPermissionStatus requestResult = NotificationPermissionStatus.notDetermined,
  SpyNotificationAnalyticsRepositoryImpl? analyticsspy,
}) {
  final container = ProviderContainer(
    overrides: [
      notificationPermissionServiceImplProvider.overrideWithValue(
        StubNotificationPermissionServiceImpl(
          statusResult: statusResult,
          requestResult: requestResult,
        ),
      ),
      notificationAnalyticsRepositoryProvider.overrideWithValue(
        analyticsspy ?? SpyNotificationAnalyticsRepositoryImpl(),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}
```

#### 追加テストケース

`checkStatus` グループへ追加:

| テスト | 確認内容 |
|---|---|
| `granted → updatePushPermissionStatus("granted")` が呼ばれる | `spy.lastPushPermissionStatus == 'granted'` |
| `denied → updatePushPermissionStatus("denied")` が呼ばれる | 同上 |

`requestPermission` グループへ追加:

| テスト | 確認内容 |
|---|---|
| `trackPushPermissionRequested` が必ず1回呼ばれる | `spy.trackPushPermissionRequestedCount == 1` |
| `granted` → `trackPushPermissionGranted` が1回呼ばれる | `spy.trackPushPermissionGrantedCount == 1` |
| `denied` → `trackPushPermissionGranted` は呼ばれない | `spy.trackPushPermissionGrantedCount == 0` |
| `permanentlyDenied` → `trackPushPermissionGranted` は呼ばれない | `spy.trackPushPermissionGrantedCount == 0` |
| `granted → updatePushPermissionStatus("granted")` が呼ばれる | `spy.lastPushPermissionStatus == 'granted'` |

---

## テスト方針サマリー

| UseCase | analytics 確認方法 | 理由 |
|---|---|---|
| `AuthUseCase` | no-op スタブで例外なく動作することを確認 | Repository 層 unit test で `logCustomEvent` 呼び出し確認済み |
| `NotificationPermissionUseCase` | Spy スタブで呼び出し回数・引数を確認 | `granted` 条件分岐の正しさはこの層で検証する必要がある |

---

## スコープ外

| 内容 | チケット |
|---|---|
| `booking_confirmed` / `payment_completed` 等 booking 系イベント | Phase 3 |
| `trip_started` / `trip_completed` 等旅行ステータス系イベント | Phase 3 |
| `marketing_consent` イベント | Phase 3 |
