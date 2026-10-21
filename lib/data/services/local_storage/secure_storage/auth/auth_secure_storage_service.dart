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

  /// 匿名IDを取得します。
  String getAnonymousId();

  /// 匿名IDを保存します。
  Future<void> setAnonymousId({required String id});

  /// ユーザーIDを取得します。
  String getUserId();

  /// ユーザーIDを保存します。
  Future<void> setUserId({required String id});

  /// 認証情報をクリアします。
  /// accessToken / refreshToken / userId を削除します。
  /// anonymousId は削除しません（ログアウト後も即時使用するため）。
  Future<bool> clearAuthData();
}
