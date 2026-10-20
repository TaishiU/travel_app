import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:travel_app/data/repositories/user/user_repository.dart';
import 'package:travel_app/data/services/web_api/users/dto.dart' as dto;
import 'package:travel_app/data/services/web_api/users/service.dart';
import 'package:travel_app/data/services/web_api/users/service_impl.dart';
import 'package:travel_app/domain/entities/user/user.dart';
import 'package:travel_app/domain/errors/app_error.dart';
import 'package:travel_app/utils/result.dart';

import 'user_repository_test.mocks.dart';

void _setupDummyValues() {
  provideDummyBuilder<Result<dto.UserDto>>(
    (_, _) => const SuccessResult(dto.UserDto()),
  );
}

@GenerateMocks([UsersApiService, UsersApiServiceImpl])
void main() {
  _setupDummyValues();

  late MockUsersApiService mockUserApiService;
  late UserRepository userRepository;

  setUp(() {
    mockUserApiService = MockUsersApiService();
    userRepository = UserRepository(usersApiService: mockUserApiService);
  });

  group('userRepositoryProvider', () {
    late ProviderContainer container;
    late MockUsersApiServiceImpl mockUserApiServiceImpl;

    setUp(() {
      mockUserApiServiceImpl = MockUsersApiServiceImpl();
      container = ProviderContainer(
        overrides: [
          usersApiServiceImplProvider.overrideWith(
            (ref) => mockUserApiServiceImpl,
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('userRepositoryProvider は UserRepository のインスタンスを返すこと', () {
      final repository = container.read(userRepositoryProvider);
      expect(repository, isA<UserRepository>());
    });
  });

  group('fetch メソッドのテスト', () {
    const mockUserDto = dto.UserDto(id: 1, email: 'john.doe@example.com');

    group('正常系', () {
      test('API取得成功時にSuccessResult<User>を返すこと', () async {
        when(
          mockUserApiService.fetchById(),
        ).thenAnswer((_) async => const SuccessResult(mockUserDto));

        final result = await userRepository.fetch();

        expect(result, isA<SuccessResult<User>>());
        final user = (result as SuccessResult<User>).value;
        expect(user.id, '1');
        expect(user.email, 'john.doe@example.com');
        verify(mockUserApiService.fetchById()).called(1);
      });

      test('emailがnullの場合、空文字が入ること', () async {
        const noEmailDto = dto.UserDto(id: 1);
        when(
          mockUserApiService.fetchById(),
        ).thenAnswer((_) async => const SuccessResult(noEmailDto));

        final result = await userRepository.fetch();

        expect(result, isA<SuccessResult<User>>());
        final user = (result as SuccessResult<User>).value;
        expect(user.id, '1');
        expect(user.email, isEmpty);
        expect(user.displayName, isNull);
      });
    });

    group('異常系', () {
      test('APIがFailureResultを返した場合、FailureResultを返すこと', () async {
        final exception = Exception('API Error');
        when(
          mockUserApiService.fetchById(),
        ).thenAnswer((_) async => FailureResult(exception));

        final result = await userRepository.fetch();

        expect(result, isA<FailureResult<User>>());
        expect((result as FailureResult).error, isA<AppError>());
      });

      test('例外発生時にFailureResultを返すこと', () async {
        when(
          mockUserApiService.fetchById(),
        ).thenThrow(Exception('Network Error'));

        final result = await userRepository.fetch();

        expect(result, isA<FailureResult<User>>());
        expect((result as FailureResult).error, isA<AppError>());
      });

      test('必須フィールド(id)が欠損している場合はFailureResultを返すこと', () async {
        const incompleteDto = dto.UserDto(email: 'no-id@example.com');
        when(
          mockUserApiService.fetchById(),
        ).thenAnswer((_) async => const SuccessResult(incompleteDto));

        final result = await userRepository.fetch();

        expect(result, isA<FailureResult<User>>());
        expect((result as FailureResult).error, isA<UnknownError>());
      });
    });
  });
}
