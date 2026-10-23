import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/repositories/notification/notification_analytics_repository_impl.dart';
import 'package:travel_app/data/repositories/permission/notification/notification_permission_repository_impl.dart';
import 'package:travel_app/data/services/permission/notification/notification_permission_service.dart';
import 'package:travel_app/data/services/permission/notification/notification_permission_service_impl.dart';
import 'package:travel_app/data/services/permission/notification/stub_notification_permission_service_impl.dart';
import 'package:travel_app/domain/entities/permission/notification/notification_permission_status.dart';
import 'package:travel_app/domain/interfaces/notification/notification_analytics_repository.dart';
import 'package:travel_app/domain/use_cases/permission/notification/notification_permission_use_case.dart';

class SpyNotificationAnalyticsRepositoryImpl
    implements NotificationAnalyticsRepository {
  int trackPushPermissionRequestedCount = 0;
  int trackPushPermissionGrantedCount = 0;
  String? lastPushPermissionStatus;

  @override
  void trackLoginCompleted() {}

  @override
  void trackLogoutCompleted() {}

  @override
  void trackPushPermissionRequested() => trackPushPermissionRequestedCount++;

  @override
  void trackPushPermissionGranted() => trackPushPermissionGrantedCount++;

  @override
  void updatePushPermissionStatus({required String status}) =>
      lastPushPermissionStatus = status;
}

