import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/repositories/task/task_repository.dart';
import 'package:travel_app/domain/entities/task/task.dart';
import 'package:travel_app/domain/use_cases/auth/auth_use_case.dart';
import 'package:travel_app/presentation/task/state.dart';

/// TaskScreenUseCaseのプロバイダ
final taskScreenUseCaseProvider = Provider<TaskScreenUseCase>(
  (ref) => TaskScreenUseCase(ref: ref),
);

/// タスク画面の関心事に属すロジックを担当するUseCase
class TaskScreenUseCase {
  /// コンストラクタ
  TaskScreenUseCase({required this.ref});

  /// Provider参照用のref
  final Ref ref;

  /// タスク画面の初期状態を構築する
  ///
  /// [tasksAsync]: Notifier が ref.watch で購読中のタスク一覧。
  /// ref.watch はリアクティブな依存を作るため Notifier の build() で行い、
  /// その結果をここで受け取る。
  Future<TaskScreenState> initState({
    required AsyncValue<List<Task>> tasksAsync,
  }) async {
    final isLoggedIn = await ref.read(authUseCaseProvider).checkIsLoggedIn();
    return TaskScreenState(
      tasks: tasksAsync.value ?? [],
      isLoggedIn: isLoggedIn,
    );
  }

  /// タスクを追加する
  Future<void> addTask({required String title}) =>
      ref.read(taskRepositoryProvider).addTask(title: title);

  /// 完了状態を更新する
  Future<void> updateCompletion({required int id, required bool completed}) =>
      ref
          .read(taskRepositoryProvider)
          .updateCompletion(id: id, completed: completed);
}
