/// 通知アナリティクス操作のインターフェース。
abstract class NotificationAnalyticsRepository {
  /// ログイン完了イベントを送信する。
  void trackLoginCompleted();

  /// ログアウト完了イベントを送信する。
  void trackLogoutCompleted();

  /// Push通知権限要求イベントを送信する。
  void trackPushPermissionRequested();

  /// Push通知権限許可イベントを送信する。
  void trackPushPermissionGranted();

  /// Push通知権限状態属性を更新する。
  void updatePushPermissionStatus({required String status});
}
