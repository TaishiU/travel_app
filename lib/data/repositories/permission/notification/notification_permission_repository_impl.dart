import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/permission/notification/notification_permission_service.dart';
import 'package:travel_app/data/services/permission/notification/notification_permission_service_impl.dart';
import 'package:travel_app/domain/entities/permission/notification/notification_permission_status.dart';
import 'package:travel_app/domain/interfaces/permission/notification/notification_permission_repository.dart';

/// [NotificationPermissionRepository] のプロバイダー
final notificationPermissionRepositoryProvider =
    Provider<NotificationPermissionRepository>(
      (ref) => NotificationPermissionRepositoryImpl(
        service: ref.read(notificationPermissionServiceImplProvider),
      ),
    );

/// [NotificationPermissionRepository] の実装クラス。
/// UseCase からの権限操作を [NotificationPermissionService] に委譲する。
class NotificationPermissionRepositoryImpl
    implements NotificationPermissionRepository {
  /// コンストラクタ
  NotificationPermissionRepositoryImpl({required this.service});

  /// 通知権限サービスインターフェース
  final NotificationPermissionService service;

  @override
  Future<NotificationPermissionStatus> checkStatus() => service.checkStatus();

  @override
  Future<NotificationPermissionStatus> requestPermission() =>
      service.requestPermission();
}
