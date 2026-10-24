import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/domain/use_cases/auth/auth_use_case.dart';
import 'package:travel_app/domain/use_cases/task/task_use_case.dart';
import 'package:travel_app/presentation/task/state.dart';
import 'package:travel_app/presentation/task/use_case.dart';

/// プロバイダ
final AsyncNotifierProvider<TaskScreenNotifier, TaskScreenState>
taskScreenProvider =
    AsyncNotifierProvider.autoDispose<TaskScreenNotifier, TaskScreenState>(
      TaskScreenNotifier.new,
    );

/// タスク画面のNotifier
class TaskScreenNotifier extends AsyncNotifier<TaskScreenState> {
  @override
  Future<TaskScreenState> build() async {
    // 認証状態の変化（login / logout）を監視し、変化があるたびに再ビルドして
    // isLoggedIn を最新化する。addListener / removeListener の詳細は
    // AuthUseCase に隠蔽し、Notifier はライフサイクル管理のみを担う。
    final removeListener = ref
        .read(authUseCaseProvider)
        .listenToAuthChanges(onChanged: () => ref.invalidateSelf());
    ref.onDispose(removeListener);

    return await ref
        .read(taskScreenUseCaseProvider)
        .initState(
          // ref.watch はリアクティブな依存を作るため UseCase ではなく build() で行う。
          // tasksStreamProvider が更新されるたびに build() が再実行され、最新タスク一覧が渡される。
          tasksAsync: ref.watch(tasksStreamProvider),
        );
  }

  /// タスクを追加する
  Future<void> addTask({required String title}) =>
      ref.read(taskUseCaseProvider).addTask(title: title);

  /// 完了状態を更新する
  Future<void> updateCompletion({required int id, required bool completed}) =>
      ref
          .read(taskUseCaseProvider)
          .updateCompletion(id: id, completed: completed);

  /// データの再読み込みを行う
  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  /// ログアウトを実行する
  Future<void> logout() async {
    await ref.read(authUseCaseProvider).logout();
  }
}
