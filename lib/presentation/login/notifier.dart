import 'package:travel_app/domain/use_cases/auth/auth_use_case.dart';
import 'package:travel_app/presentation/login/state.dart';
import 'package:travel_app/utils/logger.dart';
import 'package:travel_app/utils/result.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// LoginScreenNotifierのプロバイダ
final AsyncNotifierProvider<LoginScreenNotifier, LoginScreenState>
loginScreenProvider =
    AsyncNotifierProvider.autoDispose<LoginScreenNotifier, LoginScreenState>(
      LoginScreenNotifier.new,
    );

/// ログイン画面のNotifier
class LoginScreenNotifier extends AsyncNotifier<LoginScreenState> {
  @override
  Future<LoginScreenState> build() async {
    return const LoginScreenState(
      isLoggedIn: false,
    );
  }

  /// ログイン
  Future<void> login({
    required String username,
    required String password,
  }) async {
    final authUseCase = ref.read(authUseCaseProvider);
    final result = await authUseCase.login(
      username: username,
      password: password,
    );

    switch (result) {
      case SuccessResult<void>():
        // ログイン状態は AuthRepository の通知によって GoRouter が検知し、
        // 自動的にホーム画面へリダイレクトされるため、ここで state を変更する必要はないが、
        // 必要に応じて UI のフィードバック処理を行う。
        return;
      case FailureResult<void>():
        logger.e(
          message: '[LoginScreenNotifier] login failed: ${result.error}',
        );
        throw Exception();
    }
  }
}
