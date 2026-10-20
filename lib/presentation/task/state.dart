import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:travel_app/domain/entities/task/task.dart';

part 'state.freezed.dart';

/// タスク画面の状態
@freezed
abstract class TaskScreenState with _$TaskScreenState {
  /// コンストラクタ
  const factory TaskScreenState({
    /// タスク一覧
    required List<Task> tasks,

    /// ログイン済みかどうか
    @Default(false) bool isLoggedIn,
  }) = _TaskScreenState;
}
