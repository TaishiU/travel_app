/// Braze ユーザー識別操作のインターフェース。
abstract class UserIdentityService {
  /// Brazeのアクティブユーザーを切り替える。
  /// ログイン時は userId、未ログイン時は anonymousId を渡す。
  void changeUser({required String userId});

  /// String型カスタム属性を設定する。
  void setStringCustomAttribute({required String key, required String value});

  /// Brazeユーザーセッションを終了する。
  /// push解除・ローカルデータ消去を行う。changeUser() の前に呼ぶこと。
  Future<void> logoutSession();
}
