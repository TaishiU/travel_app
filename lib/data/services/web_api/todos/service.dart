import 'package:travel_app/data/services/web_api/todos/dto.dart';
import 'package:travel_app/utils/result.dart';

/// インターフェース
abstract class TodosApiService {
  /// [TodosDto] を取得
  Future<Result<TodosDto>> fetch();
}
