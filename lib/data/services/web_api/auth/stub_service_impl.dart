import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/web_api/api_exception.dart';
import 'package:travel_app/data/services/web_api/auth/dto.dart';
import 'package:travel_app/data/services/web_api/auth/service.dart';
import 'package:travel_app/utils/result.dart';

/// プロバイダ
final stubAuthApiServiceImplProvider = Provider<StubAuthApiServiceImpl>(
  (ref) => StubAuthApiServiceImpl(),
);

/// スタブ実装クラス
class StubAuthApiServiceImpl implements AuthApiService {
  /// コンストラクタ
  StubAuthApiServiceImpl({
    this.shouldFail = false,
    this.shouldThrow = false,
    this.shouldOmitUserInTokenResponse = false,
    this.meReturnsInvalidUser = false,
  });

  /// trueのとき全メソッドが [BadRequestException] の [FailureResult] を返す
  final bool shouldFail;

  /// trueのとき全メソッドが [Exception] をスローする（on Exception catch 分岐用）
  final bool shouldThrow;

  /// trueのとき login/register の [TokenResponseDto] に user を含めない（_persistUserId empty 分岐用）
  final bool shouldOmitUserInTokenResponse;

  /// trueのとき [me] が id=null の [UserDto] を返す（_toUser 変換失敗分岐用）
  final bool meReturnsInvalidUser;

  static const _accessToken = 'test-access-token';
  static const _refreshToken = 'test-refresh-token';
  static const _userId = '1';
  static const _displayName = 'test user';
  static const _email = 'test@example.com';

  @override
  Future<Result<TokenResponseDto>> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (shouldThrow) throw Exception('register error');
    if (shouldFail) {
      return FailureResult(BadRequestException(message: 'register failed'));
    }
    return SuccessResult(
      TokenResponseDto(
        accessToken: _accessToken,
        refreshToken: _refreshToken,
        user: shouldOmitUserInTokenResponse
            ? null
            : UserDto(
                id: _userId,
                email: email,
                displayName: displayName ?? _displayName,
              ),
      ),
    );
  }

  @override
  Future<Result<TokenResponseDto>> login({
    required String email,
    required String password,
  }) async {
    if (shouldThrow) throw Exception('login error');
    if (shouldFail) {
      return FailureResult(BadRequestException(message: 'login failed'));
    }
    return SuccessResult(
      TokenResponseDto(
        accessToken: _accessToken,
        refreshToken: _refreshToken,
        user: shouldOmitUserInTokenResponse
            ? null
            : UserDto(id: _userId, email: email, displayName: _displayName),
      ),
    );
  }

  @override
  Future<Result<void>> logout({required String refreshToken}) async {
    if (shouldThrow) throw Exception('logout error');
    if (shouldFail) {
      return FailureResult(BadRequestException(message: 'logout failed'));
    }
    return const SuccessResult(null);
  }

  @override
  Future<Result<UserDto>> me() async {
    if (shouldThrow) throw Exception('me error');
    if (shouldFail) {
      return FailureResult(BadRequestException(message: 'me failed'));
    }
    if (meReturnsInvalidUser) {
      return const SuccessResult(UserDto());
    }
    return const SuccessResult(
      UserDto(id: _userId, email: _email, displayName: _displayName),
    );
  }
}
