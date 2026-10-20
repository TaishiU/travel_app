import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:travel_app/data/repositories/auth/auth_repository_impl.dart';
import 'package:travel_app/data/services/local_storage/secure_storage/auth/auth_secure_storage_service.dart';
import 'package:travel_app/data/services/local_storage/secure_storage/auth/auth_secure_storage_service_impl.dart';
import 'package:travel_app/data/services/web_api/auth/dto.dart';
import 'package:travel_app/data/services/web_api/auth/service.dart';
import 'package:travel_app/data/services/web_api/auth/service_impl.dart';
import 'package:travel_app/domain/errors/app_error.dart';
import 'package:travel_app/domain/interfaces/auth/auth_repository.dart';
import 'package:travel_app/utils/result.dart';

import 'auth_repository_test.mocks.dart';

void _setupDummyValues() {
  provideDummyBuilder<Result<TokenResponseDto>>(
    (_, _) => const SuccessResult(TokenResponseDto()),
  );
  provideDummyBuilder<Result<RefreshTokenDto>>(
    (_, _) => const SuccessResult(RefreshTokenDto()),
  );
  provideDummyBuilder<Result<UserDto>>(
    (_, _) => const SuccessResult(UserDto()),
  );
  provideDummyBuilder<Result<void>>((_, _) => const SuccessResult(null));
}

