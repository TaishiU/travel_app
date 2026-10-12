import 'package:travel_app/data/services/local_storage/database/app_database.dart';
import 'package:travel_app/data/services/local_storage/database/task/task_local_service.dart';
import 'package:drift/drift.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// [TaskLocalService] のプロバイダ。
final taskLocalServiceImplProvider = Provider<TaskLocalServiceImpl>(
  (ref) => TaskLocalServiceImpl(db: ref.read(appDatabaseProvider)),
);

/// [TaskLocalService] の実装。Driftを使用してSQLiteへアクセスする。
class TaskLocalServiceImpl implements TaskLocalService {
  /// コンストラクタ。
  TaskLocalServiceImpl({required AppDatabase db}) : _db = db;

  final AppDatabase _db;

  @override
  Stream<List<TaskItem>> watchAll() => _db.select(_db.taskItems).watch();

  @override
  Future<List<TaskItem>> fetchAll() => _db.select(_db.taskItems).get();

  @override
  Future<void> insert({required String title}) async {
    await _db
        .into(_db.taskItems)
        .insert(
          TaskItemsCompanion.insert(
            userId: 0,
            todo: title,
            completed: const Value(false),
          ),
        );
  }

  @override
  Future<void> upsertAll(List<TaskItem> items) async {
    await _db.batch(
      (batch) => batch.insertAllOnConflictUpdate(_db.taskItems, items),
    );
  }

  @override
  Future<void> updateCompletion({
    required int id,
    required bool completed,
  }) async {
    await (_db.update(_db.taskItems)..where((t) => t.id.equals(id))).write(
      TaskItemsCompanion(completed: Value(completed)),
    );
  }

  @override
  Future<void> deleteAll() => _db.delete(_db.taskItems).go();
}
