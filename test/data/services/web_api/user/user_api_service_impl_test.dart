import 'package:travel_app/data/services/web_api/api_client.dart';
import 'package:travel_app/data/services/web_api/api_exception.dart';
import 'package:travel_app/data/services/web_api/stub_api_enabled_provider.dart';
import 'package:travel_app/data/services/web_api/users/dto.dart';
import 'package:travel_app/data/services/web_api/users/service.dart';
import 'package:travel_app/data/services/web_api/users/service_impl.dart';
import 'package:travel_app/data/services/web_api/users/stub_service_impl.dart';
import 'package:travel_app/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'user_api_service_impl_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  late MockApiClient mockApiClient;
  late UsersApiServiceImpl userApiServiceImpl;

  setUp(() {
    mockApiClient = MockApiClient();
    userApiServiceImpl = UsersApiServiceImpl(apiClient: mockApiClient);
  });

  group('userApiServiceImplProvider', () {
    late ProviderContainer container;
    late MockApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
      container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWithValue(mockApiClient),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('userApiServiceImplProviderはUserApiServiceImplのインスタンスを返すこと', () {
      final service = container.read(usersApiServiceImplProvider);
      expect(service, isA<UsersApiServiceImpl>());
    });

    test('userApiServiceImplProviderは指定されたApiClientで初期化されること', () async {
      final service = container.read(usersApiServiceImplProvider);
      when(
        mockApiClient.get(endpoint: 'users/1'),
      ).thenAnswer(
        (_) async => {
          'id': 1,
          'firstName': 'Test',
        },
      );
      await service.fetchById();
      verify(
        mockApiClient.get(endpoint: 'users/1'),
      ).called(1);
    });
  });

  group('usersApiServiceProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWithValue(MockApiClient()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('isStub=false のとき UsersApiServiceImpl を返すこと', () {
      final service = container.read(usersApiServiceProvider);
      expect(service, isA<UsersApiServiceImpl>());
    });

    test('isStub=true のとき StubUsersApiServiceImpl を返すこと', () {
      container.read(isStubApiEnabledProvider.notifier).enabled = true;
      final service = container.read(usersApiServiceProvider);
      expect(service, isA<StubUsersApiServiceImpl>());
    });

    test('isStub=false → true → false と切り替えると型が変わること', () {
      expect(
        container.read(usersApiServiceProvider),
        isA<UsersApiServiceImpl>(),
      );
      container.read(isStubApiEnabledProvider.notifier).enabled = true;
      expect(
        container.read(usersApiServiceProvider),
        isA<StubUsersApiServiceImpl>(),
      );
      container.read(isStubApiEnabledProvider.notifier).enabled = false;
      expect(
        container.read(usersApiServiceProvider),
        isA<UsersApiServiceImpl>(),
      );
    });
  });

  group('StubUsersApiServiceImpl', () {
    late StubUsersApiServiceImpl stubService;

    setUp(() {
      stubService = StubUsersApiServiceImpl();
    });

    test('stubUsersApiServiceImplProvider は StubUsersApiServiceImpl を返すこと', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(
        container.read(stubUsersApiServiceImplProvider),
        isA<StubUsersApiServiceImpl>(),
      );
    });

    test('fetchById は SuccessResult<UserDto> を返すこと', () async {
      final result = await stubService.fetchById();
      expect(result, isA<SuccessResult<UserDto>>());
    });

    test('fetchById は UsersApiService を実装していること', () {
      expect(stubService, isA<UsersApiService>());
    });

    test('返却される UserDto は必須フィールドを持つこと', () async {
      final result = await stubService.fetchById();
      final user = (result as SuccessResult<UserDto>).value;
      expect(user.id, isNotNull);
      expect(user.firstName, isNotNull);
      expect(user.lastName, isNotNull);
      expect(user.email, isNotNull);
    });
  });

  group('fetch', () {
    test('ユーザーの取得に成功した場合、SuccessResult<UserDto>を返すこと', () async {
      final mockResponse = {
        'id': 1,
        'firstName': 'John',
        'lastName': 'Doe',
        'email': 'john@example.com',
      };
      when(
        mockApiClient.get(endpoint: 'users/1'),
      ).thenAnswer((_) async => mockResponse);

      final result = await userApiServiceImpl.fetchById();

      expect(result, isA<SuccessResult<UserDto>>());
      final successResult = result as SuccessResult<UserDto>;
      expect(successResult.value.id, 1);
      expect(successResult.value.firstName, 'John');
      expect(successResult.value.lastName, 'Doe');
      expect(successResult.value.email, 'john@example.com');
    });

    test('ApiClientExceptionが発生した場合、FailureResultを返すこと', () async {
      final apiException = ApiClientException(
        message: 'Not Found',
        statusCode: 404,
      );
      when(
        mockApiClient.get(endpoint: 'users/1'),
      ).thenThrow(apiException);

      final result = await userApiServiceImpl.fetchById();

      expect(result, isA<FailureResult<UserDto>>());
      expect((result as FailureResult<UserDto>).error, apiException);
    });

    test('その他の例外が発生した場合、FailureResultを返すこと', () async {
      final exception = Exception('Something went wrong');
      when(
        mockApiClient.get(endpoint: 'users/1'),
      ).thenThrow(exception);

      final result = await userApiServiceImpl.fetchById();

      expect(result, isA<FailureResult<UserDto>>());
      expect((result as FailureResult<UserDto>).error, exception);
    });
  });
}
