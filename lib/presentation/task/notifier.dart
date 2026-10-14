import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/repositories/task/task_repository.dart';
import 'package:travel_app/presentation/task/state.dart';

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
    final tasksAsync = ref.watch(tasksStreamProvider);
    return TaskScreenState(tasks: tasksAsync.value ?? []);
  }

  /// タスクを追加する
  Future<void> addTask({required String title}) =>
      ref.read(taskRepositoryProvider).addTask(title: title);

  /// 完了状態を更新する
  Future<void> updateCompletion({required int id, required bool completed}) =>
      ref
          .read(taskRepositoryProvider)
          .updateCompletion(
            id: id,
            completed: completed,
          );

  /// データの再読み込みを行う
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
