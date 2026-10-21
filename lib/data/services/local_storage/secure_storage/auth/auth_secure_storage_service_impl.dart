import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/local_storage/secure_storage/secure_storage_service.dart';
import 'package:travel_app/data/services/local_storage/secure_storage/secure_storage_service_impl.dart';

/// AuthSecureStorageServiceImplのプロバイダ
final authSecureStorageServiceImplProvider =
    Provider<AuthSecureStorageServiceImpl>(
      (ref) => AuthSecureStorageServiceImpl(
        secureStorage: ref.read(secureStorageServiceImplProvider),
      ),
    );

/// [SecureStorageService] を利用して、認証情報をセキュアに永続化するサービス。
class AuthSecureStorageServiceImpl {
  /// コンストラクタ
  AuthSecureStorageServiceImpl({required this.secureStorage});

  /// セキュアなデータ保存のためのサービス
  final SecureStorageService secureStorage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _anonymousIdKey = 'anonymous_id';
  static const String _userIdKey = 'user_id';

  String _accessToken = '';
  String _refreshToken = '';
  String _anonymousId = '';
  String _userId = '';

  /// ストレージからデータをロードして初期化します。
  Future<void> init() async {
    _accessToken = await secureStorage.read(key: _accessTokenKey) ?? '';
    _refreshToken = await secureStorage.read(key: _refreshTokenKey) ?? '';
    _anonymousId = await secureStorage.read(key: _anonymousIdKey) ?? '';
    _userId = await secureStorage.read(key: _userIdKey) ?? '';
  }

  /// アクセストークンを取得します。
  String getAccessToken() => _accessToken;

  /// アクセストークンを保存します。
  Future<void> setAccessToken({required String token}) async {
    _accessToken = token;
    await secureStorage.write(key: _accessTokenKey, value: token);
  }

  /// リフレッシュトークンを取得します。
  String getRefreshToken() => _refreshToken;

  /// リフレッシュトークンを保存します。
  Future<void> setRefreshToken({required String token}) async {
    _refreshToken = token;
    await secureStorage.write(key: _refreshTokenKey, value: token);
  }

  /// 匿名IDを取得します。
  String getAnonymousId() => _anonymousId;

  /// 匿名IDを保存します。
  Future<void> setAnonymousId({required String id}) async {
    _anonymousId = id;
    await secureStorage.write(key: _anonymousIdKey, value: id);
  }

  /// ユーザーIDを取得します。
  String getUserId() => _userId;

  /// ユーザーIDを保存します。
  Future<void> setUserId({required String id}) async {
    _userId = id;
    await secureStorage.write(key: _userIdKey, value: id);
  }

  /// accessToken / refreshToken / userId を削除する。
  /// anonymousId は削除しない（ログアウト後も即時使用するため）。
  Future<bool> clearAuthData() async {
    _accessToken = '';
    _refreshToken = '';
    _userId = '';
    await secureStorage.delete(key: _accessTokenKey);
    await secureStorage.delete(key: _refreshTokenKey);
    await secureStorage.delete(key: _userIdKey);
    return true;
  }
}
