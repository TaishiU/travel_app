import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';

/// 画面の状態
@freezed
abstract class LoginScreenState with _$LoginScreenState {
  /// コンストラクタ
  const factory LoginScreenState({
    /// 表示するTodoアイテムのリスト
    required bool isLoggedIn,
  }) = _LoginScreenState;
}
