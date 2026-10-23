import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/braze/analytics/braze_analytics_service.dart';
import 'package:travel_app/data/services/braze/analytics/braze_analytics_service_impl.dart';
import 'package:travel_app/data/services/braze/braze_attribute_key.dart';
import 'package:travel_app/data/services/braze/braze_event_key.dart';
import 'package:travel_app/domain/interfaces/notification/notification_analytics_repository.dart';

/// [NotificationAnalyticsRepository] のプロバイダー。
final notificationAnalyticsRepositoryProvider =
    Provider<NotificationAnalyticsRepository>(
      (ref) => NotificationAnalyticsRepositoryImpl(
        analyticsService: ref.read(brazeAnalyticsServiceImplProvider),
      ),
    );

/// [NotificationAnalyticsRepository] の実装クラス。
class NotificationAnalyticsRepositoryImpl
    implements NotificationAnalyticsRepository {
  /// コンストラクタ。
  NotificationAnalyticsRepositoryImpl({required this._analyticsService});

  final BrazeAnalyticsService _analyticsService;

  @override
  void trackLoginCompleted() {
    _analyticsService.logCustomEvent(eventName: BrazeEventKey.loginCompleted);
  }

  @override
  void trackLogoutCompleted() {
    _analyticsService.logCustomEvent(eventName: BrazeEventKey.logoutCompleted);
  }

  @override
  void trackPushPermissionRequested() {
    _analyticsService.logCustomEvent(
      eventName: BrazeEventKey.pushPermissionRequested,
    );
  }

  @override
  void trackPushPermissionGranted() {
    _analyticsService.logCustomEvent(
      eventName: BrazeEventKey.pushPermissionGranted,
    );
  }

  @override
  void updatePushPermissionStatus({required String status}) {
    _analyticsService.setStringAttribute(
      key: BrazeAttributeKey.pushPermissionStatus,
      value: status,
    );
  }
}
