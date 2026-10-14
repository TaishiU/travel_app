import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/misc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/src/shared_preferences_async.dart';
import 'package:travel_app/data/services/local_storage/preferences/shared_preferences_service_impl.dart';

import 'shared_preferences_service_impl_test.mocks.dart';

@GenerateMocks([SharedPreferencesWithCache])
void main() {
  late MockSharedPreferencesWithCache mockSharedPreferencesWithCache;
  late SharedPreferencesServiceImpl serviceImpl;

  setUp(() {
    mockSharedPreferencesWithCache = MockSharedPreferencesWithCache();
    serviceImpl = SharedPreferencesServiceImpl(
      sharedPreferences: mockSharedPreferencesWithCache,
    );

    // 各テストケースの前にモックの呼び出し履歴をクリア
    reset(mockSharedPreferencesWithCache);
  });

  // sharedPreferencesServiceImplProviderのテスト
  group('sharedPreferencesServiceImplProvider', () {
    late ProviderContainer container;

    setUp(() {
      mockSharedPreferencesWithCache = MockSharedPreferencesWithCache();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesServiceImplProvider.overrideWithValue(
            SharedPreferencesServiceImpl(
              sharedPreferences: mockSharedPreferencesWithCache,
            ),
          ),
        ],
      );
      reset(mockSharedPreferencesWithCache);
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'sharedPreferencesServiceImplProviderは'
      'SharedPreferencesServiceImplのインスタンスを返すこと',
      () {
        final service = container.read(sharedPreferencesServiceImplProvider);
        expect(service, isA<SharedPreferencesServiceImpl>());
      },
    );

    test(
      'sharedPreferencesServiceImplProviderは'
      '指定されたMockSharedPreferencesWithCacheで初期化されること',
      () async {
        final service = container.read(sharedPreferencesServiceImplProvider);

        // モックされたgetStringメソッドを呼び出すことで、
        // 内部で渡されたMockSharedPreferencesWithCacheが使用されていることを確認
        when(
          mockSharedPreferencesWithCache.getString('test_key'),
        ).thenReturn('test_value');
        final value = service.getString(key: 'test_key');
        expect(value, 'test_value');
        verify(
          mockSharedPreferencesWithCache.getString('test_key'),
        ).called(1);
      },
    );

    // overrideを行わない場合
    test(
      'overridesなしでsharedPreferencesServiceImplProviderにアクセスした場合、'
      'ProviderExceptionがスローされること',
      () {
        // Providerをオーバーライドせずにコンテナを作成
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // プロバイダを読み込もうとするとProviderExceptionがスローされることを確認
        expect(
          () => container.read(sharedPreferencesServiceImplProvider),
          throwsA(isA<ProviderException>()),
        );
      },
    );
  });

  // getStringメソッドのテスト
  group('getString', () {
    test('キーに対応する文字列が保存されている場合、その文字列を返すこと', () {
      when(
        mockSharedPreferencesWithCache.getString('test_key'),
      ).thenReturn('test_value');
      final result = serviceImpl.getString(key: 'test_key');
      expect(result, 'test_value');
      verify(mockSharedPreferencesWithCache.getString('test_key')).called(1);
    });

    test('キーに対応する文字列が保存されていない場合、nullを返すこと', () {
      when(
        mockSharedPreferencesWithCache.getString('non_existent_key'),
      ).thenReturn(null);
      final result = serviceImpl.getString(key: 'non_existent_key');
      expect(result, isNull);
      verify(
        mockSharedPreferencesWithCache.getString('non_existent_key'),
      ).called(1);
    });

    test('キーに対応する文字列が保存されておらず、defaultValueが指定されている場合、'
        'defaultValueを返すこと', () {
      when(
        mockSharedPreferencesWithCache.getString('non_existent_key'),
      ).thenReturn(null);
      final result = serviceImpl.getString(
        key: 'non_existent_key',
        defaultValue: 'default_value',
      );
      expect(result, 'default_value');
      verify(
        mockSharedPreferencesWithCache.getString('non_existent_key'),
      ).called(1);
    });
  });

  // setStringメソッドのテスト
  group('setString', () {
    test('指定されたキーと値でsetStringが呼び出されること', () async {
      when(
        mockSharedPreferencesWithCache.setString('test_key', 'test_value'),
      ).thenAnswer((_) async => true);
      await serviceImpl.setString(key: 'test_key', value: 'test_value');
      verify(
        mockSharedPreferencesWithCache.setString('test_key', 'test_value'),
      ).called(1);
    });
  });

  // getBoolメソッドのテスト
  group('getBool', () {
    test('キーに対応する真偽値が保存されている場合、その真偽値を返すこと', () {
      when(
        mockSharedPreferencesWithCache.getBool('test_key'),
      ).thenReturn(true);
      final result = serviceImpl.getBool(key: 'test_key');
      expect(result, isTrue);
      verify(mockSharedPreferencesWithCache.getBool('test_key')).called(1);
    });

    test('キーに対応する真偽値が保存されていない場合、nullを返すこと', () {
      when(
        mockSharedPreferencesWithCache.getBool('non_existent_key'),
      ).thenReturn(null);
      final result = serviceImpl.getBool(key: 'non_existent_key');
      expect(result, isNull);
      verify(
        mockSharedPreferencesWithCache.getBool('non_existent_key'),
      ).called(1);
    });

    test('キーに対応する真偽値が保存されておらず、defaultValueが指定されている場合、'
        'defaultValueを返すこと', () {
      when(
        mockSharedPreferencesWithCache.getBool('non_existent_key'),
      ).thenReturn(null);
      final result = serviceImpl.getBool(
        key: 'non_existent_key',
        defaultValue: false,
      );
      expect(result, isFalse);
      verify(
        mockSharedPreferencesWithCache.getBool('non_existent_key'),
      ).called(1);
    });
  });

  // setBoolメソッドのテスト
  group('setBool', () {
    test('指定されたキーと値でsetBoolが呼び出されること', () async {
      when(
        mockSharedPreferencesWithCache.setBool('test_key', true),
      ).thenAnswer((_) async => true);
      await serviceImpl.setBool(key: 'test_key', value: true);
      verify(
        mockSharedPreferencesWithCache.setBool('test_key', true),
      ).called(1);
    });
  });

  // getIntメソッドのテスト
  group('getInt', () {
    test('キーに対応する整数が保存されている場合、その整数を返すこと', () {
      when(mockSharedPreferencesWithCache.getInt('test_key')).thenReturn(123);
      final result = serviceImpl.getInt(key: 'test_key');
      expect(result, 123);
      verify(mockSharedPreferencesWithCache.getInt('test_key')).called(1);
    });

    test('キーに対応する整数が保存されていない場合、nullを返すこと', () {
      when(
        mockSharedPreferencesWithCache.getInt('non_existent_key'),
      ).thenReturn(null);
      final result = serviceImpl.getInt(key: 'non_existent_key');
      expect(result, isNull);
      verify(
        mockSharedPreferencesWithCache.getInt('non_existent_key'),
      ).called(1);
    });

    test('キーに対応する整数が保存されておらず、defaultValueが指定されている場合、'
        'defaultValueを返すこと', () {
      when(
        mockSharedPreferencesWithCache.getInt('non_existent_key'),
      ).thenReturn(null);
      final result = serviceImpl.getInt(
        key: 'non_existent_key',
        defaultValue: 0,
      );
      expect(result, 0);
      verify(
        mockSharedPreferencesWithCache.getInt('non_existent_key'),
      ).called(1);
    });
  });

  // setIntメソッドのテスト
  group('setInt', () {
    test('指定されたキーと値でsetIntが呼び出されること', () async {
      when(
        mockSharedPreferencesWithCache.setInt('test_key', 123),
      ).thenAnswer((_) async => true);
      await serviceImpl.setInt(key: 'test_key', value: 123);
      verify(
        mockSharedPreferencesWithCache.setInt('test_key', 123),
      ).called(1);
    });
  });

  // getDoubleメソッドのテスト
  group('getDouble', () {
    test('キーに対応する浮動小数点数が保存されている場合、その浮動小数点数を返すこと', () {
      when(
        mockSharedPreferencesWithCache.getDouble('test_key'),
      ).thenReturn(1.23);
      final result = serviceImpl.getDouble(key: 'test_key');
      expect(result, 1.23);
      verify(mockSharedPreferencesWithCache.getDouble('test_key')).called(1);
    });

    test('キーに対応する浮動小数点数が保存されていない場合、nullを返すこと', () {
      when(
        mockSharedPreferencesWithCache.getDouble('non_existent_key'),
      ).thenReturn(null);
      final result = serviceImpl.getDouble(key: 'non_existent_key');
      expect(result, isNull);
      verify(
        mockSharedPreferencesWithCache.getDouble('non_existent_key'),
      ).called(1);
    });

    test(
      'キーに対応する浮動小数点数が保存されておらず、defaultValueが指定されている場合、'
      'defaultValueを返すこと',
      () {
        when(
          mockSharedPreferencesWithCache.getDouble('non_existent_key'),
        ).thenReturn(null);
        final result = serviceImpl.getDouble(
          key: 'non_existent_key',
          defaultValue: 0,
        );
        expect(result, 0.0);
        verify(
          mockSharedPreferencesWithCache.getDouble('non_existent_key'),
        ).called(1);
      },
    );
  });

  // setDoubleメソッドのテスト
  group('setDouble', () {
    test('指定されたキーと値でsetDoubleが呼び出されること', () async {
      when(
        mockSharedPreferencesWithCache.setDouble('test_key', 1.23),
      ).thenAnswer((_) async => true);
      await serviceImpl.setDouble(key: 'test_key', value: 1.23);
      verify(
        mockSharedPreferencesWithCache.setDouble('test_key', 1.23),
      ).called(1);
    });
  });

  // getStringListメソッドのテスト
  group('getStringList', () {
    test('キーに対応する文字列リストが保存されている場合、その文字列リストを返すこと', () {
      when(
        mockSharedPreferencesWithCache.getStringList('test_key'),
      ).thenReturn(['a', 'b', 'c']);
      final result = serviceImpl.getStringList(key: 'test_key');
      expect(result, ['a', 'b', 'c']);
      verify(
        mockSharedPreferencesWithCache.getStringList('test_key'),
      ).called(1);
    });

    test('キーに対応する文字列リストが保存されていない場合、nullを返すこと', () {
      when(
        mockSharedPreferencesWithCache.getStringList('non_existent_key'),
      ).thenReturn(null);
      final result = serviceImpl.getStringList(key: 'non_existent_key');
      expect(result, isNull);
      verify(
        mockSharedPreferencesWithCache.getStringList('non_existent_key'),
      ).called(1);
    });

    test(
      'キーに対応する文字列リストが保存されておらず、defaultValueが指定されている場合、'
      'defaultValueを返すこと',
      () {
        when(
          mockSharedPreferencesWithCache.getStringList('non_existent_key'),
        ).thenReturn(null);
        final result = serviceImpl.getStringList(
          key: 'non_existent_key',
          defaultValue: ['d', 'e'],
        );
        expect(result, ['d', 'e']);
        verify(
          mockSharedPreferencesWithCache.getStringList('non_existent_key'),
        ).called(1);
      },
    );
  });

  // setStringListメソッドのテスト
  group('setStringList', () {
    test('指定されたキーと値でsetStringListが呼び出されること', () async {
      when(
        mockSharedPreferencesWithCache.setStringList('test_key', [
          'a',
          'b',
          'c',
        ]),
      ).thenAnswer((_) async => true);
      await serviceImpl.setStringList(key: 'test_key', value: ['a', 'b', 'c']);
      verify(
        mockSharedPreferencesWithCache.setStringList('test_key', [
          'a',
          'b',
          'c',
        ]),
      ).called(1);
    });
  });

  // removeメソッドのテスト
  group('remove', () {
    test('指定されたキーでremoveが呼び出されること', () async {
      when(
        mockSharedPreferencesWithCache.remove('test_key'),
      ).thenAnswer((_) async => true);
      await serviceImpl.remove(key: 'test_key');
      verify(mockSharedPreferencesWithCache.remove('test_key')).called(1);
    });
  });

  // clearメソッドのテスト
  group('clear', () {
    test('clearが呼び出されること', () async {
      when(
        mockSharedPreferencesWithCache.clear(),
      ).thenAnswer((_) async => true);
      await serviceImpl.clear();
      verify(mockSharedPreferencesWithCache.clear()).called(1);
    });
  });
}