@GenerateMocks([
  AuthApiService,
  AuthApiServiceImpl,
  AuthSecureStorageService,
  AuthSecureStorageServiceImpl,
])
void main() {
  _setupDummyValues();

  late MockAuthApiService mockAuthApiService;
  late MockAuthSecureStorageService mockAuthSecureStorageService;
  late AuthRepositoryImpl authRepository;

  setUp(() {
    mockAuthApiService = MockAuthApiService();
    mockAuthSecureStorageService = MockAuthSecureStorageService();
    authRepository = AuthRepositoryImpl(
      authApiService: mockAuthApiService,
      authSecureStorageService: mockAuthSecureStorageService,
    );

    when(mockAuthSecureStorageService.init()).thenAnswer((_) async => {});
    when(mockAuthSecureStorageService.getAccessToken()).thenReturn('');
  });

  group('authRepositoryProvider', () {
    late ProviderContainer container;
    late MockAuthApiServiceImpl mockAuthApiServiceImpl;
    late MockAuthSecureStorageServiceImpl mockAuthSecureStorageServiceImpl;

    setUp(() {
      mockAuthApiServiceImpl = MockAuthApiServiceImpl();
      mockAuthSecureStorageServiceImpl = MockAuthSecureStorageServiceImpl();
      container = ProviderContainer(
        overrides: [
          authApiServiceImplProvider.overrideWith(
            (ref) => mockAuthApiServiceImpl,
          ),
          authSecureStorageServiceImplProvider.overrideWith(
            (ref) => mockAuthSecureStorageServiceImpl,
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('authRepositoryProviderはAuthRepositoryのインスタンスを返すこと', () {
      final repository = container.read(authRepositoryProvider);
      expect(repository, isA<AuthRepository>());
    });
  });

  group('isLoggedIn', () {
    test('初回呼び出し時にストレージから初期化され、トークンがあればtrueを返すこと', () async {
      when(mockAuthSecureStorageService.init()).thenAnswer((_) async => {});
      when(
        mockAuthSecureStorageService.getAccessToken(),
      ).thenReturn('valid_token');

      final result = await authRepository.isLoggedIn;

      expect(result, isTrue);
      verify(mockAuthSecureStorageService.init()).called(1);
      verify(mockAuthSecureStorageService.getAccessToken()).called(1);
    });

    test('初回呼び出し時にトークンがなければfalseを返すこと', () async {
      when(mockAuthSecureStorageService.init()).thenAnswer((_) async => {});
      when(mockAuthSecureStorageService.getAccessToken()).thenReturn('');

      final result = await authRepository.isLoggedIn;

      expect(result, isFalse);
      verify(mockAuthSecureStorageService.init()).called(1);
    });

    test('2回目以降の呼び出しではストレージにアクセスせずキャッシュを返すこと', () async {
      when(mockAuthSecureStorageService.init()).thenAnswer((_) async => {});
      when(mockAuthSecureStorageService.getAccessToken()).thenReturn('token');

      await authRepository.isLoggedIn;
      final result = await authRepository.isLoggedIn;

      expect(result, isTrue);
      verify(mockAuthSecureStorageService.init()).called(1);
      verify(mockAuthSecureStorageService.getAccessToken()).called(1);
    });
  });

  group('login', () {
    const email = 'test@example.com';
    const password = 'password123';
    const accessToken = 'access_token';
    const refreshToken = 'refresh_token';

    test('成功時にトークンを保存し、SuccessResultを返し、リスナーに通知すること', () async {
      var notifyCount = 0;
      authRepository.addListener(() => notifyCount++);

      when(
        mockAuthApiService.login(email: email, password: password),
      ).thenAnswer(
        (_) async => const SuccessResult(
          TokenResponseDto(
            accessToken: accessToken,
            refreshToken: refreshToken,
          ),
        ),
      );
      when(
        mockAuthSecureStorageService.setAccessToken(token: accessToken),
      ).thenAnswer((_) async => {});
      when(
        mockAuthSecureStorageService.setRefreshToken(token: refreshToken),
      ).thenAnswer((_) async => {});

      final result = await authRepository.login(
        email: email,
        password: password,
      );

      expect(result, isA<SuccessResult<void>>());
      expect(await authRepository.isLoggedIn, isTrue);
      expect(notifyCount, 1);

      verify(
        mockAuthSecureStorageService.setAccessToken(token: accessToken),
      ).called(1);
      verify(
        mockAuthSecureStorageService.setRefreshToken(token: refreshToken),
      ).called(1);
    });

    test('APIがFailureResultを返した場合、FailureResultを返し、トークンを保存しないこと', () async {
      final exception = Exception('Login Failed');
      when(
        mockAuthApiService.login(email: email, password: password),
      ).thenAnswer((_) async => FailureResult(exception));

      final result = await authRepository.login(
        email: email,
        password: password,
      );

      expect(result, isA<FailureResult<void>>());
      expect((result as FailureResult<void>).error, isA<AppError>());
      verifyNever(
        mockAuthSecureStorageService.setAccessToken(token: anyNamed('token')),
      );
    });

    test('例外発生時にFailureResultを返すこと', () async {
      when(
        mockAuthApiService.login(email: email, password: password),
      ).thenThrow(Exception('Network Error'));

      final result = await authRepository.login(
        email: email,
        password: password,
      );

      expect(result, isA<FailureResult<void>>());
    });
  });

  group('register', () {
    const email = 'new@example.com';
    const password = 'password123';
    const accessToken = 'access_token';
    const refreshToken = 'refresh_token';

    test('成功時にトークンを保存し、SuccessResultを返し、リスナーに通知すること', () async {
      var notifyCount = 0;
      authRepository.addListener(() => notifyCount++);

      when(
        mockAuthApiService.register(email: email, password: password),
      ).thenAnswer(
        (_) async => const SuccessResult(
          TokenResponseDto(
            accessToken: accessToken,
            refreshToken: refreshToken,
          ),
        ),
      );
      when(
        mockAuthSecureStorageService.setAccessToken(token: accessToken),
      ).thenAnswer((_) async => {});
      when(
        mockAuthSecureStorageService.setRefreshToken(token: refreshToken),
      ).thenAnswer((_) async => {});

      final result = await authRepository.register(
        email: email,
        password: password,
      );

      expect(result, isA<SuccessResult<void>>());
      expect(await authRepository.isLoggedIn, isTrue);
      expect(notifyCount, 1);
    });

    test('APIがFailureResultを返した場合、FailureResultを返すこと', () async {
      final exception = Exception('Register Failed');
      when(
        mockAuthApiService.register(email: email, password: password),
      ).thenAnswer((_) async => FailureResult(exception));

      final result = await authRepository.register(
        email: email,
        password: password,
      );

      expect(result, isA<FailureResult<void>>());
      expect((result as FailureResult<void>).error, isA<AppError>());
    });
  });

  group('pendingDeepLink / getAndClearPendingDeepLink', () {
    test('保存したパスを取得できること', () {
      authRepository.pendingDeepLink = '/some/path';
      expect(authRepository.getAndClearPendingDeepLink(), '/some/path');
    });

    test('取得後はnullになること', () {
      authRepository
        ..pendingDeepLink = '/some/path'
        ..getAndClearPendingDeepLink();
      expect(authRepository.getAndClearPendingDeepLink(), isNull);
    });

    test('保存前はnullを返すこと', () {
      expect(authRepository.getAndClearPendingDeepLink(), isNull);
    });
  });

  group('logout', () {
    test('ストレージをクリアし、状態を更新してリスナーに通知すること', () async {
      var notifyCount = 0;
      authRepository.addListener(() => notifyCount++);

      when(
        mockAuthSecureStorageService.clearAuthData(),
      ).thenAnswer((_) async => true);

      await authRepository.logout();

      expect(await authRepository.isLoggedIn, isFalse);
      expect(notifyCount, 1);
      verify(mockAuthSecureStorageService.clearAuthData()).called(1);
    });
  });
}
