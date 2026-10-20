import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/repositories/auth/auth_repository_impl.dart';
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
    final repo = ref.read(authRepositoryProvider);

    // rebuild は「このプロバイダを破棄して再ビルドせよ」という命令を
    // 1 つの関数オブジェクトにまとめたもの。
    // addListener / removeListener で同一インスタンスを渡す必要があるため変数に保持する。
    void rebuild() => ref.invalidateSelf();

    // AuthRepository は Listenable を実装しており、login() / logout() 内の
    // notifyListeners() 呼び出し時に登録済みリスナーを全て呼び出す。
    // ここで rebuild を登録することで、認証状態が変化するたびに
    // このプロバイダが再ビルドされ isLoggedIn が最新値に更新される。
    repo.addListener(rebuild);

    // プロバイダが破棄されるとき（画面離脱・再ビルド直前）にリスナーを解除する。
    // これがないと repo に古い rebuild 参照が残り続け、メモリリーク・二重呼び出しの原因になる。
    // Riverpod は build() 再実行前に前回登録した onDispose を自動実行するため、
    // watch による再ビルドが繰り返されてもリスナーが累積することはない。
    ref.onDispose(() => repo.removeListener(rebuild));

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
