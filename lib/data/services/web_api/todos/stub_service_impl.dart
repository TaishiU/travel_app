import 'package:travel_app/data/services/web_api/todos/dto.dart';
import 'package:travel_app/data/services/web_api/todos/service.dart';
import 'package:travel_app/utils/result.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// プロバイダ
final stubTodoApiServiceImplProvider = Provider<StubTodoApiServiceImpl>(
  (ref) => StubTodoApiServiceImpl(),
);

/// スタブ実装クラス
class StubTodoApiServiceImpl implements TodosApiService {
  /// コンストラクタ
  StubTodoApiServiceImpl();

  @override
  Future<Result<TodosDto>> fetch() async {
    final todos = List.generate(10, (index) {
      return TodoDto(
        id: index + 1,
        userId: index + 1,
        todo: 'todo${index + 1}',
        completed: false,
      );
    });

    final todosDto = TodosDto(todos: todos);
    return SuccessResult(todosDto);
  }
}
