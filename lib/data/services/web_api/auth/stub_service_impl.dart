import 'package:hooks_riverpod/hooks_riverpod.dart';
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
  StubAuthApiServiceImpl();

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
    return SuccessResult(
      TokenResponseDto(
        accessToken: _accessToken,
        refreshToken: _refreshToken,
        user: UserDto(
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
    return SuccessResult(
      TokenResponseDto(
        accessToken: _accessToken,
        refreshToken: _refreshToken,
        user: UserDto(
          id: _userId,
          email: email,
          displayName: _displayName,
        ),
      ),
    );
  }

  @override
  Future<Result<RefreshTokenDto>> refresh({
    required String refreshToken,
  }) async {
    return const SuccessResult(
      RefreshTokenDto(
        accessToken: _accessToken,
        refreshToken: _refreshToken,
      ),
    );
  }

  @override
  Future<Result<void>> logout({
    required String refreshToken,
  }) async {
    return const SuccessResult(null);
  }

  @override
  Future<Result<UserDto>> me() async {
    return const SuccessResult(
      UserDto(
        id: _userId,
        email: _email,
        displayName: _displayName,
      ),
    );
  }
}
