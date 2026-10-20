import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/domain/use_cases/auth/auth_use_case.dart';
import 'package:travel_app/presentation/profile/state.dart';
import 'package:travel_app/presentation/profile/use_case.dart';

/// プロバイダ
final AsyncNotifierProvider<ProfileScreenNotifier, ProfileScreenState>
profileScreenProvider =
    AsyncNotifierProvider.autoDispose<
      ProfileScreenNotifier,
      ProfileScreenState
    >(ProfileScreenNotifier.new);

/// プロフィール画面のNotifier
class ProfileScreenNotifier extends AsyncNotifier<ProfileScreenState> {
  @override
  Future<ProfileScreenState> build() async {
    return await ref.read(profileScreenUseCaseProvider).initState();
  }

  /// データの再読み込みを行う
  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  /// ログアウトを実行する
  Future<void> logout() async {
    await ref.read(authUseCaseProvider).logout();
  }
}
