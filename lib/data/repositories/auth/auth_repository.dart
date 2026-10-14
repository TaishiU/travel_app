import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/local_storage/secure_storage/auth/auth_secure_storage_service.dart';
import 'package:travel_app/data/services/local_storage/secure_storage/auth/auth_secure_storage_service_impl.dart';
import 'package:travel_app/data/services/web_api/auth/login/dto.dart';
import 'package:travel_app/data/services/web_api/auth/login/service.dart';
import 'package:travel_app/data/services/web_api/auth/login/service_impl.dart';
import 'package:travel_app/domain/errors/app_error.dart';
import 'package:travel_app/utils/logger.dart';
import 'package:travel_app/utils/result.dart';

/// プロバイダ
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    authApiService: ref.read(authApiServiceImplProvider),
    authSecureStorageService: ref.read(authSecureStorageServiceImplProvider),
  ),
);

/// リポジトリクラス
class AuthRepository extends ChangeNotifier {
  /// コンストラクタ
  AuthRepository({
    required this.authApiService,
    required this.authSecureStorageService,
  });

  /// Authに関連するAPI通信を抽象化したサービスインターフェース。
  final AuthApiService authApiService;

  /// Authに関連するデータをセキュアに永続化するサービスインターフェース。
  final AuthSecureStorageService authSecureStorageService;

  /// ログイン済みかどうか
  bool? _isLoggedIn;

  /// ストレージからロード済みかどうか
  bool _isLoaded = false;

  /// ログイン済みかどうか
  Future<bool> get isLoggedIn async {
    // キャッシュがあり、かつロード済みならそのまま返す
    if (_isLoggedIn != null && _isLoaded) {
      return _isLoggedIn!;
    }
    // ストレージからのロード
    await _ensureLoaded();
    return _isLoggedIn ?? false;
  }

  /// ストレージからのロードを保証する
  Future<void> _ensureLoaded() async {
    if (_isLoaded) {
      return;
    }
    // 初期化（非同期）
    await authSecureStorageService.init();

    final accessToken = authSecureStorageService.getAccessToken();
    _isLoggedIn = accessToken.isNotEmpty;
    _isLoaded = true;
  }

  /// ログイン
  Future<Result<void>> login({
    required String username,
    required String password,
  }) async {
    try {
      final result = await authApiService.login(
        username: username,
        password: password,
      );

      switch (result) {
        case SuccessResult<LoginDto>():
          final loginDto = result.value;
          final accessToken = loginDto.accessToken ?? '';
          final refreshToken = loginDto.refreshToken ?? '';

          await authSecureStorageService.setAccessToken(token: accessToken);
          await authSecureStorageService.setRefreshToken(token: refreshToken);

          _isLoggedIn = accessToken.isNotEmpty;
          _isLoaded = true;

          // ログイン状態の変更通知
          notifyListeners();
          return const SuccessResult(null);
        case FailureResult<LoginDto>():
          logger.e(message: '[AuthRepository] ${result.error}');
          return FailureResult(AppError.from(result.error));
      }
    } on Exception catch (error) {
      return FailureResult(AppError.from(error));
    }
  }

  /// ログアウト
  Future<void> logout() async {
    await authSecureStorageService.clearAuthData();
    _isLoggedIn = false;
    _isLoaded = true;
    notifyListeners();
  }
}
