/// Pushトークン登録のRepositoryインターフェース。
abstract class PushTokenRepository {
  /// FCMトークン（Android）またはAPNsトークン（iOS）をBrazeに登録する。
  Future<void> register();
}
