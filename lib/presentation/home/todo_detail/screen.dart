import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/design_system/components/core_app_bar.dart';
import 'package:travel_app/design_system/components/core_error.dart';
import 'package:travel_app/presentation/home/todo_detail/notifier.dart';
import 'package:travel_app/presentation/home/todo_detail/state.dart';

/// Todo詳細画面
class TodoDetailScreen extends HookConsumerWidget {
  /// コンストラクタ
  const TodoDetailScreen({required this.todoId, super.key});

  /// パス
  static const path = '/todo_detail/:todoId';

  /// TodoのID
  final int todoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(todoDetailScreenProvider(todoId));

    return Scaffold(
      appBar: const CoreAppBar(title: 'TodoDetailScreen'),
      body: switch (viewModel) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncData(:final value) => _Body(state: value),
        AsyncError(:final error) => CoreError(
          error: error,
          onPressed: () =>
              ref.read(todoDetailScreenProvider(todoId).notifier).refresh(),
        ),
      },
    );
  }
}

/// Todo詳細本体
class _Body extends HookConsumerWidget {
  const _Body({required this.state});

  final TodoDetailScreenState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todo = state.todo;

    if (todo == null) {
      return const Center(child: Text('Todo not found.'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ID: ${todo.id}', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          Text(
            'Todo: ${todo.todo}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              decoration: todo.completed ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Completed:', style: TextStyle(fontSize: 18)),
              Checkbox(
                value: todo.completed,
                onChanged: (_) => ref
                    .read(todoDetailScreenProvider(todo.id).notifier)
                    .toggleTodo(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
