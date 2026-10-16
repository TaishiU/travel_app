import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/misc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/src/shared_preferences_async.dart';
import 'package:travel_app/data/services/local_storage/preferences/permission/notification/android_notification_permission_preferences_service_impl.dart';
import 'package:travel_app/data/services/local_storage/preferences/shared_preferences_service.dart';
import 'package:travel_app/data/services/local_storage/preferences/shared_preferences_service_impl.dart';

import 'android_notification_permission_preferences_service_impl_test.mocks'
    '.dart';

@GenerateMocks([SharedPreferencesService, SharedPreferencesWithCache])
void main() {
  late MockSharedPreferencesService mockSharedPreferencesService;
  late AndroidNotificationPermissionPreferencesServiceImpl serviceImpl;

  const requestedKey = 'notification_permission_requested';
  const permanentlyDeniedKey = 'notification_permission_permanently_denied';

  setUp(() {
    mockSharedPreferencesService = MockSharedPreferencesService();
    serviceImpl = AndroidNotificationPermissionPreferencesServiceImpl(
      generalPreferences: mockSharedPreferencesService,
    );
  });

  group('androidNotificationPermissionPreferencesServiceImplProvider', () {
    late MockSharedPreferencesWithCache mockSharedPreferencesWithCache;
    late ProviderContainer container;

    setUp(() {
      mockSharedPreferencesWithCache = MockSharedPreferencesWithCache();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesServiceImplProvider.overrideWithValue(
            SharedPreferencesServiceImpl(
              sharedPreferences: mockSharedPreferencesWithCache,
            ),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'AndroidNotificationPermissionPreferencesServiceImplのインスタンスを返すこと',
      () {
        final service = container.read(
          androidNotificationPermissionPreferencesServiceImplProvider,
        );
        expect(
          service,
          isA<AndroidNotificationPermissionPreferencesServiceImpl>(),
        );
      },
    );

    test('overridesなしの場合ProviderExceptionがスローされること', () {
      final emptyContainer = ProviderContainer();
      addTearDown(emptyContainer.dispose);

      expect(
        () => emptyContainer.read(
          androidNotificationPermissionPreferencesServiceImplProvider,
        ),
        throwsA(isA<ProviderException>()),
      );
    });
  });

  group('AndroidNotificationPermissionPreferencesServiceImpl', () {
    group('getRequested', () {
      group('正常系', () {
        test('getBoolがtrueを返す場合trueを返すこと', () {
          when(
            mockSharedPreferencesService.getBool(key: requestedKey),
          ).thenReturn(true);

          final result = serviceImpl.getRequested();

          expect(result, isTrue);
          verify(
            mockSharedPreferencesService.getBool(key: requestedKey),
          ).called(1);
        });

        test('getBoolがfalseを返す場合falseを返すこと', () {
          when(
            mockSharedPreferencesService.getBool(key: requestedKey),
          ).thenReturn(false);

          final result = serviceImpl.getRequested();

          expect(result, isFalse);
        });

        test('getBoolがnullを返す場合falseを返すこと', () {
          when(
            mockSharedPreferencesService.getBool(key: requestedKey),
          ).thenReturn(null);

          final result = serviceImpl.getRequested();

          expect(result, isFalse);
        });
      });
    });

    group('setRequested', () {
      group('正常系', () {
        test('setBoolを正しいキーと値で呼び出すこと', () async {
          when(
            mockSharedPreferencesService.setBool(
              key: requestedKey,
              value: true,
            ),
          ).thenAnswer((_) async {});

          await serviceImpl.setRequested(value: true);

          verify(
            mockSharedPreferencesService.setBool(
              key: requestedKey,
              value: true,
            ),
          ).called(1);
        });
      });
    });

    group('getPermanentlyDenied', () {
      group('正常系', () {
        test('getBoolがtrueを返す場合trueを返すこと', () {
          when(
            mockSharedPreferencesService.getBool(key: permanentlyDeniedKey),
          ).thenReturn(true);

          final result = serviceImpl.getPermanentlyDenied();

          expect(result, isTrue);
          verify(
            mockSharedPreferencesService.getBool(key: permanentlyDeniedKey),
          ).called(1);
        });

        test('getBoolがfalseを返す場合falseを返すこと', () {
          when(
            mockSharedPreferencesService.getBool(key: permanentlyDeniedKey),
          ).thenReturn(false);

          final result = serviceImpl.getPermanentlyDenied();

          expect(result, isFalse);
        });

        test('getBoolがnullを返す場合falseを返すこと', () {
          when(
            mockSharedPreferencesService.getBool(key: permanentlyDeniedKey),
          ).thenReturn(null);

          final result = serviceImpl.getPermanentlyDenied();

          expect(result, isFalse);
        });
      });
    });

    group('setPermanentlyDenied', () {
      group('正常系', () {
        test('setBoolを正しいキーと値で呼び出すこと', () async {
          when(
            mockSharedPreferencesService.setBool(
              key: permanentlyDeniedKey,
              value: true,
            ),
          ).thenAnswer((_) async {});

          await serviceImpl.setPermanentlyDenied(value: true);

          verify(
            mockSharedPreferencesService.setBool(
              key: permanentlyDeniedKey,
              value: true,
            ),
          ).called(1);
        });
      });
    });
  });
}
