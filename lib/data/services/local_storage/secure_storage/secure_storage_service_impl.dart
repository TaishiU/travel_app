import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/local_storage/secure_storage/secure_storage_service.dart';

/// プロバイダ
final secureStorageServiceImplProvider = Provider<SecureStorageServiceImpl>(
  (ref) => const SecureStorageServiceImpl(FlutterSecureStorage()),
);

/// [SecureStorageService] の実装クラス。
class SecureStorageServiceImpl implements SecureStorageService {
  /// コンストラクタ
  const SecureStorageServiceImpl(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read({required String key}) async {
    return _storage.read(key: key);
  }

  @override
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
