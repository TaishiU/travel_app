import 'package:flutter/foundation.dart';
import 'package:travel_app/domain/entities/user/user.dart';
import 'package:travel_app/utils/result.dart';

/// 認証リポジトリのインターフェース。
abstract class AuthRepository implements Listenable {
  /// ログイン済みかどうか。
  Future<bool> get isLoggedIn;

  /// ログインを実行する。
  Future<Result<void>> login({required String email, required String password});

  /// 新規登録を実行する。
  Future<Result<void>> register({
    required String email,
    required String password,
    String? displayName,
  });

  /// ログインユーザーの基本情報を取得する。
  Future<Result<User>> me();

  /// 保存済みのディープリンク。
  String? get pendingDeepLink;

  /// ハードガード画面へのアクセス時にディープリンクを保存する。
  set pendingDeepLink(String path);

  /// 保存済みのディープリンクを取得してクリアする。
  String? getAndClearPendingDeepLink();

  /// ログアウトを実行する。
  Future<void> logout();
}
