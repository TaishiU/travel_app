import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/braze/push_token/push_token_service.dart';

/// [PushTokenService] のスタブ実装を提供するProvider。
final stubPushTokenServiceImplProvider = Provider<PushTokenService>(
  (_) => StubPushTokenServiceImpl(),
);

/// [PushTokenService] のスタブ実装。テスト・ローカル開発用。
class StubPushTokenServiceImpl implements PushTokenService {
  @override
  Future<void> register() async {}
}
