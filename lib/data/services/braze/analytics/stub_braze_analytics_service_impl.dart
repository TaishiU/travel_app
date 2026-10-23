import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/braze/analytics/braze_analytics_service.dart';

/// [BrazeAnalyticsService] のスタブ実装を提供するProvider。
final stubBrazeAnalyticsServiceImplProvider = Provider<BrazeAnalyticsService>(
  (_) => StubBrazeAnalyticsServiceImpl(),
);

/// [BrazeAnalyticsService] のスタブ実装。テスト・ローカル開発用。
class StubBrazeAnalyticsServiceImpl implements BrazeAnalyticsService {
  @override
  void logCustomEvent({
    required String eventName,
    Map<String, dynamic>? properties,
  }) {}

  @override
  void setStringAttribute({required String key, required String value}) {}

  @override
  void setBoolAttribute({required String key, required bool value}) {}

  @override
  void setIntAttribute({required String key, required int value}) {}

  @override
  void requestImmediateDataFlush() {}
}
