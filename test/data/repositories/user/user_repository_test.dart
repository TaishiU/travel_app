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

// MissingDummyValueErrorを解決するためにダミー値を提供するヘルパー関数
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
    const mockUserDto = dto.UserDto(
      id: 1,
      firstName: 'John',
      lastName: 'Doe',
      email: 'john.doe@example.com',
    );

    test('API取得成功時にSuccessResult<User>を返すこと', () async {
      when(mockUserApiService.fetchById()).thenAnswer(
        (_) async => const SuccessResult(mockUserDto),
      );

      final result = await userRepository.fetch();

      expect(result, isA<SuccessResult<User>>());
      final user = (result as SuccessResult<User>).value;
      expect(user.id, 1);
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
      expect(user.email, 'john.doe@example.com');
      verify(mockUserApiService.fetchById()).called(1);
    });

    test('すべてのフィールドが定義されたAPI取得成功時に、エンティティに正しく変換されること', () async {
      const fullDto = dto.UserDto(
        id: 1,
        firstName: 'John',
        lastName: 'Doe',
        maidenName: 'Smith',
        age: 30,
        gender: 'male',
        email: 'john.doe@example.com',
        phone: '1234567890',
        username: 'johndoe',
        password: 'password',
        birthDate: '1990-01-01',
        image: 'http://example.com/image.png',
        bloodGroup: 'A+',
        height: 180,
        weight: 75,
        eyeColor: 'blue',
        hair: dto.Hair(color: 'black', type: 'straight'),
        ip: '127.0.0.1',
        address: dto.Address(
          address: '123 Main St',
          city: 'New York',
          state: 'NY',
          stateCode: 'NY',
          postalCode: '10001',
          coordinates: dto.Coordinates(lat: 40.7128, lng: -74.0060),
          country: 'USA',
        ),
        macAddress: '00:00:00:00:00:00',
        university: 'MIT',
        bank: dto.Bank(
          cardExpire: '12/25',
          cardNumber: '1234567890123456',
          cardType: 'Visa',
          currency: 'USD',
          iban: 'US1234567890',
        ),
        company: dto.Company(
          department: 'Engineering',
          name: 'Tech Corp',
          title: 'Software Engineer',
          address: dto.Address(
            address: '456 Tech Lane',
            city: 'San Francisco',
            state: 'CA',
            stateCode: 'CA',
            postalCode: '94105',
            coordinates: dto.Coordinates(lat: 37.7749, lng: -122.4194),
            country: 'USA',
          ),
        ),
        ein: '12-3456789',
        ssn: '123-45-6789',
        userAgent: 'Mozilla/5.0',
        crypto: dto.Crypto(
          coin: 'Bitcoin',
          wallet: '0x123',
          network: 'Ethereum',
        ),
        role: 'admin',
      );

      when(mockUserApiService.fetchById()).thenAnswer(
        (_) async => const SuccessResult(fullDto),
      );

      final result = await userRepository.fetch();

      expect(result, isA<SuccessResult<User>>());
      final user = (result as SuccessResult<User>).value;

      // 各フィールドの変換を確認
      expect(user.id, 1);
      expect(user.firstName, 'John');
      expect(user.hair.color, 'black');
      expect(user.address.city, 'New York');
      expect(user.address.coordinates.lat, 40.7128);
      expect(user.bank.cardType, 'Visa');
      expect(user.company.name, 'Tech Corp');
      expect(user.company.address.city, 'San Francisco');
      expect(user.crypto.coin, 'Bitcoin');
      expect(user.role, 'admin');
    });

    test('APIがFailureResultを返した場合、FailureResultを返すこと', () async {
      final exception = Exception('API Error');
      when(mockUserApiService.fetchById()).thenAnswer(
        (_) async => FailureResult(exception),
      );

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
  });

  group('Entity変換のバリデーション', () {
    test('必須フィールド(id)が欠損している場合はFailureResultを返すこと', () async {
      const incompleteDto = dto.UserDto(firstName: 'No ID');
      when(mockUserApiService.fetchById()).thenAnswer(
        (_) async => const SuccessResult(incompleteDto),
      );

      final result = await userRepository.fetch();

      expect(result, isA<FailureResult<User>>());
      expect((result as FailureResult).error, isA<UnknownError>());
    });

    test('null可能なフィールドにはデフォルト値が入ること', () async {
      const minimalDto = dto.UserDto(id: 1);
      when(mockUserApiService.fetchById()).thenAnswer(
        (_) async => const SuccessResult(minimalDto),
      );

      final result = await userRepository.fetch();

      expect(result, isA<SuccessResult<User>>());
      final user = (result as SuccessResult<User>).value;
      expect(user.id, 1);
      expect(user.firstName, isEmpty);
      expect(user.age, 0);
      expect(user.height, 0.0);
    });
  });
}
