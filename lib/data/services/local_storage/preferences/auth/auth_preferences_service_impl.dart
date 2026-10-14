import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/local_storage/preferences/auth/auth_preferences_service.dart';
import 'package:travel_app/data/services/local_storage/preferences/shared_preferences_service.dart';
import 'package:travel_app/data/services/local_storage/preferences/shared_preferences_service_impl.dart';

/// プロバイダ
final authPreferencesServiceImplProvider = Provider<AuthPreferencesServiceImpl>(
  (ref) => AuthPreferencesServiceImpl(
    generalPreferences: ref.read(sharedPreferencesServiceImplProvider),
  ),
);

/// [AuthPreferencesService] の実装クラスです。
/// [SharedPreferencesService] を利用して、認証情報（アクセストークン、リフレッシュトークンなど）を永続化します。
class AuthPreferencesServiceImpl implements AuthPreferencesService {
  /// コンストラクタ
  AuthPreferencesServiceImpl({required this.generalPreferences});

  /// 認証情報永続化のための汎用的なSharedPreferencesサービス
  final SharedPreferencesService generalPreferences;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  @override
  String getAccessToken() {
    return generalPreferences.getString(key: _accessTokenKey) ?? '';
  }

  @override
  Future<void> setAccessToken({required String token}) async {
    await generalPreferences.setString(key: _accessTokenKey, value: token);
  }

  @override
  String getRefreshToken() {
    return generalPreferences.getString(key: _refreshTokenKey) ?? '';
  }

  @override
  Future<void> setRefreshToken({required String token}) async {
    await generalPreferences.setString(key: _refreshTokenKey, value: token);
  }

  @override
  Future<bool> clearAuthData() async {
    await generalPreferences.remove(key: _accessTokenKey);
    await generalPreferences.remove(key: _refreshTokenKey);
    return true;
  }
}
