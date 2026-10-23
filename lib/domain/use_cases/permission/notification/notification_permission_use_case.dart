import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/repositories/notification/notification_analytics_repository_impl.dart';
import 'package:travel_app/data/repositories/permission/notification/notification_permission_repository_impl.dart';
import 'package:travel_app/domain/entities/permission/notification/notification_permission_status.dart';
import 'package:travel_app/domain/interfaces/notification/notification_analytics_repository.dart';
import 'package:travel_app/domain/interfaces/permission/notification/notification_permission_repository.dart';

/// [NotificationPermissionUseCase] のプロバイダー
final notificationPermissionUseCaseProvider =
    Provider<NotificationPermissionUseCase>(
      (ref) => NotificationPermissionUseCase(
        repository: ref.read(notificationPermissionRepositoryProvider),
        analyticsRepository: ref.read(notificationAnalyticsRepositoryProvider),
      ),
    );

/// Push通知権限の取得・要求を担うドメインユースケース。
class NotificationPermissionUseCase {
  /// コンストラクタ
  NotificationPermissionUseCase({
    required this.repository,
    required this.analyticsRepository,
  });

  /// 通知権限リポジトリインターフェース
  final NotificationPermissionRepository repository;

  /// 通知アナリティクスリポジトリインターフェース
  final NotificationAnalyticsRepository analyticsRepository;

  /// 現在の通知権限状態を取得する。
  Future<NotificationPermissionStatus> checkStatus() async {
    final status = await repository.checkStatus();
    analyticsRepository.updatePushPermissionStatus(status: status.name);
    return status;
  }

  /// 通知権限をユーザーに要求し、結果を返す。
  ///
  /// 権限ダイアログを表示する可能性があるため、
  /// 予約確定後など「価値が伝わるタイミング」で呼び出すこと（design_doc.md 参照）。
  Future<NotificationPermissionStatus> requestPermission() async {
    analyticsRepository.trackPushPermissionRequested();
    final status = await repository.requestPermission();
    if (status == NotificationPermissionStatus.granted) {
      analyticsRepository.trackPushPermissionGranted();
    }
    analyticsRepository.updatePushPermissionStatus(status: status.name);
    return status;
  }
}
