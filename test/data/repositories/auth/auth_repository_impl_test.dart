import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/repositories/auth/auth_repository_impl.dart';
import 'package:travel_app/data/services/braze/user_identity/stub_user_identity_service_impl.dart';
import 'package:travel_app/data/services/braze/user_identity/user_identity_service_impl.dart';
import 'package:travel_app/data/services/local_storage/secure_storage/auth/auth_secure_storage_service_impl.dart';
import 'package:travel_app/data/services/local_storage/secure_storage/stub_secure_storage_service.dart';
import 'package:travel_app/data/services/web_api/auth/dto.dart';
import 'package:travel_app/data/services/web_api/auth/service.dart';
import 'package:travel_app/data/services/web_api/auth/service_impl.dart';
import 'package:travel_app/data/services/web_api/auth/stub_service_impl.dart';
import 'package:travel_app/domain/entities/user/user.dart';
import 'package:travel_app/domain/errors/app_error.dart';
import 'package:travel_app/domain/interfaces/auth/auth_repository.dart';
import 'package:travel_app/utils/result.dart';

// accessToken: null を返すスタブ（_saveTokens 検証用）
class _NullAccessTokenAuthApiService implements AuthApiService {
  @override
  Future<Result<TokenResponseDto>> login({
    required String email,
    required String password,
  }) async => const SuccessResult(TokenResponseDto(refreshToken: 'refresh'));

  @override
  Future<Result<TokenResponseDto>> register({
    required String email,
    required String password,
    String? displayName,
  }) async => const SuccessResult(TokenResponseDto(refreshToken: 'refresh'));

  @override
  Future<Result<void>> logout({required String refreshToken}) async =>
      const SuccessResult(null);

  @override
  Future<Result<UserDto>> me() async =>
      const SuccessResult(UserDto(id: '1', email: 'test@example.com'));
}

// refreshToken: null を返すスタブ（_saveTokens 検証用）
class _NullRefreshTokenAuthApiService implements AuthApiService {
  @override
  Future<Result<TokenResponseDto>> login({
    required String email,
    required String password,
  }) async => const SuccessResult(TokenResponseDto(accessToken: 'access'));

  @override
  Future<Result<TokenResponseDto>> register({
    required String email,
    required String password,
    String? displayName,
  }) async => const SuccessResult(TokenResponseDto(accessToken: 'access'));

  @override
  Future<Result<void>> logout({required String refreshToken}) async =>
      const SuccessResult(null);

  @override
  Future<Result<UserDto>> me() async =>
      const SuccessResult(UserDto(id: '1', email: 'test@example.com'));
}

/// ## 概要
/// [AuthRepositoryImpl] → [StubAuthApiServiceImpl] /
/// [AuthSecureStorageServiceImpl] → [StubSecureStorageServiceImpl]
/// を実物のまま繋いだ Unit × Small テスト。
///
/// ## スタブ境界
/// ```dart
/// AuthRepositoryImpl (real)
///   → StubAuthApiServiceImpl           ← API通信 I/O境界
///   → AuthSecureStorageServiceImpl (real)
///      → StubSecureStorageServiceImpl  ← ストレージ I/O境界
/// ```

const _testAnonymousId = 'test-anonymous-id';
const _email = 'test@example.com';
const _password = 'password123';

