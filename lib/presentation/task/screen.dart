import 'package:travel_app/design_system/components/core_app_bar.dart';
import 'package:travel_app/design_system/components/core_error.dart';
import 'package:travel_app/domain/entities/task/task.dart';
import 'package:travel_app/presentation/task/notifier.dart';
import 'package:travel_app/presentation/task/state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// タスク画面
class TaskScreen extends HookConsumerWidget {
  /// コンストラクタ
  const TaskScreen({super.key});

  /// パス
  static const path = '/task';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(taskScreenProvider);

    return Scaffold(
      appBar: const CoreAppBar(title: 'TaskScreen'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context: context, ref: ref),
        child: const Icon(Icons.add),
      ),
      body: switch (viewModel) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncData(:final value) => _Body(state: value),
        AsyncError(:final error) => CoreError(
          error: error,
          onPressed: () => ref.read(taskScreenProvider.notifier).refresh(),
        ),
      },
    );
  }

  Future<void> _showAddTaskDialog({
    required BuildContext context,
    required WidgetRef ref,
  }) => showDialog<void>(
    context: context,
    builder: (_) => _AddTaskDialog(
      onAdd: (title) =>
          ref.read(taskScreenProvider.notifier).addTask(title: title),
    ),
  );
}

class _AddTaskDialog extends StatefulWidget {
  const _AddTaskDialog({required this.onAdd});

  final Future<void> Function(String title) onAdd;

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('タスクを追加'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'タイトルを入力'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () async {
            final title = _controller.text.trim();
            if (title.isNotEmpty) {
              await widget.onAdd(title);
              if (!context.mounted) return;
              Navigator.of(context).pop();
            }
          },
          child: const Text('追加'),
        ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final TaskScreenState state;

  @override
  Widget build(BuildContext context) {
    if (state.tasks.isEmpty) {
      return const Center(child: Text('タスクがありません'));
    }
    return ListView.builder(
      itemCount: state.tasks.length,
      itemBuilder: (context, index) {
        final task = state.tasks[index];
        return _TaskItem(task: task, key: ValueKey(task.id));
      },
    );
  }
}

class _TaskItem extends ConsumerWidget {
  const _TaskItem({required this.task, super.key});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CheckboxListTile(
      value: task.completed,
      title: Text(task.title),
      onChanged: (completed) async {
        if (completed == null) return;
        await ref
            .read(taskScreenProvider.notifier)
            .updateCompletion(id: task.id, completed: completed);
      },
    );
  }
}
