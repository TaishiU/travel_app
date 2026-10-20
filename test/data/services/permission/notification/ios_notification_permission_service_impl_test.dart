import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_app/data/services/permission/notification/ios_notification_permission_service_impl.dart';
import 'package:travel_app/domain/entities/permission/notification/notification_permission_status.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Permission.notification.value = 17
  // PermissionStatus: denied=0, granted=1, restricted=2,
  //   permanentlyDenied=4, provisional=5
  const permissionChannel = MethodChannel(
    'flutter.baseflow.com/permissions/methods',
  );

  const notificationPermissionValue = 17;
  const denied = 0;
  const granted = 1;
  const restricted = 2;
  const permanentlyDenied = 4;
  const provisional = 5;

  void mockMethodCallHandler({
    required String method,
    required Object? Function() result,
  }) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (call) async {
          if (call.method == method) {
            return result();
          }
          return null;
        });
  }

  void mockCheckStatus({required int statusCode}) {
    mockMethodCallHandler(
      method: 'checkPermissionStatus',
      result: () => statusCode,
    );
  }

  void mockRequestPermission({required int statusCode}) {
    mockMethodCallHandler(
      method: 'requestPermissions',
      result: () => {notificationPermissionValue: statusCode},
    );
  }

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
  });

  group('IosNotificationPermissionServiceImpl', () {
    late IosNotificationPermissionServiceImpl service;

    setUp(() {
      service = IosNotificationPermissionServiceImpl();
    });

    /// checkStatus の共通テスト処理。
    Future<void> expectCheckStatus({
      required int osStatusCode,
      required NotificationPermissionStatus expected,
    }) async {
      // Given
      mockCheckStatus(statusCode: osStatusCode);

      // When
      final result = await service.checkStatus();

      // Then
      expect(result, equals(expected));
    }

    /// requestPermission の共通テスト処理。
    Future<void> expectRequestPermission({
      required int osStatusCode,
      required NotificationPermissionStatus expected,
    }) async {
      // Given
      mockRequestPermission(statusCode: osStatusCode);

      // When
      final result = await service.requestPermission();

      // Then
      expect(result, equals(expected));
    }

    group('checkStatus', () {
      group('正常系', () {
        test('OS=granted → granted', () async {
          await expectCheckStatus(
            osStatusCode: granted,
            expected: NotificationPermissionStatus.granted,
          );
        });

        test('OS=denied → notDetermined（iOS固有: denied は未要求を意味する）', () async {
          await expectCheckStatus(
            osStatusCode: denied,
            expected: NotificationPermissionStatus.notDetermined,
          );
        });

        test('OS=permanentlyDenied → permanentlyDenied', () async {
          await expectCheckStatus(
            osStatusCode: permanentlyDenied,
            expected: NotificationPermissionStatus.permanentlyDenied,
          );
        });

        test('OS=restricted → permanentlyDenied', () async {
          await expectCheckStatus(
            osStatusCode: restricted,
            expected: NotificationPermissionStatus.permanentlyDenied,
          );
        });

        test(
          'OS=provisional → denied（provisional は braze_005.md で不採用）',
          () async {
            await expectCheckStatus(
              osStatusCode: provisional,
              expected: NotificationPermissionStatus.denied,
            );
          },
        );
      });
    });

    group('requestPermission', () {
      group('正常系', () {
        test('OS=granted → granted', () async {
          await expectRequestPermission(
            osStatusCode: granted,
            expected: NotificationPermissionStatus.granted,
          );
        });

        test('OS=permanentlyDenied → permanentlyDenied', () async {
          await expectRequestPermission(
            osStatusCode: permanentlyDenied,
            expected: NotificationPermissionStatus.permanentlyDenied,
          );
        });
      });
    });
  });
}
