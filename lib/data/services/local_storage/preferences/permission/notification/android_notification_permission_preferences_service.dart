/// Android 通知権限状態の永続化サービスを抽象化するインターフェース。
/// Android の通知権限3状態（未要求 / 1回目拒否 / 恒久拒否）を
/// SharedPreferences フラグで区別するための契約を定義する。
///
/// iOS では `permission_handler` の `PermissionStatus.denied` が
/// `UNAuthorizationStatus.notDetermined`（未要求）と1対1で対応するため、
/// フラグ管理は不要。このインターフェースは Android 専用。
abstract class AndroidNotificationPermissionPreferencesService {
  /// `request()` を呼び出したかどうかを取得する。
  bool getRequested();

  /// `request()` を呼び出したことを保存する。
  Future<void> setRequested({required bool value});

  /// `request()` が `permanentlyDenied` を返したかどうかを取得する。
  bool getPermanentlyDenied();

  /// `request()` が `permanentlyDenied` を返したことを保存する。
  Future<void> setPermanentlyDenied({required bool value});
}
