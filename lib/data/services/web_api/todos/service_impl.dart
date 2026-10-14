import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/web_api/api_client.dart';
import 'package:travel_app/data/services/web_api/api_exception.dart';
import 'package:travel_app/data/services/web_api/stub_api_enabled_provider.dart';
import 'package:travel_app/data/services/web_api/todos/dto.dart';
import 'package:travel_app/data/services/web_api/todos/service.dart';
import 'package:travel_app/data/services/web_api/todos/stub_service_impl.dart';
import 'package:travel_app/utils/logger.dart';
import 'package:travel_app/utils/result.dart';

/// プロバイダ
final todosApiServiceImplProvider = Provider<TodosApiServiceImpl>(
  (ref) => TodosApiServiceImpl(apiClient: ref.read(apiClientProvider)),
);

/// スタブ切り替え対応の統合Provider
final todosApiServiceProvider = Provider<TodosApiService>((ref) {
  // coverage:ignore-start
  if (!kDebugMode) {
    return TodosApiServiceImpl(apiClient: ref.read(apiClientProvider));
  }
  // coverage:ignore-end
  final isStub = ref.watch<bool>(isStubApiEnabledProvider);
  return isStub
      ? StubTodoApiServiceImpl()
      : TodosApiServiceImpl(apiClient: ref.read(apiClientProvider));
});

/// APIサービス実装クラス
class TodosApiServiceImpl implements TodosApiService {
  /// コンストラクタ
  TodosApiServiceImpl({required this.apiClient});

  ///　ApiClient
  final ApiClient apiClient;

  /// エンドポイント
  static const endpoint = 'todos';

  @override
  Future<Result<TodosDto>> fetch() async {
    try {
      final response = await apiClient.get(endpoint: endpoint);
      final todosDto = TodosDto.fromJson(response);
      return SuccessResult(todosDto);
    } on ApiClientException catch (error) {
      logger.e(message: '[TodoServiceAPI] ApiClientException: $error');
      return FailureResult(error);
    } on Exception catch (error) {
      logger.e(message: '[TodoServiceAPI] Unexpected Error: $error');
      return FailureResult(error);
    }
  }
}
