import 'package:travel_app/data/services/local_storage/secure_storage/secure_storage_service_impl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'secure_storage_service_impl_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureStorageServiceImpl service;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    service = SecureStorageServiceImpl(mockStorage);
  });

  group('secureStorageServiceImplProvider', () {
    test('オーバーライドなしで SecureStorageServiceImpl のインスタンスが作成できること', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = container.read(secureStorageServiceImplProvider);
      expect(result, isA<SecureStorageServiceImpl>());
    });

    test(
      'secureStorageServiceImplProviderがオーバーライドされた場合に、指定したインスタンスを提供すること',
      () {
        final container = ProviderContainer(
          overrides: [
            secureStorageServiceImplProvider.overrideWithValue(
              SecureStorageServiceImpl(mockStorage),
            ),
          ],
        );
        addTearDown(container.dispose);

        final result = container.read(secureStorageServiceImplProvider);
        expect(result, isA<SecureStorageServiceImpl>());
      },
    );
  });

  group('read', () {
    test('指定したキーの値が読み取れること', () async {
      const key = 'test_key';
      const expectedValue = 'test_value';
      when(mockStorage.read(key: key)).thenAnswer((_) async => expectedValue);
      final result = await service.read(key: key);
      expect(result, expectedValue);
      verify(mockStorage.read(key: key)).called(1);
    });

    test('キーが存在しない場合にnullを返すこと', () async {
      const key = 'non_existent_key';
      when(mockStorage.read(key: key)).thenAnswer((_) async => null);
      final result = await service.read(key: key);
      expect(result, isNull);
      verify(mockStorage.read(key: key)).called(1);
    });
  });

  group('write', () {
    test('指定したキーと値で書き込みが行われること', () async {
      const key = 'test_key';
      const value = 'test_value';
      when(
        mockStorage.write(key: key, value: value),
      ).thenAnswer((_) async => {});
      await service.write(key: key, value: value);
      verify(mockStorage.write(key: key, value: value)).called(1);
    });
  });

  group('delete', () {
    test('指定したキーの削除が行われること', () async {
      const key = 'test_key';
      when(mockStorage.delete(key: key)).thenAnswer((_) async => {});
      await service.delete(key: key);
      verify(mockStorage.delete(key: key)).called(1);
    });
  });

  group('deleteAll', () {
    test('すべてのデータの削除が行われること', () async {
      when(mockStorage.deleteAll()).thenAnswer((_) async => {});
      await service.deleteAll();
      verify(mockStorage.deleteAll()).called(1);
    });
  });
}
