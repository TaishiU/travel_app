import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/local_storage/secure_storage/auth/auth_secure_storage_service.dart';
import 'package:travel_app/data/services/local_storage/secure_storage/secure_storage_service.dart';
import 'package:travel_app/data/services/local_storage/secure_storage/secure_storage_service_impl.dart';

/// AuthSecureStorageServiceImplのプロバイダ
final authSecureStorageServiceImplProvider = Provider<AuthSecureStorageService>(
  (ref) => AuthSecureStorageServiceImpl(
    secureStorage: ref.read(secureStorageServiceImplProvider),
  ),
);

/// [AuthSecureStorageService] の実装クラス。
/// [SecureStorageService] を利用して、認証情報をセキュアに永続化します。
class AuthSecureStorageServiceImpl implements AuthSecureStorageService {
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

  /// 初期化（ストレージからメモリへロード）
  @override
  Future<void> init() async {
    _accessToken = await secureStorage.read(key: _accessTokenKey) ?? '';
    _refreshToken = await secureStorage.read(key: _refreshTokenKey) ?? '';
    _anonymousId = await secureStorage.read(key: _anonymousIdKey) ?? '';
    _userId = await secureStorage.read(key: _userIdKey) ?? '';
  }

  @override
  String getAccessToken() => _accessToken;

  @override
  Future<void> setAccessToken({required String token}) async {
    _accessToken = token;
    await secureStorage.write(key: _accessTokenKey, value: token);
  }

  @override
  String getRefreshToken() => _refreshToken;

  @override
  Future<void> setRefreshToken({required String token}) async {
    _refreshToken = token;
    await secureStorage.write(key: _refreshTokenKey, value: token);
  }

  @override
  String getAnonymousId() => _anonymousId;

  @override
  Future<void> setAnonymousId({required String id}) async {
    _anonymousId = id;
    await secureStorage.write(key: _anonymousIdKey, value: id);
  }

  @override
  String getUserId() => _userId;

  @override
  Future<void> setUserId({required String id}) async {
    _userId = id;
    await secureStorage.write(key: _userIdKey, value: id);
  }

  /// accessToken / refreshToken / userId を削除する。
  /// anonymousId は削除しない（ログアウト後も即時使用するため）。
  @override
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
