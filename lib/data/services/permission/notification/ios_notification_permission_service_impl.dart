import 'package:permission_handler/permission_handler.dart';
import 'package:travel_app/data/services/permission/notification/notification_permission_service.dart';
import 'package:travel_app/domain/entities/permission/notification/notification_permission_status.dart';

/// iOS 向け [NotificationPermissionService] の実装クラス。
/// iOS では `PermissionStatus.denied` が
/// `UNAuthorizationStatus.notDetermined`（未要求）と1対1で対応するため、
/// Android のようなフラグ管理は不要。
class IosNotificationPermissionServiceImpl
    implements NotificationPermissionService {
  @override
  Future<NotificationPermissionStatus> checkStatus() async {
    final status = await Permission.notification.status;
    return _toStatus(status: status);
  }

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    final status = await Permission.notification.request();
    return _toStatus(status: status);
  }

  NotificationPermissionStatus _toStatus({required PermissionStatus status}) =>
      switch (status) {
        PermissionStatus.granted => NotificationPermissionStatus.granted,
        PermissionStatus.permanentlyDenied || PermissionStatus.restricted =>
          NotificationPermissionStatus.permanentlyDenied,
        // iOS: denied = UNAuthorizationStatus.notDetermined（未要求）。
        // ユーザーが拒否すると permanentlyDenied が返るため、denied は常に未要求。
        PermissionStatus.denied => NotificationPermissionStatus.notDetermined,
        // provisional: braze_005.md で不採用 → denied 扱い
        _ => NotificationPermissionStatus.denied,
      };
}