/// ## 概要
/// [NotificationPermissionUseCase] → [NotificationPermissionRepositoryImpl]
/// → [StubNotificationPermissionServiceImpl] を実物のまま繋いだ
/// Integration × Small テスト。
/// I/O 境界（[NotificationPermissionService]）のみスタブに差し替え、
/// その上の UseCase・Repository・Interface は本物を実行する。
///
/// ## 目的
/// Unit テスト（各層の単体テスト）では「各レイヤーが個別に正しいこと」を確認できるが、
/// 「繋げても正しいこと」は確認できない。
/// このテストは UseCase → Repository の委譲経路が正しく配線されているかを
/// 4状態（granted / notDetermined / denied / permanentlyDenied）× 2メソッド で保証する。
///
/// ## スタブ境界
/// ```dart
/// UseCase (real)
///   → RepositoryImpl (real)
///   → StubNotificationPermissionServiceImpl  ← ここだけスタブ
/// ```
void main() {
  group('NotificationPermissionUseCase', () {
    ProviderContainer buildContainer({
      NotificationPermissionStatus statusResult =
          NotificationPermissionStatus.notDetermined,
      NotificationPermissionStatus requestResult =
          NotificationPermissionStatus.notDetermined,
      SpyNotificationAnalyticsRepositoryImpl? spy,
    }) {
      final container = ProviderContainer(
        overrides: [
          notificationPermissionServiceImplProvider.overrideWithValue(
            StubNotificationPermissionServiceImpl(
              statusResult: statusResult,
              requestResult: requestResult,
            ),
          ),
          notificationAnalyticsRepositoryProvider.overrideWithValue(
            spy ?? SpyNotificationAnalyticsRepositoryImpl(),
          ),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    /// checkStatus / requestPermission 共通の戻り値テスト。
    Future<void> expectPermissionResult({
      required Future<NotificationPermissionStatus> Function(
        NotificationPermissionUseCase useCase,
      )
      act,
      required NotificationPermissionStatus stubResult,
    }) async {
      final container = buildContainer(
        statusResult: stubResult,
        requestResult: stubResult,
      );

      final result = await act(
        container.read(notificationPermissionUseCaseProvider),
      );

      expect(result, equals(stubResult));
    }

    group('checkStatus', () {
      group('正常系', () {
        test('granted → granted', () async {
          await expectPermissionResult(
            act: (useCase) => useCase.checkStatus(),
            stubResult: NotificationPermissionStatus.granted,
          );
        });

        test('notDetermined → notDetermined', () async {
          await expectPermissionResult(
            act: (useCase) => useCase.checkStatus(),
            stubResult: NotificationPermissionStatus.notDetermined,
          );
        });

        test('denied → denied', () async {
          await expectPermissionResult(
            act: (useCase) => useCase.checkStatus(),
            stubResult: NotificationPermissionStatus.denied,
          );
        });

        test('permanentlyDenied → permanentlyDenied', () async {
          await expectPermissionResult(
            act: (useCase) => useCase.checkStatus(),
            stubResult: NotificationPermissionStatus.permanentlyDenied,
          );
        });

        test('granted → updatePushPermissionStatus("granted") が呼ばれる', () async {
          final spy = SpyNotificationAnalyticsRepositoryImpl();
          final container = buildContainer(
            statusResult: NotificationPermissionStatus.granted,
            spy: spy,
          );
          await container
              .read(notificationPermissionUseCaseProvider)
              .checkStatus();
          expect(spy.lastPushPermissionStatus, equals('granted'));
        });

        test('denied → updatePushPermissionStatus("denied") が呼ばれる', () async {
          final spy = SpyNotificationAnalyticsRepositoryImpl();
          final container = buildContainer(
            statusResult: NotificationPermissionStatus.denied,
            spy: spy,
          );
          await container
              .read(notificationPermissionUseCaseProvider)
              .checkStatus();
          expect(spy.lastPushPermissionStatus, equals('denied'));
        });
      });
    });

    group('requestPermission', () {
      group('正常系', () {
        test('granted → granted', () async {
          await expectPermissionResult(
            act: (useCase) => useCase.requestPermission(),
            stubResult: NotificationPermissionStatus.granted,
          );
        });

        test('notDetermined → notDetermined', () async {
          await expectPermissionResult(
            act: (useCase) => useCase.requestPermission(),
            stubResult: NotificationPermissionStatus.notDetermined,
          );
        });

        test('denied → denied', () async {
          await expectPermissionResult(
            act: (useCase) => useCase.requestPermission(),
            stubResult: NotificationPermissionStatus.denied,
          );
        });

        test('permanentlyDenied → permanentlyDenied', () async {
          await expectPermissionResult(
            act: (useCase) => useCase.requestPermission(),
            stubResult: NotificationPermissionStatus.permanentlyDenied,
          );
        });

        test('trackPushPermissionRequested が必ず1回呼ばれる', () async {
          final spy = SpyNotificationAnalyticsRepositoryImpl();
          final container = buildContainer(
            requestResult: NotificationPermissionStatus.denied,
            spy: spy,
          );
          await container
              .read(notificationPermissionUseCaseProvider)
              .requestPermission();
          expect(spy.trackPushPermissionRequestedCount, equals(1));
        });

        test('granted → trackPushPermissionGranted が1回呼ばれる', () async {
          final spy = SpyNotificationAnalyticsRepositoryImpl();
          final container = buildContainer(
            requestResult: NotificationPermissionStatus.granted,
            spy: spy,
          );
          await container
              .read(notificationPermissionUseCaseProvider)
              .requestPermission();
          expect(spy.trackPushPermissionGrantedCount, equals(1));
        });

        test('denied → trackPushPermissionGranted は呼ばれない', () async {
          final spy = SpyNotificationAnalyticsRepositoryImpl();
          final container = buildContainer(
            requestResult: NotificationPermissionStatus.denied,
            spy: spy,
          );
          await container
              .read(notificationPermissionUseCaseProvider)
              .requestPermission();
          expect(spy.trackPushPermissionGrantedCount, equals(0));
        });

        test('permanentlyDenied → trackPushPermissionGranted は呼ばれない', () async {
          final spy = SpyNotificationAnalyticsRepositoryImpl();
          final container = buildContainer(
            requestResult: NotificationPermissionStatus.permanentlyDenied,
            spy: spy,
          );
          await container
              .read(notificationPermissionUseCaseProvider)
              .requestPermission();
          expect(spy.trackPushPermissionGrantedCount, equals(0));
        });

        test('granted → updatePushPermissionStatus("granted") が呼ばれる', () async {
          final spy = SpyNotificationAnalyticsRepositoryImpl();
          final container = buildContainer(
            requestResult: NotificationPermissionStatus.granted,
            spy: spy,
          );
          await container
              .read(notificationPermissionUseCaseProvider)
              .requestPermission();
          expect(spy.lastPushPermissionStatus, equals('granted'));
        });
      });
    });
  });
}
