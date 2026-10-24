import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/domain/entities/task/task.dart';
import 'package:travel_app/domain/use_cases/auth/auth_use_case.dart';
import 'package:travel_app/presentation/task/state.dart';

/// TaskScreenUseCaseのプロバイダ
final taskScreenUseCaseProvider = Provider<TaskScreenUseCase>(
  (ref) => TaskScreenUseCase(ref: ref),
);

/// タスク画面の関心事に属すロジックを担当するUseCase
///
/// タスクのドメイン操作（追加・完了更新）は TaskUseCase が担う。
/// ここでは UI State の構築（initState）という画面固有の関心事のみを扱う。
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
}
