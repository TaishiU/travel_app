import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:travel_app/data/repositories/notification/notification_analytics_repository_impl.dart';
import 'package:travel_app/data/services/braze/analytics/braze_analytics_service.dart';
import 'package:travel_app/data/services/braze/braze_attribute_key.dart';
import 'package:travel_app/data/services/braze/braze_event_key.dart';

import 'notification_analytics_repository_impl_test.mocks.dart';

@GenerateMocks([BrazeAnalyticsService])
void main() {
  late MockBrazeAnalyticsService mockAnalyticsService;
  late NotificationAnalyticsRepositoryImpl repository;

  setUp(() {
    mockAnalyticsService = MockBrazeAnalyticsService();
    repository = NotificationAnalyticsRepositoryImpl(
      analyticsService: mockAnalyticsService,
    );
  });

  group('NotificationAnalyticsRepositoryImpl', () {
    group('trackLoginCompleted', () {
      group('正常系', () {
        test('loginCompletedイベントが送信されること', () {
          // When
          repository.trackLoginCompleted();

          // Then
          verify(
            mockAnalyticsService.logCustomEvent(
              eventName: BrazeEventKey.loginCompleted,
            ),
          ).called(1);
        });
      });
    });

    group('trackLogoutCompleted', () {
      group('正常系', () {
        test('logoutCompletedイベントが送信されること', () {
          // When
          repository.trackLogoutCompleted();

          // Then
          verify(
            mockAnalyticsService.logCustomEvent(
              eventName: BrazeEventKey.logoutCompleted,
            ),
          ).called(1);
        });
      });
    });

    group('trackPushPermissionRequested', () {
      group('正常系', () {
        test('pushPermissionRequestedイベントが送信されること', () {
          // When
          repository.trackPushPermissionRequested();

          // Then
          verify(
            mockAnalyticsService.logCustomEvent(
              eventName: BrazeEventKey.pushPermissionRequested,
            ),
          ).called(1);
        });
      });
    });

    group('trackPushPermissionGranted', () {
      group('正常系', () {
        test('pushPermissionGrantedイベントが送信されること', () {
          // When
          repository.trackPushPermissionGranted();

          // Then
          verify(
            mockAnalyticsService.logCustomEvent(
              eventName: BrazeEventKey.pushPermissionGranted,
            ),
          ).called(1);
        });
      });
    });

    group('updatePushPermissionStatus', () {
      group('正常系', () {
        test('pushPermissionStatus属性が更新されること', () {
          // When
          repository.updatePushPermissionStatus(status: 'granted');

          // Then
          verify(
            mockAnalyticsService.setStringAttribute(
              key: BrazeAttributeKey.pushPermissionStatus,
              value: 'granted',
            ),
          ).called(1);
        });
      });
    });
  });
}
