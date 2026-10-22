import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/repositories/auth/auth_repository_impl.dart';
import 'package:travel_app/data/services/braze/user_identity/stub_user_identity_service_impl.dart';
import 'package:travel_app/data/services/braze/user_identity/user_identity_service_impl.dart';
import 'package:travel_app/data/services/local_storage/secure_storage/auth/auth_secure_storage_service_impl.dart';
import 'package:travel_app/data/services/local_storage/secure_storage/stub_secure_storage_service.dart';
import 'package:travel_app/data/services/web_api/auth/service_impl.dart';
import 'package:travel_app/data/services/web_api/auth/stub_service_impl.dart';
import 'package:travel_app/domain/use_cases/auth/auth_use_case.dart';
import 'package:travel_app/presentation/login/notifier.dart';
import 'package:travel_app/presentation/login/state.dart';

/// ## 概要
/// [LoginScreenNotifier] → [AuthUseCase] → [AuthRepositoryImpl] →
/// [StubAuthApiServiceImpl] / [AuthSecureStorageServiceImpl] →
/// [StubSecureStorageServiceImpl] を実物のまま繋いだ Integration × Small テスト。
///
/// ## スタブ境界
/// ```dart
/// LoginScreenNotifier (real)
///   → AuthUseCase (real)
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
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('LoginScreenNotifier', () {
    group('login', () {
      group('正常系', () {
        test('ログイン成功: stateがAsyncData(LoginScreenState())に遷移すること', () async {
          // Given
          final container = buildContainer()
            ..listen(loginScreenProvider, (_, _) {});
          await container.read(loginScreenProvider.future);
          final notifier = container.read(loginScreenProvider.notifier);

          // When
          await notifier.login(email: _email, password: _password);

          // Then
          expect(
            container.read(loginScreenProvider),
            equals(const AsyncData(LoginScreenState())),
          );
        });

        test('二重呼び出し防止: isLoading: true の状態で再呼び出しが即リターンすること', () async {
          // Given
          final container = buildContainer()
            ..listen(loginScreenProvider, (_, _) {});
          await container.read(loginScreenProvider.future);
          final notifier = container.read(loginScreenProvider.notifier);

          // When: 1回目をawaitせず開始（同期的にisLoading: trueがセットされる）
          final firstCall = notifier.login(email: _email, password: _password);

          // Then: 2回目は即リターンし、stateはisLoading: trueのまま
          await notifier.login(email: _email, password: _password);
          expect(
            container.read(loginScreenProvider),
            equals(const AsyncData(LoginScreenState(isLoading: true))),
          );

          await firstCall;
        });
      });

      group('異常系', () {
        test('ログイン失敗: stateがAsyncErrorに遷移すること', () async {
          // Given
          final container = buildContainer(shouldFail: true)
            ..listen(loginScreenProvider, (_, _) {});
          await container.read(loginScreenProvider.future);
          final notifier = container.read(loginScreenProvider.notifier);

          // When
          await notifier.login(email: _email, password: _password);

          // Then
          expect(
            container.read(loginScreenProvider),
            isA<AsyncError<LoginScreenState>>(),
          );
        });
      });
    });

    group('register', () {
      group('正常系', () {
        test('登録成功: stateがAsyncData(LoginScreenState())に遷移すること', () async {
          // Given
          final container = buildContainer()
            ..listen(loginScreenProvider, (_, _) {});
          await container.read(loginScreenProvider.future);
          final notifier = container.read(loginScreenProvider.notifier);

          // When
          await notifier.register(email: _email, password: _password);

          // Then
          expect(
            container.read(loginScreenProvider),
            equals(const AsyncData(LoginScreenState())),
          );
        });
      });

      group('異常系', () {
        test('登録失敗: stateがAsyncErrorに遷移すること', () async {
          // Given
          final container = buildContainer(shouldFail: true)
            ..listen(loginScreenProvider, (_, _) {});
          await container.read(loginScreenProvider.future);
          final notifier = container.read(loginScreenProvider.notifier);

          // When
          await notifier.register(email: _email, password: _password);

          // Then
          expect(
            container.read(loginScreenProvider),
            isA<AsyncError<LoginScreenState>>(),
          );
        });
      });
    });
  });
}
