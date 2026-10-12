import 'package:travel_app/data/repositories/todo/todo_repository.dart';
import 'package:travel_app/domain/use_cases/auth/auth_use_case.dart';
import 'package:travel_app/presentation/home/todo_list/state.dart';
import 'package:travel_app/utils/logger.dart';
import 'package:travel_app/utils/result.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// プロバイダ
final AsyncNotifierProvider<TodoListScreenNotifier, TodoListScreenState>
todoListScreenProvider =
    AsyncNotifierProvider.autoDispose<
      TodoListScreenNotifier,
      TodoListScreenState
    >(
      TodoListScreenNotifier.new,
    );

/// Todoリスト画面のNotifier
class TodoListScreenNotifier extends AsyncNotifier<TodoListScreenState> {
  @override
  Future<TodoListScreenState> build() async {
    final todosAsync = ref.watch(todosStreamProvider);
    final fetchResult = await ref.read(todoRepositoryProvider).fetch();

    return switch (fetchResult) {
      SuccessResult() => () {
        final todos =
            todosAsync.value ?? ref.read(todoRepositoryProvider).latestTodos;
        final searchQuery = state.value?.searchQuery ?? '';
        return TodoListScreenState(todos: todos, searchQuery: searchQuery);
      }(),
      FailureResult(:final error) => () {
        logger.e(message: '[TodoListScreenNotifier] Error caught: $error');
        throw error;
      }(),
    };
  }

  /// 検索クエリを更新する
  void updateSearchQuery({required String query}) {
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(searchQuery: query));
    }
  }

  /// Todoの完了状態を切り替える
  Future<void> toggleTodo({required int id}) async {
    await ref.read(todoRepositoryProvider).toggleTodoCompletion(id: id);
  }

  /// データの再読み込みを行う
  Future<void> refresh() async {
    await ref.read(todoRepositoryProvider).fetch(force: true);
    ref.invalidateSelf();
  }

  /// ログアウトを実行する
  Future<void> logout() async {
    await ref.read(authUseCaseProvider).logout();
  }
}
