import 'package:travel_app/design_system/components/core_app_bar.dart';
import 'package:travel_app/design_system/components/core_error.dart';
import 'package:travel_app/presentation/home/todo_list/notifier.dart';
import 'package:travel_app/presentation/home/todo_list/state.dart';
import 'package:travel_app/router/navigation_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Todoリスト画面
class TodoListScreen extends HookConsumerWidget {
  /// コンストラクタ
  const TodoListScreen({super.key});

  /// パス
  static const path = '/todo_list';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(todoListScreenProvider);

    return Scaffold(
      appBar: CoreAppBar(
        title: 'TodoListScreen',
        actions: [
          if (kDebugMode)
            IconButton(
              onPressed: () => context.toDebugMenuScreen(),
              icon: const Icon(Icons.bug_report_outlined),
            ),
          IconButton(
            onPressed: () async {
              await ref.read(todoListScreenProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: switch (viewModel) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncData(:final value) => _Body(state: value),
        AsyncError(:final error) => CoreError(
          error: error,
          onPressed: () => ref.read(todoListScreenProvider.notifier).refresh(),
        ),
      },
    );
  }
}

/// Todoリスト本体
class _Body extends HookConsumerWidget {
  const _Body({required this.state});

  final TodoListScreenState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = state.todos;

    if (todos.isEmpty) {
      return const Center(child: Text('No data found.'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(todoListScreenProvider.notifier).refresh(),
      child: ListView.separated(
        // ListViewが短くてもスクロール可能にして、Pull to refreshを常に有効にする
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return InkWell(
            onTap: () => context.toTodoDetailScreen(todoId: todo.id),
            child: Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: todo.completed ? Colors.blue.shade100 : Colors.transparent,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${todo.id}: ${todo.todo}',
                      style: TextStyle(
                        fontSize: 18,
                        decoration: todo.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  Checkbox(
                    value: todo.completed,
                    onChanged: (value) async {
                      if (value != null) {
                        await ref
                            .read(todoListScreenProvider.notifier)
                            .toggleTodo(id: todo.id);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Container(
            height: 1,
            width: double.infinity,
            color: Colors.grey.shade300,
          );
        },
      ),
    );
  }
}
