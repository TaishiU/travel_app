import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/web_api/todos/dto.dart';
import 'package:travel_app/data/services/web_api/todos/service.dart';
import 'package:travel_app/data/services/web_api/todos/service_impl.dart'
    show todosApiServiceProvider;
import 'package:travel_app/domain/entities/todos/todos.dart';
import 'package:travel_app/domain/errors/app_error.dart';
import 'package:travel_app/utils/logger.dart';
import 'package:travel_app/utils/result.dart';

/// RepositoryのProvider
final todoRepositoryProvider = Provider<TodoRepository>(
  (ref) => TodoRepository(todoApiService: ref.watch(todosApiServiceProvider)),
);

/// SSOTであるTodoリストのStreamを公開するProvider
final todosStreamProvider = StreamProvider<List<Todo>>((ref) {
  return ref.watch(todoRepositoryProvider).todosStream;
});

/// リポジトリクラス (SSOTの管理者)
class TodoRepository {
  /// コンストラクタ
  TodoRepository({required this.todoApiService});

  /// Todosに関連するAPI通信を抽象化したサービスインターフェース。
  final TodosApiService todoApiService;

  /// 内部でTodoリストをキャッシュする。これがSSOTの実体。
  List<Todo> _todos = [];

  /// すでに一度APIから取得したかどうかのフラグ
  bool _isFetched = false;

  /// Todoリストの変更を外部に通知するためのStreamController。
  final _todosStreamController = StreamController<List<Todo>>.broadcast();

  /// 外部公開用のTodoリストのStream。UI層はこれを購読する。
  Stream<List<Todo>> get todosStream => _todosStreamController.stream;

  /// 現在キャッシュされているTodoリストを即座に取得するゲッター
  List<Todo> get latestTodos => List.unmodifiable(_todos);

  /// [Todo] 配列を取得してSSOTのキャッシュを更新
  /// [force] が true の場合は、キャッシュがあっても強制的にAPIを叩く
  Future<Result<void>> fetch({bool force = false}) async {
    // すでに取得済みであり、かつ強制更新でない場合は何もしない
    if (_isFetched && !force) {
      return const SuccessResult(null);
    }

    try {
      final result = await todoApiService.fetch();

      switch (result) {
        case SuccessResult<TodosDto>():
          final todoList = result.value.todos!
              .map((dto) => _toEntity(dto: dto))
              .whereType<Todo>()
              .toList();

          // SSOT（キャッシュ）を更新
          _todos = todoList;
          _isFetched = true;
          // Streamに新しいリストを流して、購読者に通知
          _todosStreamController.add(_todos);

          return const SuccessResult(null);
        case FailureResult<TodosDto>():
          logger.e(message: '[TodoRepository] ${result.error}');
          return FailureResult(AppError.from(result.error));
      }
    } on Exception catch (error) {
      return FailureResult(AppError.from(error));
    }
  }

  /// 指定したIDのTodoの完了状態を切り替える
  Future<void> toggleTodoCompletion({required int id}) async {
    // 1. キャッシュ内の該当データを更新する
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) {
      return;
    }
    final targetTodo = _todos[index];
    // 新しいインスタンスを生成してリストを差し替える（Immutableな更新）
    _todos[index] = targetTodo.copyWith(completed: !targetTodo.completed);

    // 2. Streamに新しいリストを流して通知する
    // 不変（Immutable）なリストとして流すことで
    // UI側でリストを操作（add, remove）しようとするとエラーが発生するため、
    //「データ更新は必ずリポジトリ経由で行う」という SSOT の原則を強制できる
    _todosStreamController.add(List.unmodifiable(_todos));

    // 本来はここでAPIに対しても更新リクエストを送るが、
    // 今回はメモリ上のSSOT更新とStream通知を優先する
  }

  /// [TodoDto] を [Todo] エンティティに変換します。
  Todo? _toEntity({required TodoDto dto}) {
    // 必須フィールドが欠損している場合はnullを返す
    if (dto.userId == null || dto.id == null) {
      return null;
    }

    return Todo(
      userId: dto.userId!,
      id: dto.id!,
      todo: dto.todo ?? '',
      completed: dto.completed ?? false,
    );
  }
}

// import 'package:travel_app/data/services/web_api/todos/service.dart';
// import 'package:travel_app/data/services/web_api/todos/service_impl.dart';
// import 'package:travel_app/data/services/web_api/todos/dto.dart';
// import 'package:travel_app/domain/entities/todos/todos.dart';
// import 'package:travel_app/utils/logger.dart';
// import 'package:travel_app/utils/result.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
//
// /// プロバイダ
// final todoRepositoryProvider = Provider<TodoRepository>(
//       (ref) => TodoRepository(
//     todoApiService: ref.read(todosApiServiceImplProvider),
//   ),
// );
//
// /// リポジトリクラス
// class TodoRepository {
//   /// コンストラクタ
//   TodoRepository({required this.todoApiService});
//
//   /// Todosに関連するAPI通信を抽象化したサービスインターフェース。
//   final TodosApiService todoApiService;
//
//   /// [Todos] 配列を取得
//   Future<Result<Todos>> fetch() async {
//     try {
//       final result = await todoApiService.fetch();
//
//       switch (result) {
//         case SuccessResult<TodosDto>():
//           final todoList = result.value.todos!
//               .map(_toEntity)
//               .whereType<Todo>()
//               .toList();
//           final todos = Todos(todos: todoList);
//           return SuccessResult(todos);
//         case FailureResult<TodosDto>():
//           logger.e(message: '[TodoRepository] ${result.error}');
//           return FailureResult(result.error);
//       }
//     } on Exception catch (error) {
//       return Result.failure(error);
//     }
//   }
//
//   /// IDを指定して [Todo] を取得
//   Future<Result<Todo>> fetchById({required int id}) async {
//     try {
//       final result = await todoApiService.fetchById(id: id);
//
//       switch (result) {
//         case SuccessResult<TodoDto>():
//           final todo = _toEntity(result.value);
//           if (todo == null) {
//             // _toEntityがnullを返した場合、エラーとして扱う
//             return FailureResult(
//               Exception('Required fields missing for Todo with ID $id'),
//             );
//           }
//           return SuccessResult(todo);
//         case FailureResult<TodoDto>():
//           logger.e(message: '[TodoRepository] ${result.error}');
//           return FailureResult(result.error);
//       }
//     } on Exception catch (error) {
//       logger.e(message: '[TodoRepository] $error');
//       return Result.failure(error);
//     }
//   }
//
//   /// [TodoDto] を [Todo] エンティティに変換します。
//   Todo? _toEntity(TodoDto dto) {
//     // 必須フィールドが欠損している場合はnullを返す
//     if (dto.userId == null || dto.id == null) {
//       return null;
//     }
//
//     return Todo(
//       userId: dto.userId!,
//       id: dto.id!,
//       todo: dto.todo ?? '',
//       completed: dto.completed ?? false,
//     );
//   }
// }
