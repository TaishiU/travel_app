/// Braze アナリティクス操作のインターフェース。
abstract class BrazeAnalyticsService {
  /// カスタムイベントを送信する。
  void logCustomEvent({
    required String eventName,
    Map<String, dynamic>? properties,
  });

  /// String型カスタム属性を設定する。
  void setStringAttribute({required String key, required String value});

  /// Bool型カスタム属性を設定する。
  void setBoolAttribute({required String key, required bool value});

  /// Int型カスタム属性を設定する。
  void setIntAttribute({required String key, required int value});

  /// キューに積まれたデータをBrazeサーバーへ即時送信する。
  void requestImmediateDataFlush();
}
