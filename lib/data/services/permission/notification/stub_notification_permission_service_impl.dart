import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/permission/notification/notification_permission_service.dart';
import 'package:travel_app/domain/entities/permission/notification/notification_permission_status.dart';

/// [NotificationPermissionService] のスタブ実装。
/// テスト・ローカル開発時に OS 権限ダイアログを出さずに動作確認できる。
final stubNotificationPermissionServiceImplProvider =
    Provider<NotificationPermissionService>(
      (ref) => const StubNotificationPermissionServiceImpl(),
    );

/// [NotificationPermissionService] のスタブ実装クラス。
class StubNotificationPermissionServiceImpl
    implements NotificationPermissionService {
  /// コンストラクタ
  const StubNotificationPermissionServiceImpl({
    this.statusResult = NotificationPermissionStatus.notDetermined,
    this.requestResult = NotificationPermissionStatus.granted,
  });

  /// [checkStatus] が返す値。デフォルト: [NotificationPermissionStatus.notDetermined]
  final NotificationPermissionStatus statusResult;

  /// [requestPermission] が返す値。デフォルト: [NotificationPermissionStatus.granted]
  final NotificationPermissionStatus requestResult;

  @override
  Future<NotificationPermissionStatus> checkStatus() async => statusResult;

  @override
  Future<NotificationPermissionStatus> requestPermission() async =>
      requestResult;
}
