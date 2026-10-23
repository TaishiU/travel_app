/// Braze カスタムイベント名の定数定義。
abstract class BrazeEventKey {
  /// ログイン完了イベント名。
  static const String loginCompleted = 'login_completed';

  /// ログアウト完了イベント名。
  static const String logoutCompleted = 'logout_completed';

  /// Push通知権限要求イベント名。
  static const String pushPermissionRequested = 'push_permission_requested';

  /// Push通知権限許可イベント名。
  static const String pushPermissionGranted = 'push_permission_granted';
}
