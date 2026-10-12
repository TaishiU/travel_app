/// 認証関連の永続化サービスを抽象化するインターフェースです。
/// アクセストークンやリフレッシュトークンなどの認証情報を安全に管理するための契約を定義します。
abstract class AuthPreferencesService {
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
