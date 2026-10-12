import 'package:freezed_annotation/freezed_annotation.dart';

part 'dto.freezed.dart';
part 'dto.g.dart';

/// TodosDto
@freezed
abstract class TodosDto with _$TodosDto {
  /// コンストラクタ
  const factory TodosDto({
    List<TodoDto>? todos,
  }) = _TodosDto;

  /// JSONから生成
  factory TodosDto.fromJson(Map<String, dynamic> json) =>
      _$TodosDtoFromJson(json);
}

/// TodoDto
@freezed
abstract class TodoDto with _$TodoDto {
  /// コンストラクタ
  const factory TodoDto({
    /// ID
    int? id,

    /// ユーザーID
    int? userId,

    /// タイトル
    @JsonKey(name: 'todo') String? todo,

    /// 完了したかどうか
    bool? completed,
  }) = _TodoDto;

  /// JSONから生成
  factory TodoDto.fromJson(Map<String, dynamic> json) =>
      _$TodoDtoFromJson(json);
}
