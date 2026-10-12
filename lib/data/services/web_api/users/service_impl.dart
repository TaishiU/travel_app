import 'package:travel_app/data/services/web_api/api_client.dart';
import 'package:travel_app/data/services/web_api/api_exception.dart';
import 'package:travel_app/data/services/web_api/stub_api_enabled_provider.dart';
import 'package:travel_app/data/services/web_api/users/dto.dart';
import 'package:travel_app/data/services/web_api/users/service.dart';
import 'package:travel_app/data/services/web_api/users/stub_service_impl.dart';
import 'package:travel_app/utils/logger.dart';
import 'package:travel_app/utils/result.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// プロバイダ
final usersApiServiceImplProvider = Provider<UsersApiServiceImpl>(
  (ref) => UsersApiServiceImpl(apiClient: ref.read(apiClientProvider)),
);

/// スタブ切り替え対応の統合Provider
final usersApiServiceProvider = Provider<UsersApiService>((ref) {
  // coverage:ignore-start
  if (!kDebugMode) {
    return UsersApiServiceImpl(apiClient: ref.read(apiClientProvider));
  }
  // coverage:ignore-end
  final isStub = ref.watch<bool>(isStubApiEnabledProvider);
  return isStub
      ? StubUsersApiServiceImpl()
      : UsersApiServiceImpl(apiClient: ref.read(apiClientProvider));
});

/// APIサービス実装クラス
class UsersApiServiceImpl implements UsersApiService {
  /// コンストラクタ
  UsersApiServiceImpl({required this.apiClient});

  ///　ApiClient
  final ApiClient apiClient;

  /// エンドポイント
  static const endpoint = 'users';

  @override
  Future<Result<UserDto>> fetchById() async {
    try {
      // throw NoInternetConnectionException('通信エラー');
      final response = await apiClient.get(endpoint: '$endpoint/1');
      final userDto = UserDto.fromJson(response);
      return SuccessResult(userDto);
    } on ApiClientException catch (error) {
      logger.e(message: '[UsersApiServiceImpl] ApiClientException: $error');
      return FailureResult(error);
    } on Exception catch (error) {
      logger.e(message: '[UsersApiServiceImpl] Unexpected Error: $error');
      return FailureResult(error);
    }
  }
}
