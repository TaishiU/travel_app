import 'package:travel_app/data/services/local_storage/database/app_database.dart';

/// タスクのローカルDB操作を抽象化するサービス。
abstract class TaskLocalService {
  /// 全タスクをリアルタイム監視するストリームを返す。
  Stream<List<TaskItem>> watchAll();

  /// 全タスクを一度取得する。
  Future<List<TaskItem>> fetchAll();

  /// タスクを1件追加する。
  Future<void> insert({required String title});

  /// タスク一覧を一括upsertする。
  Future<void> upsertAll(List<TaskItem> items);

  /// 指定IDの完了状態を更新する。
  Future<void> updateCompletion({required int id, required bool completed});

  /// 全タスクを削除する。
  Future<void> deleteAll();
}
