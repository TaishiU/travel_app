import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_app/data/services/local_storage/preferences/shared_preferences_service.dart';

/// プロバイダ
final sharedPreferencesServiceImplProvider =
    Provider<SharedPreferencesServiceImpl>((ref) {
      // このProviderは、アプリケーションの起動時に`main.dart`内の`ProviderScope`で
      // 必ずオーバーライドされることを想定しています。
      // もしオーバーライドされずにアクセスされた場合、このエラーがスローされ、
      // プログラムの初期化シーケンスに問題があることを早期に検出できます。
      throw UnimplementedError(
        'sharedPreferencesServiceImplProvider must be overridden in main.dart.',
      );
    });

/// [SharedPreferencesService] の実装クラスです。
class SharedPreferencesServiceImpl implements SharedPreferencesService {
  /// コンストラクタ。
  /// 外部から`SharedPreferencesWithCache`のインスタンスを受け取ります。
  SharedPreferencesServiceImpl({required this._sharedPreferences});

  /// `SharedPreferencesWithCache`のインスタンスを保持します。
  final SharedPreferencesWithCache _sharedPreferences;

  @override
  String? getString({required String key, String? defaultValue}) {
    return _sharedPreferences.getString(key) ?? defaultValue;
  }

  @override
  Future<void> setString({required String key, required String value}) {
    return _sharedPreferences.setString(key, value);
  }

  @override
  bool? getBool({required String key, bool? defaultValue}) {
    return _sharedPreferences.getBool(key) ?? defaultValue;
  }

  @override
  Future<void> setBool({required String key, required bool value}) {
    return _sharedPreferences.setBool(key, value);
  }

  @override
  int? getInt({required String key, int? defaultValue}) {
    return _sharedPreferences.getInt(key) ?? defaultValue;
  }

  @override
  Future<void> setInt({required String key, required int value}) {
    return _sharedPreferences.setInt(key, value);
  }

  @override
  double? getDouble({required String key, double? defaultValue}) {
    return _sharedPreferences.getDouble(key) ?? defaultValue;
  }

  @override
  Future<void> setDouble({required String key, required double value}) {
    return _sharedPreferences.setDouble(key, value);
  }

  @override
  List<String>? getStringList({
    required String key,
    List<String>? defaultValue,
  }) {
    return _sharedPreferences.getStringList(key) ?? defaultValue;
  }

  @override
  Future<void> setStringList({
    required String key,
    required List<String> value,
  }) {
    return _sharedPreferences.setStringList(key, value);
  }

  @override
  Future<void> remove({required String key}) {
    return _sharedPreferences.remove(key);
  }

  @override
  Future<void> clear() {
    return _sharedPreferences.clear();
  }
}
