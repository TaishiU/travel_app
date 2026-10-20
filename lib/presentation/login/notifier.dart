import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/domain/use_cases/auth/auth_use_case.dart';
import 'package:travel_app/presentation/login/state.dart';
import 'package:travel_app/utils/logger.dart';
import 'package:travel_app/utils/result.dart';

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
    return const LoginScreenState();
  }

  /// ログイン
  Future<void> login({required String email, required String password}) async {
    final isLoading = switch (state) {
      AsyncData(:final value) => value.isLoading,
      _ => false,
    };
    if (isLoading) return;
    state = const AsyncData(LoginScreenState(isLoading: true));
    final result = await ref
        .read(authUseCaseProvider)
        // .login(email: email, password: password);
        .login(email: 'test3@example.com', password: 'password123');
    switch (result) {
      case SuccessResult<String?>():
        state = const AsyncData(LoginScreenState());
      case FailureResult<String?>(:final error):
        logger.e(message: '[LoginScreenNotifier] login failed: $error');
        state = AsyncError(error, StackTrace.current);
    }
  }

  /// 新規登録
  Future<void> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final isLoading = switch (state) {
      AsyncData(:final value) => value.isLoading,
      _ => false,
    };
    if (isLoading) return;
    state = const AsyncData(LoginScreenState(isLoading: true));
    final result = await ref
        .read(authUseCaseProvider)
        // .register(email: email, password: password,
        // displayName: displayName);
        .register(
          email: 'test3@example.com',
          password: 'password123',
          displayName: displayName,
        );
    switch (result) {
      case SuccessResult<String?>():
        state = const AsyncData(LoginScreenState());
      case FailureResult<String?>(:final error):
        logger.e(message: '[LoginScreenNotifier] register failed: $error');
        state = AsyncError(error, StackTrace.current);
    }
  }
}
