import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';

/// タスク情報を表すエンティティ
@freezed
abstract class Task with _$Task {
  /// コンストラクタ
  const factory Task({
    /// ID
    required int id,

    /// ユーザーID
    required int userId,

    /// タイトル
    required String title,

    /// 完了フラグ
    required bool completed,
  }) = _Task;
}
