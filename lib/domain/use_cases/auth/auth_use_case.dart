import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/repositories/auth/auth_repository.dart';
import 'package:travel_app/utils/result.dart';

/// AuthUseCaseのプロバイダ
final authUseCaseProvider = Provider<AuthUseCase>((ref) {
  return AuthUseCase(ref: ref);
});

/// 認証関連のビジネスロジックを担当するUseCase
class AuthUseCase {
  /// コンストラクタ
  AuthUseCase({required this.ref});

  /// Provider参照用のref
  final Ref ref;

  /// ログイン済みかどうかを確認する
  Future<bool> checkIsLoggedIn() async {
    return await ref.read(authRepositoryProvider).isLoggedIn;
  }

  /// ログインを実行する
  Future<Result<void>> login({
    required String username,
    required String password,
  }) async {
    return await ref
        .read(authRepositoryProvider)
        .login(username: username, password: password);
  }

  /// ログアウトを実行する
  ///
  /// 認証情報のクリア、キャッシュの破棄など、ログアウト時に必要な
  /// 一連の手順をここに集約します。
  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    // 他のリポジトリのクリア処理などが必要になればここに追加する
  }
}
