import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

/// ユーザー情報を表すエンティティ
@freezed
abstract class User with _$User {
  /// コンストラクタ
  const factory User({
    /// ユーザーID
    required String id,

    /// メールアドレス
    required String email,

    /// 表示名
    String? displayName,
  }) = _User;
}
