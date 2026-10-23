# Phase 2: 基盤実装 概要

> 各タスクチケット（BRAZE-010〜017）の親ドキュメント。
> 実装に着手する前にこのドキュメントで方針・スコープ・未決定事項を確認すること。

---

## Phase 2 実装範囲の整理

### 前提：コードの現状

| 項目 | 状態 |
|---|---|
| Braze SDK | 未導入 |
| Firebase Messaging | 未導入 |
| Push権限 | 未実装 |
| Deep Link | 未実装 |
| 認証 | 実装済み（login / logout / token管理） |
| `user_id` | `LoginDto.id` に存在 → 取得可能 |
| 画面 | login / todo_list / todo_detail / task / profile / debug のみ |
| 予約・旅行ドメイン | **完全に存在しない** |
| 通知設定UI | **存在しない** |

---

## Phase 2 チケット別の実装可能性

| チケット | 可否 | 理由 |
|---|---|---|
| BRAZE-010 SDK導入 | ✅ 完全実装可 | Firebase（Android）+ Braze SDK導入・初期化。後続タスクで実機確認できる状態を作る |
| BRAZE-011 環境別設定 | ✅ 完全実装可 | Dart define / flutter_config で分離 |
| BRAZE-012 Push権限管理 | ✅ 完全実装可 | `permission_handler` + UseCase |
| BRAZE-013 Pushトークン登録 | ✅ 完全実装可 | SDK依存なし |
| BRAZE-014 ユーザー識別 | ✅ 完全実装可 | `LoginDto.id` あり → `AuthSecureStorage` に `userId` 追加で対応 |
| BRAZE-015 属性送信Repository | ✅ インフラのみ実装可 | `BrazeAnalyticsService` + `NotificationAnalyticsRepository` の骨格 |
| BRAZE-016 カスタムイベント送信 | ⚠️ インフラのみ | booking/travel系イベントのトリガー画面が存在しない → **ログイン・ログアウト・権限取得イベントのみ** |
| BRAZE-017 通知タップ遷移 | ⚠️ 既存ルートのみ | `/todo_list` `/profile` 等のみ対応可。booking系Deep Linkはルート未定義 |

---

## 提案：Phase 2 最小実装スコープ

**方針: 「インフラ完成」に絞る。ドメイン依存イベントはPhase 3へ**

### Firebase 導入の位置づけ（iOS / Android 比較）

| 項目 | iOS | Android |
|---|---|---|
| Push配信経路 | APNs（直接） | FCM経由 |
| `firebase_core` | 不要 | **必要**（BrazeがFCMに内部依存） |
| `firebase_messaging` | 不要 | **必要**（FCMトークン取得） |
| `GoogleService-Info.plist` | 不要 | — |
| `google-services.json` | — | **必要** |

iOSはBrazeがAPNsと直接通信するためFirebaseは不要。Androidのみ必要。
Firebase関連作業はすべてBRAZE-010に吸収し、後続タスクで実機確認できる状態を先に作る。

### 含める（BRAZE-010〜015 + 016/017縮小版）

