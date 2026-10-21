import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/web_api/api_client.dart';
import 'package:travel_app/data/services/web_api/api_exception.dart';
import 'package:travel_app/data/services/web_api/auth/dto.dart';
import 'package:travel_app/data/services/web_api/auth/service.dart';
import 'package:travel_app/utils/logger.dart';
import 'package:travel_app/utils/result.dart';

/// プロバイダ
final authApiServiceImplProvider = Provider<AuthApiService>(
  (ref) => AuthApiServiceImpl(apiClient: ref.read(apiClientProvider)),
);

/// 認証APIサービス実装クラス
class AuthApiServiceImpl implements AuthApiService {
  /// コンストラクタ
  AuthApiServiceImpl({required this.apiClient});

  /// ApiClient
  final ApiClient apiClient;

  static const _registerEndpoint = 'auth/register';
  static const _loginEndpoint = 'auth/login';
  static const _refreshEndpoint = 'auth/refresh';
  static const _logoutEndpoint = 'auth/logout';
  static const _meEndpoint = 'auth/me';

  @override
  Future<Result<TokenResponseDto>> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final body = <String, dynamic>{
        'email': email,
        'password': password,
        'displayName': ?displayName,
      };
      final response = await apiClient.post(
        endpoint: _registerEndpoint,
        body: body,
      );
      final dto = TokenResponseDto.fromJson(
        response['data'] as Map<String, dynamic>,
      );
      return SuccessResult(dto);
    } on ApiClientException catch (error) {
      logger.e(message: '[AuthApiServiceImpl] ApiClientException: $error');
      return FailureResult(error);
    } on Exception catch (error) {
      logger.e(message: '[AuthApiServiceImpl] Unexpected Error: $error');
      return FailureResult(error);
    }
  }

  @override
  Future<Result<TokenResponseDto>> login({
    required String email,
    required String password,
  }) async {
    try {
      final body = <String, dynamic>{'email': email, 'password': password};
      final response = await apiClient.post(
        endpoint: _loginEndpoint,
        body: body,
      );
      final dto = TokenResponseDto.fromJson(
        response['data'] as Map<String, dynamic>,
      );
      return SuccessResult(dto);
    } on ApiClientException catch (error) {
      logger.e(message: '[AuthApiServiceImpl] ApiClientException: $error');
      return FailureResult(error);
    } on Exception catch (error) {
      logger.e(message: '[AuthApiServiceImpl] Unexpected Error: $error');
      return FailureResult(error);
    }
  }

  @override
  Future<Result<RefreshTokenDto>> refresh({
    required String refreshToken,
  }) async {
    try {
      final body = <String, dynamic>{'refreshToken': refreshToken};
      final response = await apiClient.post(
        endpoint: _refreshEndpoint,
        body: body,
      );
      final dto = RefreshTokenDto.fromJson(
        response['data'] as Map<String, dynamic>,
      );
      return SuccessResult(dto);
    } on ApiClientException catch (error) {
      logger.e(message: '[AuthApiServiceImpl] ApiClientException: $error');
      return FailureResult(error);
    } on Exception catch (error) {
      logger.e(message: '[AuthApiServiceImpl] Unexpected Error: $error');
      return FailureResult(error);
    }
  }

  @override
  Future<Result<void>> logout({required String refreshToken}) async {
    try {
      await apiClient.post(
        endpoint: _logoutEndpoint,
        body: {'refreshToken': refreshToken},
      );
      return const SuccessResult(null);
    } on ApiClientException catch (error) {
      logger.e(message: '[AuthApiServiceImpl] ApiClientException: $error');
      return FailureResult(error);
    } on Exception catch (error) {
      logger.e(message: '[AuthApiServiceImpl] Unexpected Error: $error');
      return FailureResult(error);
    }
  }

  @override
  Future<Result<UserDto>> me() async {
    try {
      final response = await apiClient.get(endpoint: _meEndpoint);
      final dto = UserDto.fromJson(response['data'] as Map<String, dynamic>);
      return SuccessResult(dto);
    } on ApiClientException catch (error) {
      logger.e(message: '[AuthApiServiceImpl] ApiClientException: $error');
      return FailureResult(error);
    } on Exception catch (error) {
      logger.e(message: '[AuthApiServiceImpl] Unexpected Error: $error');
      return FailureResult(error);
    }
  }
}
