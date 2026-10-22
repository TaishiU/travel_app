import 'package:braze_plugin/braze_plugin.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/braze/braze_plugin_provider.dart';
import 'package:travel_app/data/services/braze/user_identity/user_identity_service.dart';

/// [UserIdentityService] の実装クラスを提供するProvider。
final userIdentityServiceImplProvider = Provider<UserIdentityService>(
  (ref) => UserIdentityServiceImpl(brazePlugin: ref.read(brazePluginProvider)),
);

/// [UserIdentityService] の実装クラス。
class UserIdentityServiceImpl implements UserIdentityService {
  /// コンストラクタ
  UserIdentityServiceImpl({required this._brazePlugin});

  final BrazePlugin _brazePlugin;

  @override
  void changeUser({required String userId}) {
    _brazePlugin.changeUser(userId);
  }

  @override
  void setStringCustomAttribute({required String key, required String value}) {
    _brazePlugin.setStringCustomUserAttribute(key, value);
  }

  @override
  Future<void> logoutSession() {
    return _brazePlugin.logout();
  }
}
