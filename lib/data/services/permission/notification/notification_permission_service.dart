import 'package:travel_app/domain/entities/permission/notification/notification_permission_status.dart';

/// Push通知権限の取得・要求を抽象化するサービスインターフェース。
abstract class NotificationPermissionService {
  /// 現在の通知権限状態を取得する。
  Future<NotificationPermissionStatus> checkStatus();

  /// 通知権限をユーザーに要求し、結果を返す。
  Future<NotificationPermissionStatus> requestPermission();
}
