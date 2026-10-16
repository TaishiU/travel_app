import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/repositories/permission/notification/notification_permission_repository_impl.dart';
import 'package:travel_app/data/services/permission/notification/notification_permission_service.dart';
import 'package:travel_app/data/services/permission/notification/notification_permission_service_impl.dart';
import 'package:travel_app/data/services/permission/notification/stub_notification_permission_service_impl.dart';
import 'package:travel_app/domain/entities/permission/notification/notification_permission_status.dart';
import 'package:travel_app/domain/use_cases/permission/notification/notification_permission_use_case.dart';

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
    /// テスト用の ProviderContainer を生成し、
    /// テスト終了後に自動で dispose されるようにする。
    ProviderContainer buildContainer({
      NotificationPermissionStatus statusResult =
          NotificationPermissionStatus.notDetermined,
      NotificationPermissionStatus requestResult =
          NotificationPermissionStatus.notDetermined,
    }) {
      final container = ProviderContainer(
        overrides: [
          notificationPermissionServiceImplProvider.overrideWithValue(
            StubNotificationPermissionServiceImpl(
              statusResult: statusResult,
              requestResult: requestResult,
            ),
          ),
        ],
      );

      addTearDown(container.dispose);
      return container;
    }

    /// checkStatus / requestPermission 共通のテスト。
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
    });

    group('requestPermission', () {
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
    });
  });
}
