import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// [AppDatabase] のプロバイダ。スコープ終了時にDBを閉じる。
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// タスクアイテムを永続化するDriftテーブル定義。
class TaskItems extends Table {
  /// DB自動採番ID（主キー）。
  IntColumn get id => integer().autoIncrement()();

  /// ユーザーID。
  IntColumn get userId => integer()();

  /// タスクのテキスト。
  TextColumn get todo => text()();

  /// 完了フラグ。
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
}

/// アプリ全体で使用するDriftデータベース。
@DriftDatabase(tables: [TaskItems])
class AppDatabase extends _$AppDatabase {
  /// コンストラクタ。[executor] を省略するとデフォルト接続を使用する。
  AppDatabase({QueryExecutor? executor}) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      await m.recreateAllViews();
      for (final table in allTables) {
        await m.deleteTable(table.actualTableName);
        await m.createTable(table);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'app_database',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
