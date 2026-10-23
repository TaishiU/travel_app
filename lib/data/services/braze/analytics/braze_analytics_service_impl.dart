import 'package:braze_plugin/braze_plugin.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/braze/analytics/braze_analytics_service.dart';
import 'package:travel_app/data/services/braze/braze_plugin_provider.dart';

/// [BrazeAnalyticsService] の実装クラスを提供するProvider。
final brazeAnalyticsServiceImplProvider = Provider<BrazeAnalyticsService>(
  (ref) =>
      BrazeAnalyticsServiceImpl(brazePlugin: ref.read(brazePluginProvider)),
);

/// [BrazeAnalyticsService] の実装クラス。
class BrazeAnalyticsServiceImpl implements BrazeAnalyticsService {
  /// コンストラクタ。
  BrazeAnalyticsServiceImpl({required this._brazePlugin});

  final BrazePlugin _brazePlugin;

  @override
  void logCustomEvent({
    required String eventName,
    Map<String, dynamic>? properties,
  }) {
    _brazePlugin.logCustomEvent(eventName, properties: properties);
  }

  @override
  void setStringAttribute({required String key, required String value}) {
    _brazePlugin.setStringCustomUserAttribute(key, value);
  }

  @override
  void setBoolAttribute({required String key, required bool value}) {
    _brazePlugin.setBoolCustomUserAttribute(key, value);
  }

  @override
  void setIntAttribute({required String key, required int value}) {
    _brazePlugin.setIntCustomUserAttribute(key, value);
  }

  @override
  void requestImmediateDataFlush() {
    _brazePlugin.requestImmediateDataFlush();
  }
}
