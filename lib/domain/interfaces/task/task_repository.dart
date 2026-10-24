import 'package:travel_app/domain/entities/task/task.dart';

/// タスクリポジトリのインターフェース。
abstract class TaskRepository {
  /// タスク一覧のストリーム。
  Stream<List<Task>> get tasksStream;

  /// タスクを追加する。
  Future<void> addTask({required String title});

  /// 完了状態を更新する。
  Future<void> updateCompletion({required int id, required bool completed});
}
