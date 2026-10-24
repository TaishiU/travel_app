import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/repositories/auth/auth_repository_impl.dart';
import 'package:travel_app/data/services/braze/analytics/braze_analytics_service_impl.dart';
import 'package:travel_app/data/services/braze/analytics/stub_braze_analytics_service_impl.dart';
import 'package:travel_app/data/services/braze/user_identity/stub_user_identity_service_impl.dart';
import 'package:travel_app/data/services/braze/user_identity/user_identity_service_impl.dart';
import 'package:travel_app/data/services/local_storage/secure_storage/auth/auth_secure_storage_service_impl.dart';
import 'package:travel_app/data/services/local_storage/secure_storage/stub_secure_storage_service.dart';
import 'package:travel_app/data/services/web_api/auth/service_impl.dart';
import 'package:travel_app/data/services/web_api/auth/stub_service_impl.dart';
import 'package:travel_app/domain/use_cases/auth/auth_use_case.dart';
import 'package:travel_app/utils/result.dart';

/// ## 概要
/// [AuthUseCase] → [AuthRepositoryImpl] → [StubAuthApiServiceImpl] /
/// [AuthSecureStorageServiceImpl] → [StubSecureStorageServiceImpl]
/// を実物のまま繋いだ Integration × Small テスト。
///
/// ## スタブ境界
/// ```dart
/// AuthUseCase (real)
///   → AuthRepositoryImpl (real)
///      → StubAuthApiServiceImpl           ← API通信 I/O境界
///      → AuthSecureStorageServiceImpl (real)
///         → StubSecureStorageServiceImpl  ← ストレージ I/O境界
/// ```

const _email = 'test@example.com';
const _password = 'password123';

ProviderContainer buildContainer({bool shouldFail = false}) {
  final stub = StubSecureStorageServiceImpl();
  final container = ProviderContainer(
    overrides: [
      authApiServiceImplProvider.overrideWithValue(
        StubAuthApiServiceImpl(shouldFail: shouldFail),
      ),
      authSecureStorageServiceImplProvider.overrideWithValue(
        AuthSecureStorageServiceImpl(secureStorage: stub),
      ),
      userIdentityServiceImplProvider.overrideWithValue(
        StubUserIdentityServiceImpl(),
      ),
      brazeAnalyticsServiceImplProvider.overrideWithValue(
        StubBrazeAnalyticsServiceImpl(),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('AuthUseCase', () {
    group('login', () {
      group('正常系', () {
        test('pendingDeepLinkなし: SuccessResult(null)を返すこと', () async {
          // Given
          final container = buildContainer();
          final useCase = container.read(authUseCaseProvider);

          // When
          final result = await useCase.login(
            email: _email,
            password: _password,
          );

          // Then
          expect(result, isA<SuccessResult<String?>>());
          expect((result as SuccessResult<String?>).value, isNull);
        });

        test('pendingDeepLinkあり: SuccessResult(url)を返し、取得後クリアされること', () async {
          // Given
          final container = buildContainer();
          container.read(authRepositoryProvider).pendingDeepLink = '/foo';
          final useCase = container.read(authUseCaseProvider);

          // When
          final result = await useCase.login(
            email: _email,
            password: _password,
          );

          // Then
          expect(result, isA<SuccessResult<String?>>());
          expect((result as SuccessResult<String?>).value, equals('/foo'));
          expect(
            container.read(authRepositoryProvider).pendingDeepLink,
            isNull,
          );
        });
      });

      group('異常系', () {
        test('APIエラー: FailureResultを返すこと', () async {
          // Given
          final container = buildContainer(shouldFail: true);
          final useCase = container.read(authUseCaseProvider);

          // When
          final result = await useCase.login(
            email: _email,
            password: _password,
          );

          // Then
          expect(result, isA<FailureResult<String?>>());
        });
      });
    });

    group('register', () {
      group('正常系', () {
        test('SuccessResult(null)を返すこと', () async {
          // Given
          final container = buildContainer();
          final useCase = container.read(authUseCaseProvider);

          // When
          final result = await useCase.register(
            email: _email,
            password: _password,
          );

          // Then
          expect(result, isA<SuccessResult<String?>>());
          expect((result as SuccessResult<String?>).value, isNull);
        });
      });

      group('異常系', () {
        test('APIエラー: FailureResultを返すこと', () async {
          // Given
          final container = buildContainer(shouldFail: true);
          final useCase = container.read(authUseCaseProvider);

          // When
          final result = await useCase.register(
            email: _email,
            password: _password,
          );

          // Then
          expect(result, isA<FailureResult<String?>>());
        });
      });
    });

    group('checkIsLoggedIn', () {
      group('正常系', () {
        test('未ログイン: falseを返すこと', () async {
          // Given
          final container = buildContainer();
          final useCase = container.read(authUseCaseProvider);

          // When
          final result = await useCase.checkIsLoggedIn();

          // Then
          expect(result, isFalse);
        });

        test('ログイン済み: trueを返すこと', () async {
          // Given: login() を実行してログイン済みにする
          final container = buildContainer();
          final useCase = container.read(authUseCaseProvider);
          await useCase.login(email: _email, password: _password);

          // When
          final result = await useCase.checkIsLoggedIn();

          // Then
          expect(result, isTrue);
        });
      });
    });

    group('savePendingDeepLink', () {
      group('正常系', () {
        test('指定したpathがpendingDeepLinkに保存されること', () {
          // Given
          final container = buildContainer();

          // When
          container.read(authUseCaseProvider).savePendingDeepLink(path: '/bar');

          // Then
          expect(
            container.read(authRepositoryProvider).pendingDeepLink,
            equals('/bar'),
          );
        });
      });
    });

    group('logout', () {
      group('正常系', () {
        test('正常に完了すること', () async {
          // Given: ログイン済みにする
          final container = buildContainer();
          final useCase = container.read(authUseCaseProvider);
          await useCase.login(email: _email, password: _password);

          // When / Then: 例外なく完了する
          await expectLater(useCase.logout(), completes);
        });
      });
    });

    group('listenToAuthChanges', () {
      group('正常系', () {
        test('認証状態変化時にコールバックが呼ばれること', () async {
          // Given
          final container = buildContainer();
          final useCase = container.read(authUseCaseProvider);
          var callCount = 0;
          useCase.listenToAuthChanges(onChanged: () => callCount++);

          // When: login → notifyListeners() が発火
          await useCase.login(email: _email, password: _password);

          // Then
          expect(callCount, equals(1));
        });

        test('teardownを呼ぶとリスナーが解除されること', () async {
          // Given
          final container = buildContainer();
          final useCase = container.read(authUseCaseProvider);
          var callCount = 0;
          final teardown = useCase.listenToAuthChanges(
            onChanged: () => callCount++,
          );

          // When: teardown 後に login しても呼ばれない
          teardown();
          await useCase.login(email: _email, password: _password);

          // Then
          expect(callCount, equals(0));
        });
      });
    });
  });
}
