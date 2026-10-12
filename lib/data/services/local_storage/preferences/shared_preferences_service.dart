/// `shared_preferences`の操作を抽象化するインターフェースを定義します。
/// このインターフェースを実装することで、永続化レイヤーの依存関係を分離し、
/// テスタビリティと実装の切り替えを容易にします。
abstract class SharedPreferencesService {
  /// 指定されたキーに対応する文字列を取得します。
  /// [key]：取得する値のキー。
  /// [defaultValue]：キーが存在しない場合に返すデフォルト値。
  String? getString({required String key, String? defaultValue});

  /// 指定されたキーに文字列を保存します。
  /// [key]：保存する値のキー。
  /// [value]：保存する文字列。
  Future<void> setString({required String key, required String value});

  /// 指定されたキーに対応する真偽値を取得します。
  /// [key]：取得する値のキー。
  /// [defaultValue]：キーが存在しない場合に返すデフォルト値。
  bool? getBool({required String key, bool? defaultValue});

  /// 指定されたキーに真偽値を保存します。
  /// [key]：保存する値のキー。
  /// [value]：保存する真偽値。
  Future<void> setBool({required String key, required bool value});

  /// 指定されたキーに対応する整数を取得します。
  /// [key]：取得する値のキー。
  /// [defaultValue]：キーが存在しない場合に返すデフォルト値。
  int? getInt({required String key, int? defaultValue});

  /// 指定されたキーに整数を保存します。
  /// [key]：保存する値のキー。
  /// [value]：保存する整数。
  Future<void> setInt({required String key, required int value});

  /// 指定されたキーに対応する浮動小数点数を取得します。
  /// [key]：取得する値のキー。
  /// [defaultValue]：キーが存在しない場合に返すデフォルト値。
  double? getDouble({required String key, double? defaultValue});

  /// 指定されたキーに浮動小数点数を保存します。
  /// [key]：保存する値のキー。
  /// [value]：保存する浮動小数点数。
  Future<void> setDouble({required String key, required double value});

  /// 指定されたキーに対応する文字列リストを取得します。
  /// [key]：取得する値のキー。
  /// [defaultValue]：キーが存在しない場合に返すデフォルト値。
  List<String>? getStringList({
    required String key,
    List<String>? defaultValue,
  });

  /// 指定されたキーに文字列リストを保存します。
  /// [key]：保存する値のキー。
  /// [value]：保存する文字列リスト。
  Future<void> setStringList({
    required String key,
    required List<String> value,
  });

  /// 指定されたキーに対応する値を削除します。
  /// [key]：削除する値のキー。
  Future<void> remove({required String key});

  /// すべての永続化された値をクリアします。
  Future<void> clear();
}