void main() {
  late StubSecureStorageServiceImpl stub;
  late AuthSecureStorageServiceImpl authStorage;
  late AuthRepositoryImpl repository;

  setUp(() {
    stub = StubSecureStorageServiceImpl();
    authStorage = AuthSecureStorageServiceImpl(secureStorage: stub);
    repository = AuthRepositoryImpl(
      authApiService: StubAuthApiServiceImpl(),
      authSecureStorageService: authStorage,
      idGenerator: () => _testAnonymousId,
      userIdentityService: StubUserIdentityServiceImpl(),
    );
  });

  group('AuthRepositoryImpl', () {
    group('authRepositoryProvider', () {
      late ProviderContainer container;

      setUp(() {
        container = ProviderContainer(
          overrides: [
            authApiServiceImplProvider.overrideWithValue(
              StubAuthApiServiceImpl(),
            ),
            authSecureStorageServiceImplProvider.overrideWithValue(
              AuthSecureStorageServiceImpl(
                secureStorage: StubSecureStorageServiceImpl(),
              ),
            ),
            userIdentityServiceImplProvider.overrideWithValue(
              StubUserIdentityServiceImpl(),
            ),
          ],
        );
      });

      tearDown(() => container.dispose());

      test('authRepositoryProviderはAuthRepositoryのインスタンスを返すこと', () {
        expect(container.read(authRepositoryProvider), isA<AuthRepository>());
      });
    });

    group('login', () {
      group('正常系', () {
        test('SuccessResultを返し、isLoggedInがtrueになること', () async {
          final result = await repository.login(
            email: _email,
            password: _password,
          );

          expect(result, isA<SuccessResult<void>>());
          expect(await repository.isLoggedIn, isTrue);
        });

        test('DTOにuser_idがない場合、userIdを保存しないこと', () async {
          final repo = AuthRepositoryImpl(
            authApiService: StubAuthApiServiceImpl(
              shouldOmitUserInTokenResponse: true,
            ),
            authSecureStorageService: authStorage,
            idGenerator: () => _testAnonymousId,
            userIdentityService: StubUserIdentityServiceImpl(),
          );

          final result = await repo.login(email: _email, password: _password);

          expect(result, isA<SuccessResult<void>>());
          expect(authStorage.getUserId(), equals(''));
        });
      });

      group('異常系', () {
        test(
          'APIがFailureResultを返した場合、FailureResult<AppError>に変換されること',
          () async {
            final repo = AuthRepositoryImpl(
              authApiService: StubAuthApiServiceImpl(shouldFail: true),
              authSecureStorageService: authStorage,
              idGenerator: () => _testAnonymousId,
              userIdentityService: StubUserIdentityServiceImpl(),
            );

            final result = await repo.login(email: _email, password: _password);

            expect(result, isA<FailureResult<void>>());
            expect((result as FailureResult<void>).error, isA<AppError>());
          },
        );

        test('例外発生時にFailureResultを返すこと', () async {
          final repo = AuthRepositoryImpl(
            authApiService: StubAuthApiServiceImpl(shouldThrow: true),
            authSecureStorageService: authStorage,
            idGenerator: () => _testAnonymousId,
            userIdentityService: StubUserIdentityServiceImpl(),
          );

          final result = await repo.login(email: _email, password: _password);

          expect(result, isA<FailureResult<void>>());
        });

        test(
          'APIがaccessToken: nullを返した場合、ServerError(500)のFailureResultを返すこと',
          () async {
            final repo = AuthRepositoryImpl(
              authApiService: _NullAccessTokenAuthApiService(),
              authSecureStorageService: authStorage,
              idGenerator: () => _testAnonymousId,
              userIdentityService: StubUserIdentityServiceImpl(),
            );

            final result = await repo.login(email: _email, password: _password);

            expect(result, isA<FailureResult<void>>());
            expect((result as FailureResult<void>).error, isA<ServerError>());
          },
        );

        test(
          'APIがrefreshToken: nullを返した場合、ServerError(500)のFailureResultを返すこと',
          () async {
            final repo = AuthRepositoryImpl(
              authApiService: _NullRefreshTokenAuthApiService(),
              authSecureStorageService: authStorage,
              idGenerator: () => _testAnonymousId,
              userIdentityService: StubUserIdentityServiceImpl(),
            );

            final result = await repo.login(email: _email, password: _password);

            expect(result, isA<FailureResult<void>>());
            expect((result as FailureResult<void>).error, isA<ServerError>());
          },
        );
      });
    });

    group('register', () {
      group('正常系', () {
        test('SuccessResultを返し、isLoggedInがtrueになること', () async {
          final result = await repository.register(
            email: _email,
            password: _password,
          );

          expect(result, isA<SuccessResult<void>>());
          expect(await repository.isLoggedIn, isTrue);
        });
      });

      group('異常系', () {
        test(
          'APIがFailureResultを返した場合、FailureResult<AppError>に変換されること',
          () async {
            final repo = AuthRepositoryImpl(
              authApiService: StubAuthApiServiceImpl(shouldFail: true),
              authSecureStorageService: authStorage,
              idGenerator: () => _testAnonymousId,
              userIdentityService: StubUserIdentityServiceImpl(),
            );

            final result = await repo.register(
              email: _email,
              password: _password,
            );

            expect(result, isA<FailureResult<void>>());
            expect((result as FailureResult<void>).error, isA<AppError>());
          },
        );

        test('例外発生時にFailureResultを返すこと', () async {
          final repo = AuthRepositoryImpl(
            authApiService: StubAuthApiServiceImpl(shouldThrow: true),
            authSecureStorageService: authStorage,
            idGenerator: () => _testAnonymousId,
            userIdentityService: StubUserIdentityServiceImpl(),
          );

          final result = await repo.register(
            email: _email,
            password: _password,
          );

          expect(result, isA<FailureResult<void>>());
        });

        test(
          'APIがaccessToken: nullを返した場合、ServerError(500)のFailureResultを返すこと',
          () async {
            final repo = AuthRepositoryImpl(
              authApiService: _NullAccessTokenAuthApiService(),
              authSecureStorageService: authStorage,
              idGenerator: () => _testAnonymousId,
              userIdentityService: StubUserIdentityServiceImpl(),
            );

            final result = await repo.register(
              email: _email,
              password: _password,
            );

            expect(result, isA<FailureResult<void>>());
            expect((result as FailureResult<void>).error, isA<ServerError>());
          },
        );

        test(
          'APIがrefreshToken: nullを返した場合、ServerError(500)のFailureResultを返すこと',
          () async {
            final repo = AuthRepositoryImpl(
              authApiService: _NullRefreshTokenAuthApiService(),
              authSecureStorageService: authStorage,
              idGenerator: () => _testAnonymousId,
              userIdentityService: StubUserIdentityServiceImpl(),
            );

            final result = await repo.register(
              email: _email,
              password: _password,
            );

            expect(result, isA<FailureResult<void>>());
            expect((result as FailureResult<void>).error, isA<ServerError>());
          },
        );
      });
    });

    group('me', () {
      group('正常系', () {
        test('SuccessResult<User>を返すこと', () async {
          final result = await repository.me();

          expect(result, isA<SuccessResult<User>>());
        });
      });

      group('異常系', () {
        test(
          'APIがFailureResultを返した場合、FailureResult<AppError>に変換されること',
          () async {
            final repo = AuthRepositoryImpl(
              authApiService: StubAuthApiServiceImpl(shouldFail: true),
              authSecureStorageService: authStorage,
              idGenerator: () => _testAnonymousId,
              userIdentityService: StubUserIdentityServiceImpl(),
            );

            final result = await repo.me();

            expect(result, isA<FailureResult<User>>());
            expect((result as FailureResult<User>).error, isA<AppError>());
          },
        );

        test('UserDtoのid/emailがnullの場合、FailureResult<AppError>を返すこと', () async {
          final repo = AuthRepositoryImpl(
            authApiService: StubAuthApiServiceImpl(meReturnsInvalidUser: true),
            authSecureStorageService: authStorage,
            idGenerator: () => _testAnonymousId,
            userIdentityService: StubUserIdentityServiceImpl(),
          );

          final result = await repo.me();

          expect(result, isA<FailureResult<User>>());
          expect((result as FailureResult<User>).error, isA<AppError>());
        });

        test('例外発生時にFailureResultを返すこと', () async {
          final repo = AuthRepositoryImpl(
            authApiService: StubAuthApiServiceImpl(shouldThrow: true),
            authSecureStorageService: authStorage,
            idGenerator: () => _testAnonymousId,
            userIdentityService: StubUserIdentityServiceImpl(),
          );

          final result = await repo.me();

          expect(result, isA<FailureResult<User>>());
        });
      });
    });

    group('logout', () {
      group('正常系', () {
        test('isLoggedInがfalseになり、accessToken・refreshTokenが空文字、'
            'anonymousIdは保持されること', () async {
          await repository.login(email: _email, password: _password);

          await repository.logout();

          expect(await repository.isLoggedIn, isFalse);
          expect(authStorage.getAccessToken(), equals(''));
          expect(authStorage.getRefreshToken(), equals(''));
          expect(authStorage.getAnonymousId(), isNotEmpty);
        });
      });

      group('異常系', () {
        test('logout APIが失敗しても後続処理を続行すること', () async {
          final repo = AuthRepositoryImpl(
            authApiService: StubAuthApiServiceImpl(shouldThrow: true),
            authSecureStorageService: authStorage,
            idGenerator: () => _testAnonymousId,
            userIdentityService: StubUserIdentityServiceImpl(),
          );

          await expectLater(repo.logout(), completes);
          expect(await repo.isLoggedIn, isFalse);
        });
      });
    });

    group('isLoggedIn', () {
      group('正常系', () {
        test('初回ロード（トークンなし）: falseを返すこと', () async {
          final result = await repository.isLoggedIn;

          expect(result, isFalse);
        });

        test('初回ロード（トークンあり）: trueを返すこと', () async {
          // stub に事前にトークンを書き込む（別インスタンス経由で正しいキーを使用）
          final setup = AuthSecureStorageServiceImpl(secureStorage: stub);
          await setup.setAccessToken(token: 'valid-token');

          // 未初期化の authStorage で isLoggedIn を呼ぶ（init() が走る）
          final result = await repository.isLoggedIn;

          expect(result, isTrue);
        });

        test('ログイン後（キャッシュ）: trueを返すこと', () async {
          // login() 完了後は _isLoaded = true / _isLoggedIn = true がキャッシュされる
          await repository.login(email: _email, password: _password);

          final result = await repository.isLoggedIn;

          expect(result, isTrue);
        });
      });
    });

    group('_ensureAnonymousId', () {
      group('正常系', () {
        test('anonymousIdが設定済みの場合、新規生成しないこと', () async {
          // 事前に anonymousId をセット（stub storage + authStorage 両方に書き込まれる）
          await authStorage.setAnonymousId(id: 'pre-existing-id');

          // isLoggedIn → _ensureLoaded → init() → _ensureAnonymousId の順で実行
          await repository.isLoggedIn;

          // ID が上書きされていないことを確認
          expect(authStorage.getAnonymousId(), equals('pre-existing-id'));
        });
      });
    });

    group('pendingDeepLink / getAndClearPendingDeepLink', () {
      test('保存したパスを取得できること', () {
        repository.pendingDeepLink = '/some/path';
        expect(repository.getAndClearPendingDeepLink(), equals('/some/path'));
      });

      test('取得後はnullになること', () {
        repository
          ..pendingDeepLink = '/some/path'
          ..getAndClearPendingDeepLink();
        expect(repository.getAndClearPendingDeepLink(), isNull);
      });

      test('保存前はnullを返すこと', () {
        expect(repository.getAndClearPendingDeepLink(), isNull);
      });
    });
  });
}
