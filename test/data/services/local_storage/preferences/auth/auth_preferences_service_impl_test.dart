import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/misc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/src/shared_preferences_async.dart';
import 'package:travel_app/data/services/local_storage/preferences/auth/auth_preferences_service_impl.dart';
import 'package:travel_app/data/services/local_storage/preferences/shared_preferences_service.dart';
import 'package:travel_app/data/services/local_storage/preferences/shared_preferences_service_impl.dart';

import 'auth_preferences_service_impl_test.mocks.dart';

@GenerateMocks([SharedPreferencesService, SharedPreferencesWithCache])
void main() {
  late MockSharedPreferencesService mockSharedPreferencesService;
  late MockSharedPreferencesWithCache mockSharedPreferencesWithCache;
  late AuthPreferencesServiceImpl authPreferencesServiceImpl;

  const accessTokenKey = 'access_token';
  const refreshTokenKey = 'refresh_token';

  setUp(() {
    mockSharedPreferencesService = MockSharedPreferencesService();
    mockSharedPreferencesWithCache = MockSharedPreferencesWithCache();
    authPreferencesServiceImpl = AuthPreferencesServiceImpl(
      generalPreferences: mockSharedPreferencesService,
    );

    // 各テストケースの前にモックの呼び出し履歴をクリアします。
    reset(mockSharedPreferencesService);
    reset(mockSharedPreferencesWithCache);
  });

  group('authPreferencesServiceImplProvider', () {
    late ProviderContainer container;

    setUp(() {
      mockSharedPreferencesService = MockSharedPreferencesService();
      mockSharedPreferencesWithCache = MockSharedPreferencesWithCache();
      container = ProviderContainer(
        overrides: [
          // `sharedPreferencesServiceImplProvider` をオーバーライドして、
          // `AuthPreferencesServiceImpl` がモックを使用するようにします。
          sharedPreferencesServiceImplProvider.overrideWithValue(
            SharedPreferencesServiceImpl(
              sharedPreferences: mockSharedPreferencesWithCache,
            ),
          ),
        ],
      );
      reset(mockSharedPreferencesService);
      reset(mockSharedPreferencesWithCache);
    });

    tearDown(() {
      container.dispose();
    });

    test('authPreferencesServiceImplProviderは'
        'AuthPreferencesServiceImplのインスタンスを返すこと', () {
      final service = container.read(authPreferencesServiceImplProvider);
      expect(service, isA<AuthPreferencesServiceImpl>());
    });

    test('authPreferencesServiceImplProviderは'
        '指定されたMockSharedPreferencesWithCacheで初期化されること', () {
      final service = container.read(authPreferencesServiceImplProvider);

      // モックされたgetStringメソッドを呼び出すことで、
      // 内部で渡されたMockSharedPreferencesWithCacheが使用されていることを確認
      when(
        mockSharedPreferencesWithCache.getString('test_key'),
      ).thenReturn('test_value');
      final value = service.generalPreferences.getString(key: 'test_key');
      expect(value, 'test_value');
      verify(mockSharedPreferencesWithCache.getString('test_key')).called(1);
    });

    test('overridesなしでauthPreferencesServiceImplProviderにアクセスした場合、'
        'ProviderExceptionがスローされること', () {
      // Providerをオーバーライドせずにコンテナを作成
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // プロバイダを読み込もうとするとProviderExceptionがスローされることを確認
      expect(
        () => container.read(authPreferencesServiceImplProvider),
        throwsA(isA<ProviderException>()),
      );
    });
  });

  group('AuthPreferencesServiceImpl', () {
    test('getAccessTokenはgeneralPreferences.getStringを正しいキーで呼び出すこと', () {
      when(
        mockSharedPreferencesService.getString(key: accessTokenKey),
      ).thenReturn('test_access_token');
      final result = authPreferencesServiceImpl.getAccessToken();
      expect(result, 'test_access_token');
      verify(
        mockSharedPreferencesService.getString(key: accessTokenKey),
      ).called(1);
    });

    test('getAccessTokenがnullを返した場合、空文字列を返すこと', () {
      when(
        mockSharedPreferencesService.getString(key: accessTokenKey),
      ).thenReturn(null);
      final result = authPreferencesServiceImpl.getAccessToken();
      expect(result, '');
      verify(
        mockSharedPreferencesService.getString(key: accessTokenKey),
      ).called(1);
    });

    test(
      'setAccessTokenはgeneralPreferences.setStringを正しいキーと値で呼び出すこと',
      () async {
        when(
          mockSharedPreferencesService.setString(
            key: accessTokenKey,
            value: 'new_access_token',
          ),
        ).thenAnswer((_) async => true);
        await authPreferencesServiceImpl.setAccessToken(
          token: 'new_access_token',
        );
        verify(
          mockSharedPreferencesService.setString(
            key: accessTokenKey,
            value: 'new_access_token',
          ),
        ).called(1);
      },
    );

    test('getRefreshTokenはgeneralPreferences.getStringを正しいキーで呼び出すこと', () {
      when(
        mockSharedPreferencesService.getString(key: refreshTokenKey),
      ).thenReturn('test_refresh_token');
      final result = authPreferencesServiceImpl.getRefreshToken();
      expect(result, 'test_refresh_token');
      verify(
        mockSharedPreferencesService.getString(key: refreshTokenKey),
      ).called(1);
    });

    test('getRefreshTokenがnullを返した場合、空文字列を返すこと', () {
      when(
        mockSharedPreferencesService.getString(key: refreshTokenKey),
      ).thenReturn(null);
      final result = authPreferencesServiceImpl.getRefreshToken();
      expect(result, '');
      verify(
        mockSharedPreferencesService.getString(key: refreshTokenKey),
      ).called(1);
    });

    test(
      'setRefreshTokenはgeneralPreferences.setStringを正しいキーと値で呼び出すこと',
      () async {
        when(
          mockSharedPreferencesService.setString(
            key: refreshTokenKey,
            value: 'new_refresh_token',
          ),
        ).thenAnswer((_) async => true);
        await authPreferencesServiceImpl.setRefreshToken(
          token: 'new_refresh_token',
        );
        verify(
          mockSharedPreferencesService.setString(
            key: refreshTokenKey,
            value: 'new_refresh_token',
          ),
        ).called(1);
      },
    );

    test('clearAuthDataはgeneralPreferences.removeを両方のキーで呼び出すこと', () async {
      when(
        mockSharedPreferencesService.remove(key: accessTokenKey),
      ).thenAnswer((_) async => true);
      when(
        mockSharedPreferencesService.remove(key: refreshTokenKey),
      ).thenAnswer((_) async => true);
      final result = await authPreferencesServiceImpl.clearAuthData();
      expect(result, isTrue);
      verify(
        mockSharedPreferencesService.remove(key: accessTokenKey),
      ).called(1);
      verify(
        mockSharedPreferencesService.remove(key: refreshTokenKey),
      ).called(1);
    });
  });
}
