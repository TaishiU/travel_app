import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:travel_app/data/repositories/todo/todo_repository.dart';
import 'package:travel_app/data/services/web_api/todos/dto.dart';
import 'package:travel_app/data/services/web_api/todos/service.dart';
import 'package:travel_app/data/services/web_api/todos/service_impl.dart';
import 'package:travel_app/domain/entities/todos/todos.dart';
import 'package:travel_app/domain/errors/app_error.dart';
import 'package:travel_app/utils/result.dart';

import 'todo_repository_test.mocks.dart';

// MissingDummyValueErrorを解決するためにダミー値を提供するヘルパー関数
void _setupDummyValues() {
  provideDummyBuilder<Result<TodosDto>>(
    (_, _) => const SuccessResult(TodosDto(todos: [])),
  );
  provideDummyBuilder<Result<TodoDto>>(
    (_, _) => const SuccessResult(TodoDto()),
  );
}

@GenerateMocks([TodosApiService, TodosApiServiceImpl])
void main() {
  _setupDummyValues();

  late MockTodosApiService mockTodosApiService;
  late TodoRepository todoRepository;

  setUp(() {
    mockTodosApiService = MockTodosApiService();
    todoRepository = TodoRepository(todoApiService: mockTodosApiService);
  });

  group('Providerのテスト', () {
    late ProviderContainer container;
    late MockTodosApiServiceImpl mockTodosApiServiceImpl;

    setUp(() {
      mockTodosApiServiceImpl = MockTodosApiServiceImpl();
      container = ProviderContainer(
        overrides: [
          todosApiServiceProvider.overrideWith(
            (ref) => mockTodosApiServiceImpl,
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('todoRepositoryProvider は TodoRepository のインスタンスを返すこと', () {
      final repository = container.read(todoRepositoryProvider);
      expect(repository, isA<TodoRepository>());
    });

    test(
      'todosStreamProvider は TodoRepository の todosStream を提供すること',
      () async {
        final mockTodoDtos = [
          const TodoDto(userId: 1, id: 1, todo: 'Test Todo', completed: false),
        ];
        when(mockTodosApiServiceImpl.fetch()).thenAnswer(
          (_) async => SuccessResult(TodosDto(todos: mockTodoDtos)),
        );

        final repository = container.read(todoRepositoryProvider);
        final completer = Completer<List<Todo>>();

        // Providerの状態変化を監視し、データが届いたらCompleterを完了させる
        container.listen<AsyncValue<List<Todo>>>(
          todosStreamProvider,
          (previous, next) {
            next.whenData((todos) {
              if (!completer.isCompleted) {
                completer.complete(todos);
              }
            });
          },
          fireImmediately: true,
        );

        // データの取得を実行
        await repository.fetch();

        // Completerを通じてデータが届くのを待つ（タイムアウト回避のため適度な時間を設定可能だがデフォルトでも動作するはず）
        final todos = await completer.future.timeout(
          const Duration(seconds: 5),
        );

        expect(todos.length, 1);
        expect(todos.first.todo, 'Test Todo');
      },
    );
  });

  group('fetch メソッドのテスト', () {
    final mockTodoDtos = [
      const TodoDto(userId: 1, id: 1, todo: 'Todo 1', completed: false),
      const TodoDto(userId: 1, id: 2, todo: 'Todo 2', completed: true),
    ];

    test('初回fetch成功時にキャッシュとStreamが更新されること', () async {
      when(mockTodosApiService.fetch()).thenAnswer(
        (_) async => SuccessResult(TodosDto(todos: mockTodoDtos)),
      );

      // Streamを監視
      final expectation = expectLater(
        todoRepository.todosStream,
        emits(predicate<List<Todo>>((list) => list.length == 2)),
      );

      final result = await todoRepository.fetch();

      expect(result, isA<SuccessResult<void>>());
      expect(todoRepository.latestTodos.length, 2);
      await expectation;
      verify(mockTodosApiService.fetch()).called(1);
    });

    test('2回目以降のfetchは、forceフラグがfalseならAPIを叩かないこと', () async {
      when(mockTodosApiService.fetch()).thenAnswer(
        (_) async => SuccessResult(TodosDto(todos: mockTodoDtos)),
      );

      // 1回目
      await todoRepository.fetch();
      // 2回目 (force=false)
      await todoRepository.fetch();

      verify(mockTodosApiService.fetch()).called(1);
    });

    test('forceフラグがtrueなら、取得済みでもAPIを叩くこと', () async {
      when(mockTodosApiService.fetch()).thenAnswer(
        (_) async => SuccessResult(TodosDto(todos: mockTodoDtos)),
      );

      // 1回目
      await todoRepository.fetch();
      // 2回目 (force=true)
      await todoRepository.fetch(force: true);

      verify(mockTodosApiService.fetch()).called(2);
    });

    test('APIがエラーを返した場合、FailureResultを返しキャッシュは更新されないこと', () async {
      final exception = Exception('API Error');
      when(mockTodosApiService.fetch()).thenAnswer(
        (_) async => FailureResult(exception),
      );

      final result = await todoRepository.fetch();

      expect(result, isA<FailureResult<void>>());
      expect((result as FailureResult).error, isA<AppError>());
      expect(todoRepository.latestTodos, isEmpty);
    });

    test('例外発生時にFailureResultを返すこと', () async {
      when(mockTodosApiService.fetch()).thenThrow(Exception('Network Error'));

      final result = await todoRepository.fetch();

      expect(result, isA<FailureResult<void>>());
      expect((result as FailureResult).error, isA<AppError>());
    });
  });

  group('toggleTodoCompletion メソッドのテスト', () {
    setUp(() async {
      final mockTodoDtos = [
        const TodoDto(userId: 1, id: 1, todo: 'Todo 1', completed: false),
      ];
      when(mockTodosApiService.fetch()).thenAnswer(
        (_) async => SuccessResult(TodosDto(todos: mockTodoDtos)),
      );
      await todoRepository.fetch();
    });

    test('指定したIDのTodoの完了状態が反転し、Streamに通知されること', () async {
      // 初期状態の確認
      expect(todoRepository.latestTodos.first.completed, isFalse);

      // Streamを監視
      final expectation = expectLater(
        todoRepository.todosStream,
        emits(predicate<List<Todo>>((list) => list.first.completed)),
      );

      await todoRepository.toggleTodoCompletion(id: 1);

      expect(todoRepository.latestTodos.first.completed, isTrue);
      await expectation;
    });

    test('存在しないIDを指定した場合は何も起きないこと', () async {
      await todoRepository.toggleTodoCompletion(id: 999);
      expect(todoRepository.latestTodos.first.completed, isFalse);
    });
  });

  group('Entity変換のバリデーション', () {
    test('必須フィールドが欠損しているTodoは除外されること', () async {
      final mockTodoDtos = [
        const TodoDto(userId: 1, id: 1, todo: 'Valid', completed: false),
        const TodoDto(id: 2), // userId欠損
        const TodoDto(userId: 3), // id欠損
      ];
      when(mockTodosApiService.fetch()).thenAnswer(
        (_) async => SuccessResult(TodosDto(todos: mockTodoDtos)),
      );

      await todoRepository.fetch();

      expect(todoRepository.latestTodos.length, 1);
      expect(todoRepository.latestTodos.first.id, 1);
    });

    test('null可能なフィールドにはデフォルト値が入ること', () async {
      final mockTodoDtos = [
        const TodoDto(userId: 1, id: 1),
      ];
      when(mockTodosApiService.fetch()).thenAnswer(
        (_) async => SuccessResult(TodosDto(todos: mockTodoDtos)),
      );

      await todoRepository.fetch();

      final todo = todoRepository.latestTodos.first;
      expect(todo.todo, isEmpty);
      expect(todo.completed, isFalse);
    });
  });
}
