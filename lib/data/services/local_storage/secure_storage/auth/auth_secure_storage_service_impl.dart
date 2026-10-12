import 'package:travel_app/data/services/local_storage/secure_storage/auth/auth_secure_storage_service.dart';
import 'package:travel_app/data/services/local_storage/secure_storage/secure_storage_service.dart';
import 'package:travel_app/data/services/local_storage/secure_storage/secure_storage_service_impl.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

  String _accessToken = '';
  String _refreshToken = '';

  /// 初期化（ストレージからメモリへロード）
  @override
  Future<void> init() async {
    _accessToken = await secureStorage.read(key: _accessTokenKey) ?? '';
    _refreshToken = await secureStorage.read(key: _refreshTokenKey) ?? '';
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
  Future<bool> clearAuthData() async {
    _accessToken = '';
    _refreshToken = '';
    await secureStorage.delete(key: _accessTokenKey);
    await secureStorage.delete(key: _refreshTokenKey);
    return true;
  }
}
