import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/local_storage/preferences/permission/notification/android_notification_permission_preferences_service.dart';
import 'package:travel_app/data/services/local_storage/preferences/shared_preferences_service.dart';
import 'package:travel_app/data/services/local_storage/preferences/shared_preferences_service_impl.dart';

/// [AndroidNotificationPermissionPreferencesService] の実装クラスを提供する Provider。
final androidNotificationPermissionPreferencesServiceImplProvider =
    Provider<AndroidNotificationPermissionPreferencesService>(
      (ref) => AndroidNotificationPermissionPreferencesServiceImpl(
        generalPreferences: ref.read(sharedPreferencesServiceImplProvider),
      ),
    );

/// [AndroidNotificationPermissionPreferencesService] の実装クラス。
class AndroidNotificationPermissionPreferencesServiceImpl
    implements AndroidNotificationPermissionPreferencesService {
  /// コンストラクタ
  AndroidNotificationPermissionPreferencesServiceImpl({
    required this.generalPreferences,
  });

  /// 通知権限フラグ永続化のための汎用的な SharedPreferences サービス
  final SharedPreferencesService generalPreferences;

  static const _requestedKey = 'notification_permission_requested';
  static const _permanentlyDeniedKey =
      'notification_permission_permanently_denied';

  @override
  bool getRequested() =>
      generalPreferences.getBool(key: _requestedKey) ?? false;

  @override
  Future<void> setRequested({required bool value}) =>
      generalPreferences.setBool(key: _requestedKey, value: value);

  @override
  bool getPermanentlyDenied() =>
      generalPreferences.getBool(key: _permanentlyDeniedKey) ?? false;

  @override
  Future<void> setPermanentlyDenied({required bool value}) =>
      generalPreferences.setBool(key: _permanentlyDeniedKey, value: value);
}
