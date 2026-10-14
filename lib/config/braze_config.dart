/// Braze SDK 設定値。Dart層の `BrazePlugin.initialize(apiKey, endpoint)` で使用する。
///
/// TODO(BRAZE-011): --dart-define による環境別キー注入に移行する
class BrazeConfig {
  /// Android 用 Braze API キー
  static const String androidApiKey = 'YOUR_ANDROID_API_KEY';

  /// iOS 用 Braze API キー
  static const String iosApiKey = 'YOUR_IOS_API_KEY';

  /// Braze SDK エンドポイント（例: `sdk.iad-01.braze.com`）
  static const String endpoint = 'YOUR_BRAZE_ENDPOINT';
}