| 実装内容 | 変更・新規ファイル |
|---|---|
| Firebase / FCM セットアップ（Android） | Firebase Consoleでアプリ登録 → `google-services.json` を `android/app/` に配置<br>`pubspec.yaml` に `firebase_core` / `firebase_messaging` 追加<br>`android/build.gradle` / `app/build.gradle` に `google-services` プラグイン追加 |
| Braze SDK導入・初期化 | `pubspec.yaml` に `braze_plugin` 追加<br>`lib/main.dart` でSDK初期化<br>`ios/Runner/AppDelegate.swift` で `BrazePlugin.configure` 設定<br>`android/app/src/main/res/values/braze.xml` でAndroid設定 |
| 環境別APIキー管理 | `lib/config/braze_config.dart`（dev / staging / prod） |
| Push権限管理 | `../../../../lib/domain/use_cases/permission/notification/notification_permission_use_case.dart` |
| Pushトークン登録 | Braze SDKの `registerPushToken` をService経由で呼ぶ |
| ユーザー識別 | `AuthSecureStorageService` に `userId` 追加 + `AuthUseCase.login` / `logout` に `changeUser` / Brazeログアウト追加 |
| 属性送信インフラ | `lib/data/services/braze/braze_analytics_service.dart`（interface）<br>`lib/data/services/braze/braze_analytics_service_impl.dart`（impl）<br>`lib/data/services/braze/stub_braze_analytics_service_impl.dart`（stub）<br>`../../../../lib/data/repositories/permission/notification/notification_analytics_repository.dart` |
| 最小イベント送信 | `login_completed`, `logout_completed`, `push_permission_requested`, `push_permission_granted` のみ |
| Deep Link（既存ルートのみ） | `lib/router/router.dart` にBrazeタップコールバック追加。`/todo_list` `/profile` のみ遷移先として定義 |

### 除外（Phase 3以降）

- `booking_confirmed` / `payment_completed` 等 booking系イベント（対応画面なし）
- `trip_started` / `trip_completed` 等 旅行ステータス系（対応ドメインなし）
- 通知設定UI（`lib/presentation/notification_settings/screen.dart` 等）
- `marketing_consent` 管理
- カレンダー連携・位置情報連携

---

## 残課題（設計決定が必要な点）

各チケットのADR内で仮決定を明記しながら進める。

| # | 課題 | 選択肢 | 仮決定チケット |
|---|---|---|---|
| 1 | 環境別APIキーの管理方法 | A: `--dart-define` でビルド時注入<br>B: `flutter_config` / `envied` | BRAZE-011 |
| 2 | 冷起動時のDeep Link GoRouter連携 | Brazeタップコールバック取得タイミングをどこで待つか（`main.dart` vs `router.dart`） | BRAZE-017 |
| 3 | `userId` の型変換 | `LoginDto.id` は `int?` → Brazeの `changeUser` は `String` → `id.toString()` で変換する想定 | BRAZE-014 |

---

## 参考資料：Braze公式サンプルコード

ローカルパス: `/Users/taishiutsunomiya/StudioProjects/braze-flutter-sdk/example`

各チケット実装時に下記ファイルを参照すること。

### ファイル別の参照用途

| ファイル | 参照用途 | 関連チケット |
|---|---|---|
| `lib/main.dart` | SDK初期化の基本構造（`BrazePlugin.logLevel` 設定 → `runApp` 前に初期化） | BRAZE-010 |
| `lib/constants/config.dart` | APIキー・エンドポイントの定数管理パターン | BRAZE-011 |
| `lib/screens/home_screen.dart` | `BrazePlugin` インスタンス生成・`initialize(apiKey, endpoint)` 呼び出し・`deepLinkChannel` 設定 | BRAZE-010, BRAZE-017 |
| `lib/screens/user_management_screen.dart` | `changeUser()` / `logout()` / `registerPushToken()` / `subscribeToPushNotificationEvents()` の使い方 | BRAZE-013, BRAZE-014, BRAZE-016 |
| `lib/sdk_helpers.dart` | `logCustomEvent` のプロパティ付き呼び出しパターン | BRAZE-016 |
| `docs/guide.md` | 画面別API解説（Lv.1〜5）。初学者向けのAPI早見表として有用 | 全般 |
| `ios/Runner/AppDelegate.swift` | iOS側のBraze設定（`BrazePlugin.configure`）・Push権限要求（`UNUserNotificationCenter`）・Deep Link転送（`deepLinkChannel`） | BRAZE-010, BRAZE-012, BRAZE-017 |
| `android/app/src/main/res/values/braze.xml` | Android側のBraze設定ファイル構造（APIキー・FCM設定・Deep Link自動処理フラグ） | BRAZE-010, BRAZE-011 |
| `android/app/src/main/kotlin/.../MainActivity.kt` | Android側のDeep Link受信（`handleDeepLink`）・FCMトークン手動登録パターン | BRAZE-013, BRAZE-017 |

