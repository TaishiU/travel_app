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
    // 認証状態の変化（login / logout）を監視し、変化があるたびに再ビルドして
    // isLoggedIn を最新化する。addListener / removeListener の詳細は
    // AuthUseCase に隠蔽し、Notifier はライフサイクル管理のみを担う。
    final removeListener = ref
        .read(authUseCaseProvider)
        .listenToAuthChanges(onChanged: () => ref.invalidateSelf());
    ref.onDispose(removeListener);

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
