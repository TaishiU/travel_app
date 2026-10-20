import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/misc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/src/shared_preferences_async.dart';
import 'package:travel_app/data/services/local_storage/preferences/settings/settings_preferences_service_impl.dart';
import 'package:travel_app/data/services/local_storage/preferences/shared_preferences_service.dart';
import 'package:travel_app/data/services/local_storage/preferences/shared_preferences_service_impl.dart';

import 'settings_preferences_service_impl_test.mocks.dart';

@GenerateMocks([SharedPreferencesService, SharedPreferencesWithCache])
void main() {
  late MockSharedPreferencesService mockSharedPreferencesService;
  late MockSharedPreferencesWithCache mockSharedPreferencesWithCache;
  late SettingsPreferencesServiceImpl settingsPreferencesServiceImpl;

  const appThemeKey = 'app_theme';
  const languageCodeKey = 'language_code';
  const agreedToTermsKey = 'agreed_to_terms';
  const notificationEnabledKey = 'notification_enabled';
  const lastLoginDateKey = 'last_login_date';

  setUp(() {
    mockSharedPreferencesService = MockSharedPreferencesService();
    mockSharedPreferencesWithCache = MockSharedPreferencesWithCache();
    settingsPreferencesServiceImpl = SettingsPreferencesServiceImpl(
      generalPreferences: mockSharedPreferencesService,
    );

    // 各テストケースの前にモックの呼び出し履歴をクリアします。
    reset(mockSharedPreferencesService);
    reset(mockSharedPreferencesWithCache);
  });

  group('settingsPreferencesServiceImplProvider', () {
    late ProviderContainer container;

    setUp(() {
      mockSharedPreferencesService = MockSharedPreferencesService();
      mockSharedPreferencesWithCache = MockSharedPreferencesWithCache();
      container = ProviderContainer(
        overrides: [
          // `sharedPreferencesServiceImplProvider` をオーバーライドして、
          // `SettingsPreferencesServiceImpl` がモックを使用するようにします。
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

    test('settingsPreferencesServiceImplProviderは'
        'SettingsPreferencesServiceImplのインスタンスを返すこと', () {
      final service = container.read(settingsPreferencesServiceImplProvider);
      expect(service, isA<SettingsPreferencesServiceImpl>());
    });

    test('settingsPreferencesServiceImplProviderは'
        '指定されたMockSharedPreferencesWithCacheで初期化されること', () {
      final service = container.read(settingsPreferencesServiceImplProvider);

      // モックされたgetStringメソッドを呼び出すことで、
      // 内部で渡されたMockSharedPreferencesWithCacheが使用されていることを確認
      when(
        mockSharedPreferencesWithCache.getString('test_key'),
      ).thenReturn('test_value');
      final value = service.generalPreferences.getString(key: 'test_key');
      expect(value, 'test_value');
      verify(mockSharedPreferencesWithCache.getString('test_key')).called(1);
    });

    test('overridesなしでsettingsPreferencesServiceImplProviderにアクセスした場合、'
        'ProviderExceptionがスローされること', () {
      // Providerをオーバーライドせずにコンテナを作成
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // プロバイダを読み込もうとするとProviderExceptionがスローされることを確認
      expect(
        () => container.read(settingsPreferencesServiceImplProvider),
        throwsA(isA<ProviderException>()),
      );
    });
  });

  group('SettingsPreferencesServiceImpl', () {
    // getAppTheme / setAppTheme
    test('getAppThemeは_generalPreferences.getStringを正しいキーで呼び出すこと', () {
      when(
        mockSharedPreferencesService.getString(key: appThemeKey),
      ).thenReturn('dark');
      final result = settingsPreferencesServiceImpl.getAppTheme();
      expect(result, 'dark');
      verify(
        mockSharedPreferencesService.getString(key: appThemeKey),
      ).called(1);
    });

    test('getAppThemeがnullを返した場合、空文字列を返すこと', () {
      when(
        mockSharedPreferencesService.getString(key: appThemeKey),
      ).thenReturn(null);
      final result = settingsPreferencesServiceImpl.getAppTheme();
      expect(result, '');
      verify(
        mockSharedPreferencesService.getString(key: appThemeKey),
      ).called(1);
    });

    test('setAppThemeは_generalPreferences.setStringを正しいキーと値で呼び出すこと', () async {
      when(
        mockSharedPreferencesService.setString(
          key: appThemeKey,
          value: 'light',
        ),
      ).thenAnswer((_) async => true);
      await settingsPreferencesServiceImpl.setAppTheme(theme: 'light');
      verify(
        mockSharedPreferencesService.setString(
          key: appThemeKey,
          value: 'light',
        ),
      ).called(1);
    });

    // getLanguageCode / setLanguageCode
    test('getLanguageCodeは_generalPreferences.getStringを正しいキーで呼び出すこと', () {
      when(
        mockSharedPreferencesService.getString(key: languageCodeKey),
      ).thenReturn('en');
      final result = settingsPreferencesServiceImpl.getLanguageCode();
      expect(result, 'en');
      verify(
        mockSharedPreferencesService.getString(key: languageCodeKey),
      ).called(1);
    });

    test('getLanguageCodeがnullを返した場合、空文字列を返すこと', () {
      when(
        mockSharedPreferencesService.getString(key: languageCodeKey),
      ).thenReturn(null);
      final result = settingsPreferencesServiceImpl.getLanguageCode();
      expect(result, '');
      verify(
        mockSharedPreferencesService.getString(key: languageCodeKey),
      ).called(1);
    });

    test(
      'setLanguageCodeは_generalPreferences.setStringを正しいキーと値で呼び出すこと',
      () async {
        when(
          mockSharedPreferencesService.setString(
            key: languageCodeKey,
            value: 'ja',
          ),
        ).thenAnswer((_) async => true);
        await settingsPreferencesServiceImpl.setLanguageCode(code: 'ja');
        verify(
          mockSharedPreferencesService.setString(
            key: languageCodeKey,
            value: 'ja',
          ),
        ).called(1);
      },
    );

    // getAgreedToTerms / setAgreedToTerms
    test('getAgreedToTermsは_generalPreferences.getBoolを正しいキーで呼び出すこと', () {
      when(
        mockSharedPreferencesService.getBool(key: agreedToTermsKey),
      ).thenReturn(true);
      final result = settingsPreferencesServiceImpl.getAgreedToTerms();
      expect(result, true);
      verify(
        mockSharedPreferencesService.getBool(key: agreedToTermsKey),
      ).called(1);
    });

    test('getAgreedToTermsがnullを返した場合、falseを返すこと', () {
      when(
        mockSharedPreferencesService.getBool(key: agreedToTermsKey),
      ).thenReturn(null);
      final result = settingsPreferencesServiceImpl.getAgreedToTerms();
      expect(result, false);
      verify(
        mockSharedPreferencesService.getBool(key: agreedToTermsKey),
      ).called(1);
    });

    test(
      'setAgreedToTermsは_generalPreferences.setBoolを正しいキーと値で呼び出すこと',
      () async {
        when(
          mockSharedPreferencesService.setBool(
            key: agreedToTermsKey,
            value: true,
          ),
        ).thenAnswer((_) async => true);
        await settingsPreferencesServiceImpl.setAgreedToTerms(agreed: true);
        verify(
          mockSharedPreferencesService.setBool(
            key: agreedToTermsKey,
            value: true,
          ),
        ).called(1);
      },
    );

    // getNotificationEnabled / setNotificationEnabled
    test('getNotificationEnabledは_generalPreferences.getBoolを正しいキーで呼び出すこと', () {
      when(
        mockSharedPreferencesService.getBool(key: notificationEnabledKey),
      ).thenReturn(true);
      final result = settingsPreferencesServiceImpl.getNotificationEnabled();
      expect(result, true);
      verify(
        mockSharedPreferencesService.getBool(key: notificationEnabledKey),
      ).called(1);
    });

    test('getNotificationEnabledがnullを返した場合、falseを返すこと', () {
      when(
        mockSharedPreferencesService.getBool(key: notificationEnabledKey),
      ).thenReturn(null);
      final result = settingsPreferencesServiceImpl.getNotificationEnabled();
      expect(result, false);
      verify(
        mockSharedPreferencesService.getBool(key: notificationEnabledKey),
      ).called(1);
    });

    test(
      'setNotificationEnabledは_generalPreferences.setBoolを正しいキーと値で呼び出すこと',
      () async {
        when(
          mockSharedPreferencesService.setBool(
            key: notificationEnabledKey,
            value: true,
          ),
        ).thenAnswer((_) async => true);
        await settingsPreferencesServiceImpl.setNotificationEnabled(
          enabled: true,
        );
        verify(
          mockSharedPreferencesService.setBool(
            key: notificationEnabledKey,
            value: true,
          ),
        ).called(1);
      },
    );

    // getLastLoginDate / setLastLoginDate
    test('getLastLoginDateは_generalPreferences.getStringを正しいキーで呼び出すこと', () {
      when(
        mockSharedPreferencesService.getString(key: lastLoginDateKey),
      ).thenReturn('2023-01-01');
      final result = settingsPreferencesServiceImpl.getLastLoginDate();
      expect(result, '2023-01-01');
      verify(
        mockSharedPreferencesService.getString(key: lastLoginDateKey),
      ).called(1);
    });

    test('getLastLoginDateがnullを返した場合、空文字列を返すこと', () {
      when(
        mockSharedPreferencesService.getString(key: lastLoginDateKey),
      ).thenReturn(null);
      final result = settingsPreferencesServiceImpl.getLastLoginDate();
      expect(result, '');
      verify(
        mockSharedPreferencesService.getString(key: lastLoginDateKey),
      ).called(1);
    });

    test(
      'setLastLoginDateは_generalPreferences.setStringを正しいキーと値で呼び出すこと',
      () async {
        when(
          mockSharedPreferencesService.setString(
            key: lastLoginDateKey,
            value: '2023-01-02',
          ),
        ).thenAnswer((_) async => true);
        await settingsPreferencesServiceImpl.setLastLoginDate(
          date: '2023-01-02',
        );
        verify(
          mockSharedPreferencesService.setString(
            key: lastLoginDateKey,
            value: '2023-01-02',
          ),
        ).called(1);
      },
    );

    // clearSettingsData
    test('clearSettingsDataは_generalPreferences.removeを全てのキーで呼び出すこと', () async {
      when(
        mockSharedPreferencesService.remove(key: appThemeKey),
      ).thenAnswer((_) async => true);
      when(
        mockSharedPreferencesService.remove(key: agreedToTermsKey),
      ).thenAnswer((_) async => true);
      when(
        mockSharedPreferencesService.remove(key: notificationEnabledKey),
      ).thenAnswer((_) async => true);
      when(
        mockSharedPreferencesService.remove(key: lastLoginDateKey),
      ).thenAnswer((_) async => true);

      final result = await settingsPreferencesServiceImpl.clearSettingsData();
      expect(result, isTrue);
      verify(mockSharedPreferencesService.remove(key: appThemeKey)).called(1);
      verify(
        mockSharedPreferencesService.remove(key: agreedToTermsKey),
      ).called(1);
      verify(
        mockSharedPreferencesService.remove(key: notificationEnabledKey),
      ).called(1);
      verify(
        mockSharedPreferencesService.remove(key: lastLoginDateKey),
      ).called(1);
    });
  });
}
