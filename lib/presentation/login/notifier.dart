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

  /// ログイン。戻り値は pending_deep_link（なければ null）
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final isLoading = switch (state) {
      AsyncData(:final value) => value.isLoading,
      _ => false,
    };
    if (isLoading) return null;
    state = const AsyncData(LoginScreenState(isLoading: true));
    final result = await ref
        .read(authUseCaseProvider)
        .login(email: email, password: password);
    switch (result) {
      case SuccessResult<String?>():
        state = const AsyncData(LoginScreenState());
        return result.value;
      case FailureResult<String?>(:final error):
        logger.e(message: '[LoginScreenNotifier] auth failed: $error');
        state = AsyncError(error, StackTrace.current);
        return null;
    }
  }

  /// 新規登録。戻り値は pending_deep_link（なければ null）
  Future<String?> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final isLoading = switch (state) {
      AsyncData(:final value) => value.isLoading,
      _ => false,
    };
    if (isLoading) return null;
    state = const AsyncData(LoginScreenState(isLoading: true));
    final result = await ref
        .read(authUseCaseProvider)
        .register(email: email, password: password, displayName: displayName);
    switch (result) {
      case SuccessResult<String?>():
        state = const AsyncData(LoginScreenState());
        return result.value;
      case FailureResult<String?>(:final error):
        logger.e(message: '[LoginScreenNotifier] register failed: $error');
        state = AsyncError(error, StackTrace.current);
        return null;
    }
  }
}
