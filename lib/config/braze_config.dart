/// Braze SDK 設定値。ビルド時に `--dart-define=FLAVOR=<dev|staging|prod>` で切り替える。
///
/// Android Studio: Run/Debug Configuration → Additional run args に
/// `--dart-define=FLAVOR=dev` を指定する。
/// 省略時は dev にフォールバック。
class BrazeConfig {
  static const _flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  /// 現在のビルドフレーバー（dev / staging / prod）
  static String get flavor => _flavor;

  /// Android 用 Braze API キー（FLAVOR に応じて切り替わる）
  static String get androidApiKey => switch (_flavor) {
    'prod' => 'YOUR_PROD_ANDROID_API_KEY',
    'staging' => 'YOUR_STG_ANDROID_API_KEY',
    _ => 'YOUR_DEV_ANDROID_API_KEY',
  };

  /// iOS 用 Braze API キー（FLAVOR に応じて切り替わる）
  static String get iosApiKey => switch (_flavor) {
    'prod' => 'YOUR_PROD_IOS_API_KEY',
    'staging' => 'YOUR_STG_IOS_API_KEY',
    _ => 'YOUR_DEV_IOS_API_KEY',
  };

  /// Braze SDK エンドポイント（例: `sdk.iad-01.braze.com`）
  static String get endpoint => switch (_flavor) {
    'prod' => 'YOUR_PROD_BRAZE_ENDPOINT',
    'staging' => 'YOUR_STG_BRAZE_ENDPOINT',
    _ => 'YOUR_DEV_BRAZE_ENDPOINT',
  };
}