### チケット別の主要参照箇所

#### BRAZE-010 SDK導入・初期化

```dart
// home_screen.dart — Dartレイヤーでの初期化
braze = BrazePlugin(customConfigs: {replayCallbacksConfigKey: true});
braze.initialize(apiKey, endpoint);
```

```swift
// AppDelegate.swift — iOSレイヤーでの設定（Dartのinitialize()呼び出し前に設定を注入）
BrazePlugin.configure { configuration in
    configuration.push.automation = true
}
```

```xml
<!-- braze.xml — Androidレイヤーの設定 -->
<string name="com_braze_api_key">YOUR_APP_IDENTIFIER_API_KEY</string>
<bool name="com_braze_firebase_cloud_messaging_registration_enabled">true</bool>
```

#### BRAZE-012 Push権限管理（iOS）

```swift
// AppDelegate.swift — Push権限要求と APNs登録
UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
    DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
    }
}
```

#### BRAZE-013 Pushトークン登録

```dart
// user_management_screen.dart — トークン登録
braze.registerPushToken(token);

// Push通知イベント購読
_pushEventsSubscription = braze.subscribeToPushNotificationEvents(_pushNotificationEventReceived);
```

```kotlin
// MainActivity.kt — AndroidでのFCMトークン取得→Braze登録
FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
    Braze.getInstance(applicationContext).registeredPushToken = task.result
}
```

#### BRAZE-014 ユーザー識別

```dart
// user_management_screen.dart
braze.changeUser(userId);  // ログイン時

// logout() は push解除 → データ消去 → SDK無効化 を一括実行
await braze.logout();
```

#### BRAZE-016 カスタムイベント送信

```dart
// sdk_helpers.dart
braze.logCustomEvent('eventName');
braze.logCustomEvent('eventName', properties: {'key': 'value', 'count': 1});
braze.requestImmediateDataFlush();  // キューを即送信
```

#### BRAZE-017 Deep Link遷移

```swift
// AppDelegate.swift — URLをDartレイヤーへ転送
let deepLinkChannel = FlutterMethodChannel(name: "deepLinkChannel", binaryMessenger: ...)
deepLinkChannel.invokeMethod("receiveDeepLink", arguments: url.absoluteString)
```

```kotlin
// MainActivity.kt — Androidでの受信
override fun onNewIntent(intent: Intent) {
    handleDeepLink(intent)
}
private fun handleDeepLink(intent: Intent) {
    MethodChannel(binaryMessenger, "deepLinkChannel").invokeMethod("receivedLink", intent.data.toString())
}
```

```dart
// home_screen.dart — DartレイヤーでのDeep Link受信
MethodChannel('deepLinkChannel').setMethodCallHandler((call) async {
    showDeepLinkAlert(context, call.arguments as String);
});
```

---

## チケット一覧

| チケット | ADRファイル | 状態 |
|---|---|---|
| BRAZE-010 Braze SDK導入 | `braze_010.md` | ✅ 完了（2026-10-14） |
| BRAZE-011 環境別設定 | `braze_011.md` | ✅ 完了（2026-10-14） |
| BRAZE-012 Push権限管理 | `braze_012.md` | ✅ 完了（2026-10-14） |
| BRAZE-013 Pushトークン登録 | `braze_013.md` | ✅ 完了（2026-10-18） |
| BRAZE-014 ユーザー識別 | `braze_014.md` | ✅ 完了（2026-10-22） |
| BRAZE-015 属性送信Repository | `braze_015.md` | ✅ 完了（2026-10-22） |
| BRAZE-016 カスタムイベント送信（縮小版） | `braze_016.md` | ✅ 完了（2026-10-23） |
| BRAZE-017 通知タップ遷移（縮小版） | `braze_017.md` | ✅ 完了（2026-10-23） |
