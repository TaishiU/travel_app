import 'package:travel_app/data/services/web_api/api_exception.dart';

/// アプリケーション全体で使用するドメインエラーの基底クラス。
///
/// ApiClientException（インフラ層）を Repository 境界で AppError（ドメイン層）に変換する。
/// View は AppError の型で分岐し、HTTP の詳細を知らない。
sealed class AppError implements Exception {
  const AppError();

  /// [ApiClientException] を [AppError] に変換する。
  /// 全 Repository で共通して使用する。
  factory AppError.from(Exception e) => switch (e) {
    NoInternetConnectionException() => const NetworkError(),
    UnauthorizedException() => const UnauthorizedError(),
    InternalServerErrorException() => const ServerError(500),
    BadRequestException(:final statusCode) => ClientError(statusCode ?? 400),
    NotFoundException(:final statusCode) => ClientError(statusCode ?? 404),
    _ => const UnknownError(),
  };
}

/// ネットワーク未接続
class NetworkError extends AppError {
  /// コンストラクタ
  const NetworkError();
}

/// セッション切れ（401）
class UnauthorizedError extends AppError {
  /// コンストラクタ
  const UnauthorizedError();
}

/// サーバーエラー（5xx）
class ServerError extends AppError {
  /// コンストラクタ
  const ServerError(this.statusCode);

  /// HTTPステータスコード
  final int statusCode;
}

/// クライアントエラー（4xx）
class ClientError extends AppError {
  /// コンストラクタ
  const ClientError(this.statusCode);

  /// HTTPステータスコード
  final int statusCode;
}

/// 上記以外
class UnknownError extends AppError {
  /// コンストラクタ
  const UnknownError();
}
