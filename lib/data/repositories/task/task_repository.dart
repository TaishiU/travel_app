import 'package:travel_app/data/services/local_storage/database/app_database.dart';
import 'package:travel_app/data/services/local_storage/database/task/task_local_service.dart';
import 'package:travel_app/data/services/local_storage/database/task/task_local_service_impl.dart';
import 'package:travel_app/domain/entities/task/task.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// [TaskRepository] のプロバイダ。
final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => TaskRepository(
    taskLocalService: ref.read(taskLocalServiceImplProvider),
  ),
);

/// タスク一覧のSSOTを提供するStreamProvider。
final tasksStreamProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).tasksStream;
});

/// タスクのSSOTを管理するリポジトリ。
class TaskRepository {
  /// コンストラクタ。
  TaskRepository({required this.taskLocalService});

  /// ローカルDBサービス。
  final TaskLocalService taskLocalService;

  /// タスク一覧のストリーム。
  Stream<List<Task>> get tasksStream => taskLocalService.watchAll().map(
    (items) => items.map((item) => _toEntity(item: item)).toList(),
  );

  /// タスクを追加する。
  Future<void> addTask({required String title}) =>
      taskLocalService.insert(title: title);

  /// 完了状態を更新する。
  Future<void> updateCompletion({required int id, required bool completed}) =>
      taskLocalService.updateCompletion(id: id, completed: completed);

  Task _toEntity({required TaskItem item}) => Task(
    id: item.id,
    userId: item.userId,
    title: item.todo,
    completed: item.completed,
  );
}
