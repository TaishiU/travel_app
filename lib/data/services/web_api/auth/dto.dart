import 'package:freezed_annotation/freezed_annotation.dart';

part 'dto.freezed.dart';
part 'dto.g.dart';

/// TokenResponseDto（認証トークンレスポンス）
@freezed
abstract class TokenResponseDto with _$TokenResponseDto {
  /// コンストラクタ
  const factory TokenResponseDto({
    /// アクセストークン
    String? accessToken,

    /// リフレッシュトークン
    String? refreshToken,

    /// ユーザー情報
    UserDto? user,
  }) = _TokenResponseDto;

  /// JSONから生成
  factory TokenResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseDtoFromJson(json);
}

/// UserDto（ユーザー情報）
@freezed
abstract class UserDto with _$UserDto {
  /// コンストラクタ
  const factory UserDto({
    /// ユーザーID
    String? id,

    /// メールアドレス
    String? email,

    /// 表示名
    String? displayName,
  }) = _UserDto;

  /// JSONから生成
  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}
