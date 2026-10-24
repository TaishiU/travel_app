import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/repositories/task/task_repository_impl.dart';
import 'package:travel_app/domain/entities/task/task.dart';

/// Task ドメインの SSOT ストリームを提供する Provider。
///
/// taskRepositoryProvider が保持する Stream をそのまま公開する。
/// 複数画面の Notifier がこの Provider を ref.watch することで、
/// タスク一覧の変更（追加・完了切替）を自動検知して再ビルドできる。
///
/// 宣言を domain/use_cases 層に置く理由:
/// Notifier（プレゼンテーション層）は data 層を直接参照できないため、
/// domain 層を経由して公開する。auth_use_case.dart が AuthRepository を
/// domain 層でラップしているのと同じ構造。
final tasksStreamProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).tasksStream;
});

/// [TaskUseCase] のプロバイダ
final taskUseCaseProvider = Provider<TaskUseCase>(
  (ref) => TaskUseCase(ref: ref),
);

/// タスクドメインのビジネスロジックを担当する UseCase。
///
/// タスクの追加・完了状態更新といったドメイン操作を集約する。
/// 画面固有の State 構築は TaskScreenUseCase が担う。
class TaskUseCase {
  /// コンストラクタ
  TaskUseCase({required this.ref});

  /// Provider 参照用の ref
  final Ref ref;

  /// タスクを追加する
  Future<void> addTask({required String title}) =>
      ref.read(taskRepositoryProvider).addTask(title: title);

  /// 完了状態を更新する
  Future<void> updateCompletion({required int id, required bool completed}) =>
      ref
          .read(taskRepositoryProvider)
          .updateCompletion(id: id, completed: completed);
}
