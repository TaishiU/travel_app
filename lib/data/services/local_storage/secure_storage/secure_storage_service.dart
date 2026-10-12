/// `flutter_secure_storage`の操作を抽象化するインターフェースを定義します。
/// セキュアなデータ保存が必要な場合に使用します。
abstract class SecureStorageService {
  /// 指定されたキーに対応する値を取得します。
  Future<String?> read({required String key});

  /// 指定されたキーに値を保存します。
  Future<void> write({required String key, required String value});

  /// 指定されたキーに対応する値を削除します。
  Future<void> delete({required String key});

  /// すべての値をクリアします。
  Future<void> deleteAll();
}
