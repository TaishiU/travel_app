import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/braze/braze_attribute_key.dart';
import 'package:travel_app/data/services/braze/user_identity/user_identity_service.dart';
import 'package:travel_app/data/services/braze/user_identity/user_identity_service_impl.dart';
import 'package:travel_app/data/services/local_storage/secure_storage/auth/auth_secure_storage_service_impl.dart';
import 'package:travel_app/data/services/web_api/api_exception.dart';
import 'package:travel_app/data/services/web_api/auth/dto.dart';
import 'package:travel_app/data/services/web_api/auth/service.dart';
import 'package:travel_app/data/services/web_api/auth/service_impl.dart';
import 'package:travel_app/domain/entities/user/user.dart';
import 'package:travel_app/domain/errors/app_error.dart';
import 'package:travel_app/domain/interfaces/auth/auth_repository.dart';
import 'package:travel_app/utils/logger.dart';
import 'package:travel_app/utils/result.dart';
import 'package:uuid/uuid.dart';

/// UUID 生成関数の型。テスト時に固定値を注入できるようにするための抽象化。
typedef IdGenerator = String Function();

/// プロバイダ
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    authApiService: ref.read(authApiServiceImplProvider),
    authSecureStorageService: ref.read(authSecureStorageServiceImplProvider),
    idGenerator: () => const Uuid().v4(),
    userIdentityService: ref.read(userIdentityServiceImplProvider),
  ),
);

/// [AuthRepository] の実装クラス。
class AuthRepositoryImpl extends ChangeNotifier implements AuthRepository {
  /// コンストラクタ
  AuthRepositoryImpl({
    required this.authApiService,
    required this.authSecureStorageService,
    required this.idGenerator,
    required this.userIdentityService,
  });

  /// Authに関連するAPI通信を抽象化したサービスインターフェース
  final AuthApiService authApiService;

  /// Authに関連するデータをセキュアに永続化するサービス
  final AuthSecureStorageServiceImpl authSecureStorageService;

  /// UUID 生成関数（本番: Uuid().v4()、テスト: 固定値）
  final IdGenerator idGenerator;

  /// Braze ユーザー識別サービス
  final UserIdentityService userIdentityService;

  bool? _isLoggedIn;
  bool _isLoaded = false;
  String? _pendingDeepLink;

  // ---------------------------------------------------------------------------
  // AuthRepository
  // ---------------------------------------------------------------------------

  @override
  Future<bool> get isLoggedIn async {
    if (!_isLoaded) {
      await _ensureLoaded();
    }
    _loadLoginState();
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
    await _callLogoutApi();
    await authSecureStorageService.clearAuthData();
    await _issueNewAnonymousId();
    _isLoggedIn = false;
    _isLoaded = true;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Private: _ensureLoaded の子メソッド
  // ---------------------------------------------------------------------------

  Future<void> _ensureLoaded() async {
    if (_isLoaded) return;
    await authSecureStorageService.init();
    _loadLoginState();
    await _ensureAnonymousId();
    _isLoaded = true;
  }

  /// accessToken の有無から _isLoggedIn を設定する。
  void _loadLoginState() {
    _isLoggedIn = authSecureStorageService.getAccessToken().isNotEmpty;
  }

  /// anonymousId を確保し、未ログイン時に Braze 匿名セッションを確立する。
  /// ログイン済みの場合は changeUser を呼ばない（_persistUserId で設定済みのため上書きしない）。
  Future<void> _ensureAnonymousId() async {
    var anonymousId = authSecureStorageService.getAnonymousId();
    if (anonymousId.isEmpty) {
      anonymousId = idGenerator();
      await authSecureStorageService.setAnonymousId(id: anonymousId);
    }
    if (!(_isLoggedIn ?? false)) {
      userIdentityService
        ..changeUser(userId: anonymousId)
        ..setStringCustomAttribute(
          key: BrazeAttributeKey.anonymousId,
          value: anonymousId,
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Private: _saveTokens の子メソッド
  // ---------------------------------------------------------------------------

  Future<void> _saveTokens({required TokenResponseDto dto}) async {
    final accessToken = dto.accessToken ?? '';
    final refreshToken = dto.refreshToken ?? '';
    if (accessToken.isEmpty || refreshToken.isEmpty) {
      throw InternalServerErrorException(
        message: 'accessToken or refreshToken is empty',
      );
    }
    await _persistTokenPair(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await _persistUserId(userId: dto.user?.id ?? '');
    _isLoggedIn = true;
    _isLoaded = true;
  }

  /// accessToken / refreshToken を永続化する。
  Future<void> _persistTokenPair({
    required String accessToken,
    required String refreshToken,
  }) async {
    await authSecureStorageService.setAccessToken(token: accessToken);
    await authSecureStorageService.setRefreshToken(token: refreshToken);
  }

  /// user_id を永続化する。空なら no-op。
  /// anonymous_id → user_id への Braze ユーザー切り替えもここで行う。
  Future<void> _persistUserId({required String userId}) async {
    if (userId.isEmpty) return;
    await authSecureStorageService.setUserId(id: userId);
    userIdentityService.changeUser(userId: userId);
    userIdentityService.setStringCustomAttribute(
      key: BrazeAttributeKey.anonymousId,
      value: authSecureStorageService.getAnonymousId(),
    );
  }

  // ---------------------------------------------------------------------------
  // Private: logout の子メソッド
  // ---------------------------------------------------------------------------

  /// ログアウト API を呼び出す。失敗しても後続処理を続行する。
  Future<void> _callLogoutApi() async {
    final refreshToken = authSecureStorageService.getRefreshToken();
    try {
      await authApiService.logout(refreshToken: refreshToken);
    } on Exception catch (error) {
      logger.e(message: '[AuthRepositoryImpl] logout API error: $error');
    }
  }

  /// ログアウト後の匿名セッション用に新しい UUID を発行・保存する。
  /// Braze のユーザーセッションを終了してから新しい匿名ユーザーとして開始する。
  Future<void> _issueNewAnonymousId() async {
    final id = idGenerator();
    await authSecureStorageService.setAnonymousId(id: id);
    try {
      await userIdentityService.logoutSession();
    } on Exception catch (error) {
      logger.e(message: '[AuthRepositoryImpl] logoutSession error: $error');
    }
    userIdentityService.changeUser(userId: id);
  }

  // ---------------------------------------------------------------------------
  // Private: DTO → Entity 変換
  // ---------------------------------------------------------------------------

  User? _toUser({required UserDto dto}) {
    final id = dto.id;
    final email = dto.email;
    if (id == null || email == null) return null;
    return User(id: id, email: email, displayName: dto.displayName);
  }
}
