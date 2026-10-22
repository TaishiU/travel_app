import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/braze/user_identity/user_identity_service.dart';

/// [UserIdentityService] のスタブ実装を提供するProvider。
final stubUserIdentityServiceImplProvider = Provider<UserIdentityService>(
  (_) => StubUserIdentityServiceImpl(),
);

/// [UserIdentityService] のスタブ実装。テスト・ローカル開発用。
class StubUserIdentityServiceImpl implements UserIdentityService {
  @override
  void changeUser({required String userId}) {}

  @override
  void setStringCustomAttribute({required String key, required String value}) {}

  @override
  Future<void> logoutSession() async {}
}
