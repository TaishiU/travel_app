import 'package:freezed_annotation/freezed_annotation.dart';

part 'todos.freezed.dart';
part 'todos.g.dart';

/// 複数のTodoアイテムを格納するリストを表すエンティティ
@freezed
abstract class Todos with _$Todos {
  /// コンストラクタ
  const factory Todos({
    /// 単一のTodoアイテムのリスト
    required List<Todo> todos,
  }) = _Todos;

  /// JSONから生成
  factory Todos.fromJson(Map<String, Object?> json) => _$TodosFromJson(json);
}

/// 単一のTodoアイテムを表すエンティティ
@freezed
abstract class Todo with _$Todo {
  /// コンストラクタ
  const factory Todo({
    /// ID
    required int id,

    /// ユーザーID
    required int userId,

    /// タイトル
    required String todo,

    /// 完了したかどうか
    required bool completed,
  }) = _Todo;

  /// JSONから生成
  factory Todo.fromJson(Map<String, Object?> json) => _$TodoFromJson(json);
}
