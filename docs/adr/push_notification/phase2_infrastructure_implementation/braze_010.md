# BRAZE-010: Braze SDK 導入

## ステータス

完了（2026-10-14）

---

## 目的

Flutter向け Braze SDK（`braze_plugin: ^23.0.0`）を追加し、iOS / Android のネイティブ初期化設定を行う。
後続チケット（BRAZE-011〜017）が実機確認できる状態を先に作る。

Firebase セットアップ（FlutterFire CLI による `firebase_core` / `firebase_messaging` 導入、`google-services.json` / `GoogleService-Info.plist` 配置）は完了済みのため、このチケットでは `braze_plugin` のみ対応する。

---

## 変更ファイル一覧

| ファイル | 種別 | 内容 |
|---|---|---|
| `pubspec.yaml` | 変更 | `braze_plugin: ^23.0.0` 追加 |
| `lib/main.dart` | 変更 | `BrazePlugin.logLevel` + `BrazePlugin.initialize()` + `brazePluginProvider` override |
| `lib/config/braze_config.dart` | 新規 | APIキー / エンドポイントの定数管理（プレースホルダー） |
| `lib/data/services/braze/braze_plugin_provider.dart` | 新規 | `Provider<BrazePlugin>` 定義 |
| `ios/Runner/AppDelegate.swift` | 変更 | `BrazePlugin.configure{}` で Push 自動処理設定を保存 |
| `android/app/src/main/res/values/braze.xml` | 新規 | Android SDK 設定（APIキー / カスタムエンドポイント / FCM / DeepLink） |
| `android/app/src/main/AndroidManifest.xml` | 変更 | `INTERNET` / `ACCESS_NETWORK_STATE` パーミッション追加 |

---

## 実装詳細

### 1. パッケージ解決

- パッケージURL: https://pub.dev/packages/braze_plugin

```yaml
# pubspec.yaml
braze_plugin: ^23.0.0
```

```
+ braze_plugin 23.0.0
```

### 2. 初期化フロー（v23.0.0）

v23.0.0 の初期化は **iOS / Android / Dart の3層に分かれる**。

```
アプリ起動
  │
  ├─ iOS: AppDelegate.application(didFinishLaunchingWithOptions)
  │        └─ BrazePlugin.configure { push.automation = true }
  │             ※ ネイティブ設定をキャッシュ（SDKはまだ未生成）
  │
  ├─ Android: braze.xml
  │            └─ APIキー / エンドポイント / FCM / DeepLink 設定を定義
  │
  └─ Dart: main()
            ├─ BrazePlugin.logLevel = BrazeLogLevel.debug  // debug時のみ
            ├─ brazePlugin = BrazePlugin()
            └─ brazePlugin.initialize(apiKey, endpoint)
                 ※ ここで iOS はキャッシュ済み設定 + apiKey/endpoint で Braze インスタンス生成
                 ※ Android は braze.xml 設定 + apiKey/endpoint で初期化
```

### 3. iOS 設定 (`AppDelegate.swift`)

`BrazePlugin.configure {}` はSDKを即生成するのではなく、**設定をキャッシュ**する静的メソッド。
Dart の `brazePlugin.initialize(apiKey, endpoint)` が呼ばれたタイミングで設定が適用され、Braze インスタンスが生成される。

`FlutterImplicitEngineDelegate` パターンとの整合:
- `BrazePlugin.configure` は `application(didFinishLaunchingWithOptions:)` 内で呼ぶ（プラグイン登録前でも可）
- `GeneratedPluginRegistrant.register` は `didInitializeImplicitFlutterEngine` 内に残す

```swift
BrazePlugin.configure { configuration in
  configuration.push.automation = true
}
```

`push.automation = true` により APNs トークン登録・Push 受信・フォアグラウンド表示を自動処理する。

### 4. Android 設定 (`braze.xml`)

```xml
<string name="com_braze_api_key">YOUR_ANDROID_API_KEY</string>
<string name="com_braze_custom_endpoint">YOUR_CUSTOM_ENDPOINT</string>
<bool name="com_braze_firebase_cloud_messaging_registration_enabled">true</bool>
<string name="com_braze_firebase_cloud_messaging_sender_id">YOUR_FCM_SENDER_ID</string>
<bool name="com_braze_handle_push_deep_links_automatically">true</bool>
```

- `com_braze_custom_endpoint`: Brazeダッシュボードのエンドポイント（例: `sdk.iad-01.braze.com`）
- `com_braze_firebase_cloud_messaging_sender_id`: `google-services.json` の `project_number`
- `com_braze_handle_push_deep_links_automatically`: 通知タップ時のDeepLinkをBrazeが自動処理

### 5. Dart 初期化 (`main.dart`)

```dart
if (kDebugMode) {
  BrazePlugin.logLevel = BrazeLogLevel.debug;
}
final brazePlugin = BrazePlugin();
if (Platform.isAndroid) {
  brazePlugin.initialize(BrazeConfig.androidApiKey, BrazeConfig.endpoint);
} else if (Platform.isIOS) {
  brazePlugin.initialize(BrazeConfig.iosApiKey, BrazeConfig.endpoint);
}
```

Android / iOS でAPIキーが別のため Platform 分岐で初期化する。

### 6. Riverpod プロバイダー

`BrazePlugin()` の MethodChannel ハンドラーは1インスタンス登録が前提のため、`main()` で単一インスタンスを生成し `overrideWithValue` で注入する。

```dart
// lib/data/services/braze/braze_plugin_provider.dart
final brazePluginProvider = Provider<BrazePlugin>(
  (_) => throw UnimplementedError('brazePluginProvider は main() で override が必要'),
);
```

既存の `sharedPreferencesServiceImplProvider` と同じ注入パターン。

### 7. Android パーミッション (`AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

pub.dev の公式ドキュメントに記載されている必須パーミッション。

---

## 設計上の決定事項

### `BrazePlugin.configure` vs `BrazePlugin.initBraze`

| API | バージョン | 用途 |
|---|---|---|
| `BrazePlugin.configure {}` | v22.x 〜 v23.x | 設定をキャッシュ → Dart `initialize()` 呼び出し時に適用 |
| `BrazePlugin.initBraze(config)` | v11.x 〜 v21.x | AppDelegate でSDKを即生成（Dart `initialize()` 不要） |

v23.0.0 では `BrazePlugin.configure` + Dart `initialize()` のパターンが正式。`BrazePlugin.initBraze` は旧API。

### Android / iOS で APIキーを分ける理由

BrazeダッシュボードはプラットフォームごとにApp設定が独立しており、APIキーが異なる。同一キーを使用する場合も、将来の分離に備え定数を分けておく。

---

## 未完了・引き継ぎ事項

| 項目 | 引き継ぎ先 |
|---|---|
| APIキー / エンドポイントを `--dart-define` で環境別管理 | BRAZE-011 |
| `com_braze_firebase_cloud_messaging_sender_id` に実値設定 | BRAZE-011 |
| Push 権限要求フロー実装 | BRAZE-012 |
| FCM トークン → Braze 登録確認 | BRAZE-013 |
| ログイン時の `changeUser()` 実装 | BRAZE-014 |

---

## 動作確認手順（BRAZE-011 でAPIキー設定後に実施）

1. iOS Simulator / 実機で `flutter run`
2. Brazeダッシュボード > User Search でテスト端末が登録されることを確認
3. Android エミュレータ / 実機で同様に確認
4. `flutter analyze` でエラーなし ✅（実施済み）
