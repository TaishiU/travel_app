import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/web_api/api_client.dart';
import 'package:travel_app/data/services/web_api/api_exception.dart';
import 'package:travel_app/data/services/web_api/auth/login/dto.dart';
import 'package:travel_app/data/services/web_api/auth/login/service.dart';
import 'package:travel_app/utils/logger.dart';
import 'package:travel_app/utils/result.dart';

/// AuthApiServiceImplのプロバイダ
final authApiServiceImplProvider = Provider<AuthApiServiceImpl>(
  (ref) => AuthApiServiceImpl(apiClient: ref.read(apiClientProvider)),
);

/// APIサービス実装クラス
class AuthApiServiceImpl implements AuthApiService {
  /// コンストラクタ
  AuthApiServiceImpl({required this.apiClient});

  ///　ApiClient
  final ApiClient apiClient;

  /// エンドポイント
  static const endpoint = 'auth/login';

  @override
  Future<Result<LoginDto>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        endpoint: endpoint,
        body: {'username': username, 'password': password, 'expiresInMins': 30},
      );
      final loginDto = LoginDto.fromJson(response);
      return SuccessResult(loginDto);
    } on ApiClientException catch (error) {
      logger.e(message: '[AuthApiServiceImpl] ApiClientException: $error');
      return FailureResult(error);
    } on Exception catch (error) {
      logger.e(message: '[AuthApiServiceImpl] Unexpected Error: $error');
      return FailureResult(error);
    }
  }
}
