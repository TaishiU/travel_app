import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/local_storage/preferences/permission/notification/android_notification_permission_preferences_service_impl.dart';
import 'package:travel_app/data/services/local_storage/preferences/permission/notification/stub_android_notification_permission_preferences_service_impl.dart';
import 'package:travel_app/data/services/permission/notification/android_notification_permission_service_impl.dart';
import 'package:travel_app/data/services/permission/notification/ios_notification_permission_service_impl.dart';
import 'package:travel_app/data/services/permission/notification/notification_permission_service_impl.dart';

void main() {
  group('notificationPermissionServiceImplProvider', () {
    group('正常系', () {
      test(
        'AndroidNotificationPermissionServiceImplのインスタンスを返すこと',
        () {
          final container = ProviderContainer(
            overrides: [
              androidNotificationPermissionPreferencesServiceImplProvider
                  .overrideWithValue(
                    StubAndroidNotificationPermissionPreferencesServiceImpl(),
                  ),
            ],
          );
          addTearDown(container.dispose);

          final service = container.read(
            notificationPermissionServiceImplProvider,
          );

          expect(service, isA<AndroidNotificationPermissionServiceImpl>());
        },
      );
    });
  });

  group('buildNotificationPermissionService', () {
    final prefsService =
        StubAndroidNotificationPermissionPreferencesServiceImpl();

    group('正常系', () {
      test('isIos=true → IosNotificationPermissionServiceImplを返すこと', () {
        final service = buildNotificationPermissionService(
          preferencesService: prefsService,
          isIos: true,
        );

        expect(service, isA<IosNotificationPermissionServiceImpl>());
      });

      test(
        'isIos=false → AndroidNotificationPermissionServiceImplを返すこと',
        () {
          final service = buildNotificationPermissionService(
            preferencesService: prefsService,
            isIos: false,
          );

          expect(service, isA<AndroidNotificationPermissionServiceImpl>());
        },
      );
    });
  });
}
