/// Pushトークン登録のサービスインターフェース。
abstract class PushTokenService {
  /// FCMトークンを取得してBrazeに登録する。
  /// iOSはpush.automation = trueで自動処理のためno-op。
  Future<void> register();
}
