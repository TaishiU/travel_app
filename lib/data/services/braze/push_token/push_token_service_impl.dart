import 'dart:io';

import 'package:braze_plugin/braze_plugin.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/braze/braze_plugin_provider.dart';
import 'package:travel_app/data/services/braze/push_token/push_token_service.dart';

/// [FirebaseMessaging.instance] を提供するProvider。テスト時に差し替え可能。
final firebaseMessagingProvider = Provider<FirebaseMessaging>(
  (_) => FirebaseMessaging.instance, // coverage:ignore-line
);

/// [PushTokenService] の実装クラスを提供するProvider。
final pushTokenServiceImplProvider = Provider<PushTokenService>(
  (ref) => PushTokenServiceImpl(
    brazePlugin: ref.read(brazePluginProvider),
    firebaseMessaging: ref.read(firebaseMessagingProvider),
    isAndroid: Platform.isAndroid,
  ),
);

/// [PushTokenService] の実装クラス。
/// AndroidはFCMトークンを取得してBrazeに登録する。
/// iOSはpush.automation = trueによる自動処理に委ねる。
class PushTokenServiceImpl implements PushTokenService {
  /// コンストラクタ。
  /// Androidの場合はトークン更新リスナーを設定する。
  PushTokenServiceImpl({
    required this._brazePlugin,
    required this._firebaseMessaging,
    required this._isAndroid,
  }) {
    if (_isAndroid) {
      // トークン更新時にBrazeへ再登録
      _firebaseMessaging.onTokenRefresh.listen(
        _brazePlugin.registerPushToken,
      );
    }
  }

  final BrazePlugin _brazePlugin;
  final FirebaseMessaging _firebaseMessaging;
  final bool _isAndroid;

  @override
  Future<void> register() async {
    if (!_isAndroid) return;
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      _brazePlugin.registerPushToken(token);
    }
  }
}
