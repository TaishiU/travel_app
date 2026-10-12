import 'package:freezed_annotation/freezed_annotation.dart';

part 'dto.freezed.dart';
part 'dto.g.dart';

/// LoginDto
@freezed
abstract class LoginDto with _$LoginDto {
  /// コンストラクタ
  const factory LoginDto({
    /// ID
    int? id,

    /// ユーザー名
    String? username,

    /// メールアドレス
    String? email,

    /// 姓
    String? firstName,

    /// 名
    String? lastName,

    /// 性別
    String? gender,

    /// 画像
    String? image,

    /// アクセストークン
    String? accessToken,

    /// リフレッシュトークン
    String? refreshToken,
  }) = _LoginDto;

  /// JSONから生成
  factory LoginDto.fromJson(Map<String, Object?> json) =>
      _$LoginDtoFromJson(json);
}
