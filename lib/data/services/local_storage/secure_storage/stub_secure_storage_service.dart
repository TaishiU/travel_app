import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/local_storage/secure_storage/secure_storage_service.dart';

/// プロバイダ
final stubSecureStorageServiceImplProvider =
    Provider<StubSecureStorageServiceImpl>(
      (ref) => StubSecureStorageServiceImpl(),
    );

/// [SecureStorageService] のインメモリスタブ実装。
class StubSecureStorageServiceImpl implements SecureStorageService {
  final Map<String, String> _store = {};

  @override
  Future<String?> read({required String key}) async => _store[key];

  @override
  Future<void> write({required String key, required String value}) async {
    _store[key] = value;
  }

  @override
  Future<void> delete({required String key}) async {
    _store.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _store.clear();
  }
}
