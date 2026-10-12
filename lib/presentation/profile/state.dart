import 'package:travel_app/domain/entities/user/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';

/// 画面の状態
@freezed
abstract class ProfileScreenState with _$ProfileScreenState {
  /// コンストラクタ
  const factory ProfileScreenState({
    /// ユーザー
    required User user,
  }) = _ProfileScreenState;
}
