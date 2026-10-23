import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/repositories/auth/auth_repository_impl.dart';
import 'package:travel_app/data/repositories/notification/notification_analytics_repository_impl.dart';
import 'package:travel_app/utils/result.dart';

/// AuthUseCaseのプロバイダ
final authUseCaseProvider = Provider<AuthUseCase>((ref) {
  return AuthUseCase(ref: ref);
});

/// 認証関連のビジネスロジックを担当するUseCase
class AuthUseCase {
  /// コンストラクタ
  AuthUseCase({required this.ref});

  /// Provider参照用のref
  final Ref ref;

  /// ログイン済みかどうかを確認する
  Future<bool> checkIsLoggedIn() async {
    return await ref.read(authRepositoryProvider).isLoggedIn;
  }

  /// ログインを実行し、pending_deep_link を返す
  Future<Result<String?>> login({
    required String email,
    required String password,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.login(email: email, password: password);
    switch (result) {
      case SuccessResult<void>():
        ref.read(notificationAnalyticsRepositoryProvider).trackLoginCompleted();
        return SuccessResult(repo.getAndClearPendingDeepLink());
      case FailureResult<void>():
        return FailureResult(result.error);
    }
  }

  /// 新規登録を実行し、pending_deep_link を返す
  Future<Result<String?>> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.register(
      email: email,
      password: password,
      displayName: displayName,
    );
    switch (result) {
      case SuccessResult<void>():
        return SuccessResult(repo.getAndClearPendingDeepLink());
      case FailureResult<void>():
        return FailureResult(result.error);
    }
  }

  /// ログアウトを実行する
  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    ref.read(notificationAnalyticsRepositoryProvider).trackLogoutCompleted();
  }
}
