import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/local_storage/secure_storage/auth/auth_secure_storage_service.dart';
import 'package:travel_app/data/services/local_storage/secure_storage/auth/auth_secure_storage_service_impl.dart';
import 'package:travel_app/data/services/web_api/auth/dto.dart';
import 'package:travel_app/data/services/web_api/auth/service.dart';
import 'package:travel_app/data/services/web_api/auth/service_impl.dart';
import 'package:travel_app/domain/entities/user/user.dart';
import 'package:travel_app/domain/errors/app_error.dart';
import 'package:travel_app/domain/interfaces/auth/auth_repository.dart';
import 'package:travel_app/utils/logger.dart';
import 'package:travel_app/utils/result.dart';

/// プロバイダ
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    authApiService: ref.read(authApiServiceImplProvider),
    authSecureStorageService: ref.read(authSecureStorageServiceImplProvider),
  ),
);

/// [AuthRepository] の実装クラス。
class AuthRepositoryImpl extends ChangeNotifier implements AuthRepository {
  /// コンストラクタ
  AuthRepositoryImpl({
    required this.authApiService,
    required this.authSecureStorageService,
  });

  /// Authに関連するAPI通信を抽象化したサービスインターフェース
  final AuthApiService authApiService;

  /// Authに関連するデータをセキュアに永続化するサービスインターフェース
  final AuthSecureStorageService authSecureStorageService;

  bool? _isLoggedIn;
  bool _isLoaded = false;
  String? _pendingDeepLink;

  // ---------------------------------------------------------------------------
  // AuthRepository
  // ---------------------------------------------------------------------------

  @override
  Future<bool> get isLoggedIn async {
    if (_isLoggedIn != null && _isLoaded) {
      return _isLoggedIn!;
    }
    await _ensureLoaded();
    return _isLoggedIn ?? false;
  }

  @override
  Future<Result<void>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await authApiService.login(
        email: email,
        password: password,
      );
      switch (result) {
        case SuccessResult<TokenResponseDto>():
          await _saveTokens(dto: result.value);
          notifyListeners();
          logger.w(message: 'notifyListeners(): 発火');
          return const SuccessResult(null);
        case FailureResult<TokenResponseDto>():
          logger.e(message: '[AuthRepositoryImpl] ${result.error}');
          return FailureResult(AppError.from(result.error));
      }
    } on Exception catch (error) {
      return FailureResult(AppError.from(error));
    }
  }

  @override
  Future<Result<void>> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final result = await authApiService.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      switch (result) {
        case SuccessResult<TokenResponseDto>():
          await _saveTokens(dto: result.value);
          notifyListeners();
          return const SuccessResult(null);
        case FailureResult<TokenResponseDto>():
          logger.e(message: '[AuthRepositoryImpl] ${result.error}');
          return FailureResult(AppError.from(result.error));
      }
    } on Exception catch (error) {
      return FailureResult(AppError.from(error));
    }
  }

  @override
  Future<Result<void>> refreshToken() async {
    final storedRefreshToken = authSecureStorageService.getRefreshToken();
    try {
      final result = await authApiService.refresh(
        refreshToken: storedRefreshToken,
      );
      switch (result) {
        case SuccessResult<RefreshTokenDto>():
          final accessToken = result.value.accessToken ?? '';
          final newRefreshToken = result.value.refreshToken ?? '';
          await authSecureStorageService.setAccessToken(token: accessToken);
          await authSecureStorageService.setRefreshToken(
            token: newRefreshToken,
          );
          _isLoggedIn = accessToken.isNotEmpty;
          return const SuccessResult(null);
        case FailureResult<RefreshTokenDto>():
          logger.e(message: '[AuthRepositoryImpl] ${result.error}');
          return FailureResult(AppError.from(result.error));
      }
    } on Exception catch (error) {
      return FailureResult(AppError.from(error));
    }
  }

  @override
  Future<Result<User>> me() async {
    try {
      final result = await authApiService.me();
      switch (result) {
        case SuccessResult<UserDto>():
          final user = _toUser(dto: result.value);
          if (user == null) {
            return FailureResult(AppError.from(Exception('Invalid user data')));
          }
          return SuccessResult(user);
        case FailureResult<UserDto>():
          logger.e(message: '[AuthRepositoryImpl] ${result.error}');
          return FailureResult(AppError.from(result.error));
      }
    } on Exception catch (error) {
      return FailureResult(AppError.from(error));
    }
  }

  @override
  String? get pendingDeepLink => _pendingDeepLink;

  @override
  set pendingDeepLink(String path) {
    _pendingDeepLink = path;
  }

  @override
  String? getAndClearPendingDeepLink() {
    final path = _pendingDeepLink;
    _pendingDeepLink = null;
    return path;
  }

  @override
  Future<void> logout() async {
    final storedRefreshToken = authSecureStorageService.getRefreshToken();
    try {
      await authApiService.logout(refreshToken: storedRefreshToken);
    } on Exception catch (error) {
      logger.e(message: '[AuthRepositoryImpl] logout API error: $error');
    }
    await authSecureStorageService.clearAuthData();
    _isLoggedIn = false;
    _isLoaded = true;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  Future<void> _ensureLoaded() async {
    if (_isLoaded) return;
    await authSecureStorageService.init();
    final accessToken = authSecureStorageService.getAccessToken();
    _isLoggedIn = accessToken.isNotEmpty;
    _isLoaded = true;
  }

  Future<void> _saveTokens({required TokenResponseDto dto}) async {
    logger.i(message: '_saveTokens(): start');
    final accessToken = dto.accessToken ?? '';
    final refreshToken = dto.refreshToken ?? '';
    await authSecureStorageService.setAccessToken(token: accessToken);
    await authSecureStorageService.setRefreshToken(token: refreshToken);
    _isLoggedIn = accessToken.isNotEmpty;
    _isLoaded = true;
    logger.i(message: '_saveTokens(): end');
  }

  User? _toUser({required UserDto dto}) {
    final id = dto.id;
    final email = dto.email;
    if (id == null || email == null) return null;
    return User(id: id, email: email, displayName: dto.displayName);
  }
}
