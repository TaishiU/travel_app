import 'package:travel_app/data/services/local_storage/preferences/settings/settings_preferences_service.dart';
import 'package:travel_app/data/services/local_storage/preferences/shared_preferences_service.dart';
import 'package:travel_app/data/services/local_storage/preferences/shared_preferences_service_impl.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// プロバイダ
final settingsPreferencesServiceImplProvider =
    Provider<SettingsPreferencesServiceImpl>(
      (ref) => SettingsPreferencesServiceImpl(
        generalPreferences: ref.read(sharedPreferencesServiceImplProvider),
      ),
    );

/// [SettingsPreferencesService] の実装クラス。
/// [SharedPreferencesService] を利用して、アプリケーション設定（テーマ、言語、通知など）を永続化します。
class SettingsPreferencesServiceImpl implements SettingsPreferencesService {
  /// コンストラクタ
  SettingsPreferencesServiceImpl({required this.generalPreferences});

  /// 認証情報永続化のための汎用的なSharedPreferencesサービス
  final SharedPreferencesService generalPreferences;

  static const String _appThemeKey = 'app_theme';
  static const String _languageCodeKey = 'language_code';
  static const String _agreedToTermsKey = 'agreed_to_terms';
  static const String _notificationEnabledKey = 'notification_enabled';
  static const String _lastLoginDateKey = 'last_login_date';

  @override
  String getAppTheme() {
    return generalPreferences.getString(key: _appThemeKey) ?? '';
  }

  @override
  Future<void> setAppTheme({required String theme}) async {
    await generalPreferences.setString(key: _appThemeKey, value: theme);
  }

  @override
  String getLanguageCode() {
    return generalPreferences.getString(key: _languageCodeKey) ?? '';
  }

  @override
  Future<void> setLanguageCode({required String code}) async {
    await generalPreferences.setString(key: _languageCodeKey, value: code);
  }

  @override
  bool getAgreedToTerms() {
    return generalPreferences.getBool(key: _agreedToTermsKey) ?? false;
  }

  @override
  Future<void> setAgreedToTerms({required bool agreed}) async {
    await generalPreferences.setBool(key: _agreedToTermsKey, value: agreed);
  }

  @override
  bool getNotificationEnabled() {
    return generalPreferences.getBool(key: _notificationEnabledKey) ?? false;
  }

  @override
  Future<void> setNotificationEnabled({required bool enabled}) async {
    await generalPreferences.setBool(
      key: _notificationEnabledKey,
      value: enabled,
    );
  }

  @override
  String getLastLoginDate() {
    return generalPreferences.getString(key: _lastLoginDateKey) ?? '';
  }

  @override
  Future<void> setLastLoginDate({required String date}) async {
    await generalPreferences.setString(key: _lastLoginDateKey, value: date);
  }

  @override
  Future<bool> clearSettingsData() async {
    await generalPreferences.remove(key: _appThemeKey);
    await generalPreferences.remove(key: _agreedToTermsKey);
    await generalPreferences.remove(key: _notificationEnabledKey);
    await generalPreferences.remove(key: _lastLoginDateKey);
    return true;
  }
}
