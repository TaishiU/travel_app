import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:travel_app/data/repositories/push_token/push_token_repository_impl.dart';
import 'package:travel_app/data/services/braze/push_token/push_token_service.dart';
import 'package:travel_app/data/services/braze/push_token/push_token_service_impl.dart';
import 'package:travel_app/data/services/braze/push_token/stub_push_token_service_impl.dart';
import 'package:travel_app/domain/interfaces/push_token/push_token_repository.dart';

import 'push_token_repository_impl_test.mocks.dart';

@GenerateMocks([PushTokenService])
void main() {
  late MockPushTokenService mockPushTokenService;
  late PushTokenRepositoryImpl repository;

  setUp(() {
    mockPushTokenService = MockPushTokenService();
    repository = PushTokenRepositoryImpl(
      pushTokenService: mockPushTokenService,
    );
  });

  group('pushTokenRepositoryProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          pushTokenServiceImplProvider.overrideWith(
            (_) => StubPushTokenServiceImpl(),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('PushTokenRepositoryのインスタンスを返すこと', () {
      final result = container.read(pushTokenRepositoryProvider);
      expect(result, isA<PushTokenRepository>());
    });
  });

  group('register', () {
    test('正常系: PushTokenService.register()に委譲すること', () async {
      when(mockPushTokenService.register()).thenAnswer((_) async {});

      await repository.register();

      verify(mockPushTokenService.register()).called(1);
    });

    test('異常系: PushTokenService.register()が例外をスローした場合に伝播すること', () async {
      when(
        mockPushTokenService.register(),
      ).thenAnswer((_) async => throw Exception('register failed'));

      await expectLater(repository.register(), throwsException);
    });
  });
}
