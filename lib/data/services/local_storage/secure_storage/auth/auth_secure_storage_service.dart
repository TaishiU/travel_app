/// 認証関連のセキュアな永続化サービスを抽象化するインターフェースです。
abstract class AuthSecureStorageService {
  /// ストレージからデータをロードして初期化します。
  Future<void> init();

  /// アクセストークンを取得します。
  String getAccessToken();

  /// アクセストークンを保存します。
  Future<void> setAccessToken({required String token});

  /// リフレッシュトークンを取得します。
  String getRefreshToken();

  /// リフレッシュトークンを保存します。
  Future<void> setRefreshToken({required String token});

  /// 認証情報をクリアします。
  Future<bool> clearAuthData();
}
