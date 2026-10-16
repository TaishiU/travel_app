import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/local_storage/preferences/permission/notification/android_notification_permission_preferences_service.dart';

/// [AndroidNotificationPermissionPreferencesService] のスタブ実装を提供する Provider。
final stubAndroidNotificationPermissionPreferencesServiceImplProvider =
    Provider<AndroidNotificationPermissionPreferencesService>(
      (ref) => StubAndroidNotificationPermissionPreferencesServiceImpl(),
    );

/// [AndroidNotificationPermissionPreferencesService] のスタブ実装クラス。
/// テスト時に SharedPreferences を使わずフラグ状態をメモリ上で制御する。
class StubAndroidNotificationPermissionPreferencesServiceImpl
    implements AndroidNotificationPermissionPreferencesService {
  /// コンストラクタ
  ///
  /// [requested]: `request()` 呼び出し済みかの初期値（デフォルト: false）
  /// [permanentlyDenied]: 恒久拒否済みかの初期値（デフォルト: false）
  StubAndroidNotificationPermissionPreferencesServiceImpl({
    this.requested = false,
    this.permanentlyDenied = false,
  });

  /// `request()` 呼び出し済みかどうかのフラグ。
  bool requested;

  /// `request()` が `permanentlyDenied` を返したかどうかのフラグ。
  bool permanentlyDenied;

  @override
  bool getRequested() => requested;

  @override
  Future<void> setRequested({required bool value}) async => requested = value;

  @override
  bool getPermanentlyDenied() => permanentlyDenied;

  @override
  Future<void> setPermanentlyDenied({required bool value}) async =>
      permanentlyDenied = value;
}
