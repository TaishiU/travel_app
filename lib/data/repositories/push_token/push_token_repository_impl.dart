import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/braze/push_token/push_token_service.dart';
import 'package:travel_app/data/services/braze/push_token/push_token_service_impl.dart';
import 'package:travel_app/domain/interfaces/push_token/push_token_repository.dart';

/// [PushTokenRepository] のプロバイダー。
final pushTokenRepositoryProvider = Provider<PushTokenRepository>(
  (ref) => PushTokenRepositoryImpl(
    pushTokenService: ref.read(pushTokenServiceImplProvider),
  ),
);

/// [PushTokenRepository] の実装クラス。
/// UseCase からの操作を [PushTokenService] に委譲する。
class PushTokenRepositoryImpl implements PushTokenRepository {
  /// コンストラクタ。
  PushTokenRepositoryImpl({required this._pushTokenService});

  final PushTokenService _pushTokenService;

  @override
  Future<void> register() => _pushTokenService.register();
}
