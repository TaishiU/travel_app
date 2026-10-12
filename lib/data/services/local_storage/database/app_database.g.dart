// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TaskItemsTable extends TaskItems
    with TableInfo<$TaskItemsTable, TaskItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _todoMeta = const VerificationMeta('todo');
  @override
  late final GeneratedColumn<String> todo = GeneratedColumn<String>(
    'todo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, todo, completed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('todo')) {
      context.handle(
        _todoMeta,
        todo.isAcceptableOrUnknown(data['todo']!, _todoMeta),
      );
    } else if (isInserting) {
      context.missing(_todoMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      todo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}todo'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
    );
  }

  @override
  $TaskItemsTable createAlias(String alias) {
    return $TaskItemsTable(attachedDatabase, alias);
  }
}

class TaskItem extends DataClass implements Insertable<TaskItem> {
  /// DB自動採番ID（主キー）。
  final int id;

  /// ユーザーID。
  final int userId;

  /// タスクのテキスト。
  final String todo;

  /// 完了フラグ。
  final bool completed;
  const TaskItem({
    required this.id,
    required this.userId,
    required this.todo,
    required this.completed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['todo'] = Variable<String>(todo);
    map['completed'] = Variable<bool>(completed);
    return map;
  }

  TaskItemsCompanion toCompanion(bool nullToAbsent) {
    return TaskItemsCompanion(
      id: Value(id),
      userId: Value(userId),
      todo: Value(todo),
      completed: Value(completed),
    );
  }

  factory TaskItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskItem(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      todo: serializer.fromJson<String>(json['todo']),
      completed: serializer.fromJson<bool>(json['completed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'todo': serializer.toJson<String>(todo),
      'completed': serializer.toJson<bool>(completed),
    };
  }

  TaskItem copyWith({int? id, int? userId, String? todo, bool? completed}) =>
      TaskItem(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        todo: todo ?? this.todo,
        completed: completed ?? this.completed,
      );
  TaskItem copyWithCompanion(TaskItemsCompanion data) {
    return TaskItem(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      todo: data.todo.present ? data.todo.value : this.todo,
      completed: data.completed.present ? data.completed.value : this.completed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskItem(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('todo: $todo, ')
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, todo, completed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskItem &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.todo == this.todo &&
          other.completed == this.completed);
}

class TaskItemsCompanion extends UpdateCompanion<TaskItem> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> todo;
  final Value<bool> completed;
  const TaskItemsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.todo = const Value.absent(),
    this.completed = const Value.absent(),
  });
  TaskItemsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String todo,
    this.completed = const Value.absent(),
  }) : userId = Value(userId),
       todo = Value(todo);
  static Insertable<TaskItem> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? todo,
    Expression<bool>? completed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (todo != null) 'todo': todo,
      if (completed != null) 'completed': completed,
    });
  }

  TaskItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<String>? todo,
    Value<bool>? completed,
  }) {
    return TaskItemsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      todo: todo ?? this.todo,
      completed: completed ?? this.completed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (todo.present) {
      map['todo'] = Variable<String>(todo.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskItemsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('todo: $todo, ')
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TaskItemsTable taskItems = $TaskItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [taskItems];
}

typedef $$TaskItemsTableCreateCompanionBuilder =
    TaskItemsCompanion Function({
      Value<int> id,
      required int userId,
      required String todo,
      Value<bool> completed,
    });
typedef $$TaskItemsTableUpdateCompanionBuilder =
    TaskItemsCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<String> todo,
      Value<bool> completed,
    });

class $$TaskItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskItemsTable> {
  $$TaskItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get todo => $composableBuilder(
    column: $table.todo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaskItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskItemsTable> {
  $$TaskItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get todo => $composableBuilder(
    column: $table.todo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaskItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskItemsTable> {
  $$TaskItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get todo =>
      $composableBuilder(column: $table.todo, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);
}

class $$TaskItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskItemsTable,
          TaskItem,
          $$TaskItemsTableFilterComposer,
          $$TaskItemsTableOrderingComposer,
          $$TaskItemsTableAnnotationComposer,
          $$TaskItemsTableCreateCompanionBuilder,
          $$TaskItemsTableUpdateCompanionBuilder,
          (TaskItem, BaseReferences<_$AppDatabase, $TaskItemsTable, TaskItem>),
          TaskItem,
          PrefetchHooks Function()
        > {
  $$TaskItemsTableTableManager(_$AppDatabase db, $TaskItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String> todo = const Value.absent(),
                Value<bool> completed = const Value.absent(),
              }) => TaskItemsCompanion(
                id: id,
                userId: userId,
                todo: todo,
                completed: completed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required String todo,
                Value<bool> completed = const Value.absent(),
              }) => TaskItemsCompanion.insert(
                id: id,
                userId: userId,
                todo: todo,
                completed: completed,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaskItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskItemsTable,
      TaskItem,
      $$TaskItemsTableFilterComposer,
      $$TaskItemsTableOrderingComposer,
      $$TaskItemsTableAnnotationComposer,
      $$TaskItemsTableCreateCompanionBuilder,
      $$TaskItemsTableUpdateCompanionBuilder,
      (TaskItem, BaseReferences<_$AppDatabase, $TaskItemsTable, TaskItem>),
      TaskItem,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TaskItemsTableTableManager get taskItems =>
      $$TaskItemsTableTableManager(_db, _db.taskItems);
}
