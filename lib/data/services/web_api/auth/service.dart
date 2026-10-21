import 'package:travel_app/data/services/web_api/auth/dto.dart';
import 'package:travel_app/utils/result.dart';

/// 認証APIサービスインターフェース
abstract class AuthApiService {
  /// 新規ユーザー登録
  Future<Result<TokenResponseDto>> register({
    required String email,
    required String password,
    String? displayName,
  });

  /// ログイン
  Future<Result<TokenResponseDto>> login({
    required String email,
    required String password,
  });

  /// ログアウト
  Future<Result<void>> logout({required String refreshToken});

  /// ログインユーザー取得
  Future<Result<UserDto>> me();
}
