/// Braze カスタム属性キーの定数定義。
abstract class BrazeAttributeKey {
  /// 匿名IDのカスタム属性キー。ログイン後のユーザープロファイルに紐づける。
  static const String anonymousId = 'anonymous_id';

  /// Push通知権限状態のカスタム属性キー。
  static const String pushPermissionStatus = 'push_permission_status';
}
