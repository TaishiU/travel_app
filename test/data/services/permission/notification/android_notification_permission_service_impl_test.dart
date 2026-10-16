import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_app/data/services/local_storage/preferences/permission/notification/stub_android_notification_permission_preferences_service_impl.dart';
import 'package:travel_app/data/services/permission/notification/android_notification_permission_service_impl.dart';
import 'package:travel_app/domain/entities/permission/notification/notification_permission_status.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Permission.notification.value = 17
  // PermissionStatus: denied=0, granted=1, permanentlyDenied=4
  const permissionChannel = MethodChannel(
    'flutter.baseflow.com/permissions/methods',
  );
  const notificationPermissionValue = 17;
  const denied = 0;
  const granted = 1;
  const permanentlyDenied = 4;

  void mockCheckStatus(int statusCode) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (call) async {
          if (call.method == 'checkPermissionStatus') return statusCode;
          return null;
        });
  }

  void mockRequestPermission(int statusCode) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (call) async {
          if (call.method == 'requestPermissions') {
            return {notificationPermissionValue: statusCode};
          }
          return null;
        });
  }

  const restricted = 2;
  const limited = 3;

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
  });

  group('AndroidNotificationPermissionServiceImpl', () {
    group('checkStatus', () {
      group('正常系', () {
        test('OS=denied, requested=false → notDetermined', () async {
          // Given
          mockCheckStatus(denied);
          final prefsService =
              StubAndroidNotificationPermissionPreferencesServiceImpl();
          final service = AndroidNotificationPermissionServiceImpl(
            preferencesService: prefsService,
          );

          // When
          final result = await service.checkStatus();

          // Then
          expect(result, equals(NotificationPermissionStatus.notDetermined));
        });

        test(
          'OS=denied, requested=true, permanentlyDenied=false → denied',
          () async {
            // Given
            mockCheckStatus(denied);
            final prefsService =
                StubAndroidNotificationPermissionPreferencesServiceImpl(
                  requested: true,
                );
            final service = AndroidNotificationPermissionServiceImpl(
              preferencesService: prefsService,
            );

            // When
            final result = await service.checkStatus();

            // Then
            expect(result, equals(NotificationPermissionStatus.denied));
          },
        );

        test(
          'OS=denied, requested=true, permanentlyDenied=true '
          '→ permanentlyDenied',
          () async {
            // Given
            mockCheckStatus(denied);
            final prefsService =
                StubAndroidNotificationPermissionPreferencesServiceImpl(
                  requested: true,
                  permanentlyDenied: true,
                );
            final service = AndroidNotificationPermissionServiceImpl(
              preferencesService: prefsService,
            );

            // When
            final result = await service.checkStatus();

            // Then
            expect(
              result,
              equals(NotificationPermissionStatus.permanentlyDenied),
            );
          },
        );

        test('OS=permanentlyDenied → permanentlyDenied', () async {
          // Given
          mockCheckStatus(permanentlyDenied);
          final prefsService =
              StubAndroidNotificationPermissionPreferencesServiceImpl();
          final service = AndroidNotificationPermissionServiceImpl(
            preferencesService: prefsService,
          );

          // When
          final result = await service.checkStatus();

          // Then
          expect(
            result,
            equals(NotificationPermissionStatus.permanentlyDenied),
          );
        });

        test('OS=restricted → permanentlyDenied', () async {
          // Given
          mockCheckStatus(restricted);
          final prefsService =
              StubAndroidNotificationPermissionPreferencesServiceImpl();
          final service = AndroidNotificationPermissionServiceImpl(
            preferencesService: prefsService,
          );

          // When
          final result = await service.checkStatus();

          // Then
          expect(
            result,
            equals(NotificationPermissionStatus.permanentlyDenied),
          );
        });

        test('OS=limited（未知ステータス）→ denied', () async {
          // Given
          mockCheckStatus(limited);
          final prefsService =
              StubAndroidNotificationPermissionPreferencesServiceImpl();
          final service = AndroidNotificationPermissionServiceImpl(
            preferencesService: prefsService,
          );

          // When
          final result = await service.checkStatus();

          // Then
          expect(result, equals(NotificationPermissionStatus.denied));
        });

        test(
          'OS=granted, permanentlyDenied=true → granted '
          'かつ permanentlyDenied フラグがリセットされる',
          () async {
            // Given
            mockCheckStatus(granted);
            final prefsService =
                StubAndroidNotificationPermissionPreferencesServiceImpl(
                  requested: true,
                  permanentlyDenied: true,
                );
            final service = AndroidNotificationPermissionServiceImpl(
              preferencesService: prefsService,
            );

            // When
            final result = await service.checkStatus();

            // Then
            expect(result, equals(NotificationPermissionStatus.granted));
            expect(prefsService.getPermanentlyDenied(), isFalse);
          },
        );
      });
    });

    group('requestPermission', () {
      group('正常系', () {
        test(
          'OS=denied → denied かつ requested フラグが true になる',
          () async {
            // Given
            mockRequestPermission(denied);
            final prefsService =
                StubAndroidNotificationPermissionPreferencesServiceImpl();
            final service = AndroidNotificationPermissionServiceImpl(
              preferencesService: prefsService,
            );

            // When
            final result = await service.requestPermission();

            // Then
            expect(result, equals(NotificationPermissionStatus.denied));
            expect(prefsService.getRequested(), isTrue);
          },
        );

        test(
          'OS=permanentlyDenied → permanentlyDenied かつ各フラグが true になる',
          () async {
            // Given
            mockRequestPermission(permanentlyDenied);
            final prefsService =
                StubAndroidNotificationPermissionPreferencesServiceImpl();
            final service = AndroidNotificationPermissionServiceImpl(
              preferencesService: prefsService,
            );

            // When
            final result = await service.requestPermission();

            // Then
            expect(
              result,
              equals(NotificationPermissionStatus.permanentlyDenied),
            );
            expect(prefsService.getRequested(), isTrue);
            expect(prefsService.getPermanentlyDenied(), isTrue);
          },
        );
      });
    });
  });
}
