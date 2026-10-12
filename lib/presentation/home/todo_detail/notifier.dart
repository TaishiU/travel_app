import 'dart:async';

import 'package:travel_app/data/repositories/todo/todo_repository.dart';
import 'package:travel_app/presentation/home/todo_detail/state.dart';
import 'package:travel_app/utils/logger.dart';
import 'package:travel_app/utils/result.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/misc.dart';

/// プロバイダ（ .family で todoId を受け取る）
final AsyncNotifierProviderFamily<
  TodoDetailScreenNotifier,
  TodoDetailScreenState,
  int
>
todoDetailScreenProvider = AsyncNotifierProvider.autoDispose
    .family<TodoDetailScreenNotifier, TodoDetailScreenState, int>(
      (arg) => TodoDetailScreenNotifier(todoId: arg),
    );

/// Todo詳細画面のNotifier
class TodoDetailScreenNotifier extends AsyncNotifier<TodoDetailScreenState> {
  /// コンストラクタ
  TodoDetailScreenNotifier({required this.todoId});

  /// プロバイダの .family 引数となる todoId
  final int todoId;

  @override
  FutureOr<TodoDetailScreenState> build() async {
    // 1. SSOT (StreamProvider) を watch する
    final todosAsync = ref.watch(todosStreamProvider);

    // 2. 該当する Todo を抽出する
    final todo = todosAsync.value?.where((t) => t.id == todoId).firstOrNull;

    if (todo != null) {
      return TodoDetailScreenState(todo: todo);
    }

    // 3. まだデータがない（または取得中）の場合は fetch を試みる
    final fetchResult = await ref.read(todoRepositoryProvider).fetch();

    return switch (fetchResult) {
      SuccessResult() => () {
        // fetch後に再度抽出を試みる
        final latestTodo = ref
            .read(todoRepositoryProvider)
            .latestTodos
            .where((t) => t.id == todoId)
            .firstOrNull;

        if (latestTodo == null) {
          throw Exception('Todo not found');
        }

        return TodoDetailScreenState(todo: latestTodo);
      }(),
      FailureResult(:final error) => () {
        logger.e(message: '[TodoDetailScreenNotifier] Error caught: $error');
        throw error;
      }(),
    };
  }

  /// Todoの完了状態を切り替える (一覧画面と同様にRepositoryを更新する)
  Future<void> toggleTodo() async {
    await ref.read(todoRepositoryProvider).toggleTodoCompletion(id: todoId);
  }

  /// データの再読み込みを行う
  Future<void> refresh() async {
    await ref.read(todoRepositoryProvider).fetch(force: true);
    ref.invalidateSelf();
  }
}
