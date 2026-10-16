import 'package:permission_handler/permission_handler.dart';
import 'package:travel_app/data/services/local_storage/preferences/permission/notification/android_notification_permission_preferences_service.dart';
import 'package:travel_app/data/services/permission/notification/notification_permission_service.dart';
import 'package:travel_app/domain/entities/permission/notification/notification_permission_status.dart';

/// Android 向け [NotificationPermissionService] の実装クラス。
/// `permission_handler` の OS 権限 API と
/// [AndroidNotificationPermissionPreferencesService] のフラグ管理を組み合わせて
/// Android の通知権限3状態（未要求 / 1回目拒否 / 恒久拒否）を区別する。
class AndroidNotificationPermissionServiceImpl
    implements NotificationPermissionService {
  /// コンストラクタ
  AndroidNotificationPermissionServiceImpl({
    required this.preferencesService,
  });

  /// Android 権限フラグ永続化サービス
  final AndroidNotificationPermissionPreferencesService preferencesService;

  @override
  Future<NotificationPermissionStatus> checkStatus() async {
    final status = await Permission.notification.status;
    return switch (status) {
      PermissionStatus.granted => _handleGranted(),
      PermissionStatus.denied => Future.value(_handleDenied()),
      PermissionStatus.permanentlyDenied || PermissionStatus.restricted =>
        Future.value(NotificationPermissionStatus.permanentlyDenied),
      _ => Future.value(NotificationPermissionStatus.denied),
    };
  }

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    // ダイアログ表示前にフラグを立てる。
    // request() 後に立てると OS がダイアログを表示しなかった場合に
    // フラグが立たず、次回 checkStatus() で notDetermined が返り続ける。
    await preferencesService.setRequested(value: true);
    final status = await Permission.notification.request();
    if (status == PermissionStatus.permanentlyDenied) {
      await preferencesService.setPermanentlyDenied(value: true);
      return NotificationPermissionStatus.permanentlyDenied;
    }
    return _toStatus(status: status);
  }

  Future<NotificationPermissionStatus> _handleGranted() async {
    // ユーザーが設定から再許可した可能性があるため permanentlyDenied フラグをリセット。
    await preferencesService.setPermanentlyDenied(value: false);
    return NotificationPermissionStatus.granted;
  }

  NotificationPermissionStatus _handleDenied() {
    // Android 13+: .status は未要求 / 1回目拒否 / 恒久拒否をすべて denied で返す。
    // 2つの SharedPreferences フラグで3状態を区別する。
    if (!preferencesService.getRequested()) {
      return NotificationPermissionStatus.notDetermined;
    }
    return preferencesService.getPermanentlyDenied()
        ? NotificationPermissionStatus.permanentlyDenied
        : NotificationPermissionStatus.denied;
  }

  NotificationPermissionStatus _toStatus({required PermissionStatus status}) =>
      switch (status) {
        PermissionStatus.granted => NotificationPermissionStatus.granted,
        PermissionStatus.permanentlyDenied || PermissionStatus.restricted =>
          NotificationPermissionStatus.permanentlyDenied,
        _ => NotificationPermissionStatus.denied,
      };
}
