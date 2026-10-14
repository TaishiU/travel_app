import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:travel_app/data/services/web_api/api_client.dart';
import 'package:travel_app/data/services/web_api/api_exception.dart';
import 'package:travel_app/data/services/web_api/stub_api_enabled_provider.dart';
import 'package:travel_app/data/services/web_api/todos/dto.dart';
import 'package:travel_app/data/services/web_api/todos/service.dart';
import 'package:travel_app/data/services/web_api/todos/service_impl.dart';
import 'package:travel_app/data/services/web_api/todos/stub_service_impl.dart';
import 'package:travel_app/utils/result.dart';

import 'todos_api_service_impl_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  late MockApiClient mockApiClient;
  late TodosApiServiceImpl todosApiServiceImpl;

  setUp(() {
    mockApiClient = MockApiClient();
    todosApiServiceImpl = TodosApiServiceImpl(apiClient: mockApiClient);
  });

  group('todosApiServiceImplProvider', () {
    late ProviderContainer container;
    late MockApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
      container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWithValue(mockApiClient),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('todosApiServiceImplProviderはTodosApiServiceImplのインスタンスを返すこと', () {
      final service = container.read(todosApiServiceImplProvider);
      expect(service, isA<TodosApiServiceImpl>());
    });

    test('todosApiServiceImplProviderは指定されたApiClientで初期化されること', () async {
      final service = container.read(todosApiServiceImplProvider);
      when(
        mockApiClient.get(endpoint: 'todos'),
      ).thenAnswer(
        (_) async => {
          'todos': <Map<String, dynamic>>[],
        },
      );
      await service.fetch();
      verify(
        mockApiClient.get(endpoint: 'todos'),
      ).called(1);
    });
  });

  group('todosApiServiceProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWithValue(MockApiClient()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('isStub=false のとき TodosApiServiceImpl を返すこと', () {
      final service = container.read(todosApiServiceProvider);
      expect(service, isA<TodosApiServiceImpl>());
    });

    test('isStub=true のとき StubTodoApiServiceImpl を返すこと', () {
      container.read(isStubApiEnabledProvider.notifier).enabled = true;
      final service = container.read(todosApiServiceProvider);
      expect(service, isA<StubTodoApiServiceImpl>());
    });

    test('isStub=false → true → false と切り替えると型が変わること', () {
      expect(
        container.read(todosApiServiceProvider),
        isA<TodosApiServiceImpl>(),
      );
      container.read(isStubApiEnabledProvider.notifier).enabled = true;
      expect(
        container.read(todosApiServiceProvider),
        isA<StubTodoApiServiceImpl>(),
      );
      container.read(isStubApiEnabledProvider.notifier).enabled = false;
      expect(
        container.read(todosApiServiceProvider),
        isA<TodosApiServiceImpl>(),
      );
    });
  });

  group('StubTodoApiServiceImpl', () {
    late StubTodoApiServiceImpl stubService;

    setUp(() {
      stubService = StubTodoApiServiceImpl();
    });

    test('stubTodoApiServiceImplProvider は StubTodoApiServiceImpl を返すこと', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(
        container.read(stubTodoApiServiceImplProvider),
        isA<StubTodoApiServiceImpl>(),
      );
    });

    test('fetch は SuccessResult<TodosDto> を返すこと', () async {
      final result = await stubService.fetch();
      expect(result, isA<SuccessResult<TodosDto>>());
    });

    test('fetch は TodosApiService を実装していること', () {
      expect(stubService, isA<TodosApiService>());
    });

    test('返却される todos は空でないこと', () async {
      final result = await stubService.fetch();
      final todos = (result as SuccessResult<TodosDto>).value.todos;
      expect(todos, isNotNull);
      expect(todos, isNotEmpty);
    });

    test('返却される各 TodoDto は id / userId / todo を持つこと', () async {
      final result = await stubService.fetch();
      final todos = (result as SuccessResult<TodosDto>).value.todos!;
      for (final todo in todos) {
        expect(todo.id, isNotNull);
        expect(todo.userId, isNotNull);
        expect(todo.todo, isNotNull);
      }
    });
  });

  group('fetch', () {
    test('todosの取得に成功した場合、SuccessResult<TodosDto>を返すこと', () async {
      final mockResponse = {
        'todos': [
          {'id': 1, 'userId': 1, 'todo': 'Test Todo 1', 'completed': false},
          {'id': 2, 'userId': 1, 'todo': 'Test Todo 2', 'completed': true},
        ],
      };
      when(
        mockApiClient.get(endpoint: 'todos'),
      ).thenAnswer((_) async => mockResponse);

      final result = await todosApiServiceImpl.fetch();

      expect(result, isA<SuccessResult<TodosDto>>());
      expect((result as SuccessResult<TodosDto>).value.todos?.length, 2);
      expect(result.value.todos?[0].todo, 'Test Todo 1');
    });

    test('ApiClientExceptionが発生した場合、FailureResultを返すこと', () async {
      final apiException = ApiClientException(
        message: 'Not Found',
        statusCode: 404,
      );
      when(
        mockApiClient.get(endpoint: 'todos'),
      ).thenThrow(apiException);

      final result = await todosApiServiceImpl.fetch();

      expect(result, isA<FailureResult<TodosDto>>());
      expect((result as FailureResult<TodosDto>).error, apiException);
    });

    test('その他の例外が発生した場合、FailureResultを返すこと', () async {
      final exception = Exception('Something went wrong');
      when(
        mockApiClient.get(endpoint: 'todos'),
      ).thenThrow(exception);

      final result = await todosApiServiceImpl.fetch();

      expect(result, isA<FailureResult<TodosDto>>());
      expect((result as FailureResult<TodosDto>).error, exception);
    });
  });
}
