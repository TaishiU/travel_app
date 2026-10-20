import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';

/// 画面の状態
@freezed
abstract class LoginScreenState with _$LoginScreenState {
  /// コンストラクタ
  const factory LoginScreenState({@Default(false) bool isLoading}) =
      _LoginScreenState;
}
