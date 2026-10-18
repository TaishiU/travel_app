import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/repositories/push_token/push_token_repository_impl.dart';
import 'package:travel_app/domain/interfaces/push_token/push_token_repository.dart';

/// [RegisterPushTokenUseCase] のプロバイダー。
final registerPushTokenUseCaseProvider = Provider<RegisterPushTokenUseCase>(
  (ref) => RegisterPushTokenUseCase(
    pushTokenRepository: ref.read(pushTokenRepositoryProvider),
  ),
);

/// Pushトークン登録のドメインユースケース。
class RegisterPushTokenUseCase {
  /// コンストラクタ。
  RegisterPushTokenUseCase({required this._pushTokenRepository});

  final PushTokenRepository _pushTokenRepository;

  /// FCMトークン（Android）またはAPNsトークン（iOS）をBrazeに登録する。
  Future<void> register() => _pushTokenRepository.register();
}
