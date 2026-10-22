import 'package:braze_plugin/braze_plugin.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:travel_app/data/services/braze/braze_plugin_provider.dart';
import 'package:travel_app/data/services/braze/user_identity/user_identity_service.dart';
import 'package:travel_app/data/services/braze/user_identity/user_identity_service_impl.dart';

import 'user_identity_service_impl_test.mocks.dart';

@GenerateMocks([BrazePlugin])
void main() {
  late MockBrazePlugin mockBrazePlugin;

  setUp(() {
    mockBrazePlugin = MockBrazePlugin();
  });

  group('userIdentityServiceImplProvider', () {
    group('正常系', () {
      test('UserIdentityServiceのインスタンスを返すこと', () {
        // Given
        final container = ProviderContainer(
          overrides: [brazePluginProvider.overrideWithValue(mockBrazePlugin)],
        );
        addTearDown(container.dispose);

        // When / Then
        expect(
          container.read(userIdentityServiceImplProvider),
          isA<UserIdentityService>(),
        );
      });
    });
  });

  group('UserIdentityServiceImpl', () {
    late UserIdentityServiceImpl service;

    setUp(() {
      service = UserIdentityServiceImpl(brazePlugin: mockBrazePlugin);
    });

    group('changeUser', () {
      group('正常系', () {
        test('brazePlugin.changeUser()が呼ばれること', () {
          // Given
          const userId = 'user123';

          // When
          service.changeUser(userId: userId);

          // Then
          verify(mockBrazePlugin.changeUser(userId)).called(1);
        });
      });
    });

    group('setStringCustomAttribute', () {
      group('正常系', () {
        test('brazePlugin.setStringCustomUserAttribute()が呼ばれること', () {
          // Given
          const key = 'anonymous_id';
          const value = 'anon-123';

          // When
          service.setStringCustomAttribute(key: key, value: value);

          // Then
          verify(
            mockBrazePlugin.setStringCustomUserAttribute(key, value),
          ).called(1);
        });
      });
    });

    group('logoutSession', () {
      group('正常系', () {
        test('brazePlugin.logout()が呼ばれること', () async {
          // Given / When
          await service.logoutSession();

          // Then
          verify(mockBrazePlugin.logout()).called(1);
        });
      });
    });
  });
}
