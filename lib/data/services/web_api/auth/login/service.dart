import 'package:travel_app/data/services/web_api/auth/login/dto.dart';
import 'package:travel_app/utils/result.dart';

/// インターフェース
abstract class AuthApiService {
  /// ログイン
  Future<Result<LoginDto>> login({
    required String username,
    required String password,
  });
}
