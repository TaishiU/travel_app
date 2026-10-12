import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

/// 処理の結果（成功または失敗）を保持する汎用的な [Result] クラス。
///
/// アプリケーション全体のデータフローにおける成功・失敗の状態表現に使用します。
/// sealedクラスとして定義されているため、switch文やswitch式での網羅的な評価が可能です。
@freezed
sealed class Result<T> with _$Result<T> {
  /// 処理が成功し、結果値を保持している状態。
  const factory Result.success(T value) = SuccessResult<T>;

  /// 処理が失敗し、例外を保持している状態。
  const factory Result.failure(Exception error) = FailureResult<T>;
}
