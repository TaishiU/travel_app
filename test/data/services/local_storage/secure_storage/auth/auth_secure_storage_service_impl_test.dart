import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:travel_app/data/services/local_storage/secure_storage/auth/auth_secure_storage_service_impl.dart';
import 'package:travel_app/data/services/local_storage/secure_storage/secure_storage_service.dart';
import 'package:travel_app/data/services/local_storage/secure_storage/secure_storage_service_impl.dart';

import 'auth_secure_storage_service_impl_test.mocks.dart';

@GenerateMocks([SecureStorageService, FlutterSecureStorage])
void main() {
  late MockSecureStorageService mockSecureStorage;
  late MockFlutterSecureStorage mockFlutterSecureStorage;
  late AuthSecureStorageServiceImpl authSecureStorageService;

  const accessTokenKey = 'access_token';
  const refreshTokenKey = 'refresh_token';

  setUp(() {
    mockSecureStorage = MockSecureStorageService();
    mockFlutterSecureStorage = MockFlutterSecureStorage();
    authSecureStorageService = AuthSecureStorageServiceImpl(
      secureStorage: mockSecureStorage,
    );

    reset(mockSecureStorage);
    reset(mockFlutterSecureStorage);
  });

  group('authSecureStorageServiceImplProvider', () {
    late ProviderContainer container;

    setUp(() {
      mockSecureStorage = MockSecureStorageService();
      mockFlutterSecureStorage = MockFlutterSecureStorage();
      container = ProviderContainer(
        overrides: [
          secureStorageServiceImplProvider.overrideWithValue(
            SecureStorageServiceImpl(mockFlutterSecureStorage),
          ),
        ],
      );
      reset(mockSecureStorage);
      reset(mockFlutterSecureStorage);
    });

    tearDown(() {
      container.dispose();
    });

    test('authSecureStorageServiceImplProviderは'
        'AuthSecureStorageServiceImplのインスタンスを返すこと', () {
      final service = container.read(authSecureStorageServiceImplProvider);
      expect(service, isA<AuthSecureStorageServiceImpl>());
    });

    test('authSecureStorageServiceImplProviderは'
        '指定されたMockFlutterSecureStorageで初期化されること', () async {
      final impl = container.read(authSecureStorageServiceImplProvider);

      when(
        mockFlutterSecureStorage.read(key: 'test_key'),
      ).thenAnswer((_) async => 'test_value');

      final value = await impl.secureStorage.read(key: 'test_key');
      expect(value, 'test_value');
      verify(mockFlutterSecureStorage.read(key: 'test_key')).called(1);
    });
  });

  group('AuthSecureStorageServiceImpl', () {
    test('initはストレージからデータをロードすること', () async {
      when(
        mockSecureStorage.read(key: accessTokenKey),
      ).thenAnswer((_) async => 'saved_access_token');
      when(
        mockSecureStorage.read(key: refreshTokenKey),
      ).thenAnswer((_) async => 'saved_refresh_token');

      await authSecureStorageService.init();

      expect(authSecureStorageService.getAccessToken(), 'saved_access_token');
      expect(authSecureStorageService.getRefreshToken(), 'saved_refresh_token');
      verify(mockSecureStorage.read(key: accessTokenKey)).called(1);
      verify(mockSecureStorage.read(key: refreshTokenKey)).called(1);
    });

    test('getAccessTokenは初期化されていない場合、空文字を返すこと', () {
      expect(authSecureStorageService.getAccessToken(), '');
    });

    test('setAccessTokenはメモリとストレージの両方を更新すること', () async {
      when(
        mockSecureStorage.write(key: accessTokenKey, value: 'new_token'),
      ).thenAnswer((_) async {});

      await authSecureStorageService.setAccessToken(token: 'new_token');

      expect(authSecureStorageService.getAccessToken(), 'new_token');
      verify(
        mockSecureStorage.write(key: accessTokenKey, value: 'new_token'),
      ).called(1);
    });

    test('getRefreshTokenは初期化されていない場合、空文字を返すこと', () {
      expect(authSecureStorageService.getRefreshToken(), '');
    });

    test('setRefreshTokenはメモリとストレージの両方を更新すること', () async {
      when(
        mockSecureStorage.write(key: refreshTokenKey, value: 'new_token'),
      ).thenAnswer((_) async {});

      await authSecureStorageService.setRefreshToken(token: 'new_token');

      expect(authSecureStorageService.getRefreshToken(), 'new_token');
      verify(
        mockSecureStorage.write(key: refreshTokenKey, value: 'new_token'),
      ).called(1);
    });

    test('clearAuthDataはメモリとストレージの両方をクリアすること', () async {
      // 事前にデータをセット
      when(
        mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')),
      ).thenAnswer((_) async {});
      await authSecureStorageService.setAccessToken(token: 'token');
      await authSecureStorageService.setRefreshToken(token: 'token');

      when(
        mockSecureStorage.delete(key: accessTokenKey),
      ).thenAnswer((_) async {});
      when(
        mockSecureStorage.delete(key: refreshTokenKey),
      ).thenAnswer((_) async {});

      final result = await authSecureStorageService.clearAuthData();

      expect(result, isTrue);
      expect(authSecureStorageService.getAccessToken(), '');
      expect(authSecureStorageService.getRefreshToken(), '');
      verify(mockSecureStorage.delete(key: accessTokenKey)).called(1);
      verify(mockSecureStorage.delete(key: refreshTokenKey)).called(1);
    });
  });
}
