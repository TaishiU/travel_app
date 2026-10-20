import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/repositories/auth/auth_repository_impl.dart';
import 'package:travel_app/domain/entities/user/user.dart';
import 'package:travel_app/domain/use_cases/auth/auth_use_case.dart';
import 'package:travel_app/presentation/profile/state.dart';
import 'package:travel_app/utils/logger.dart';
import 'package:travel_app/utils/result.dart';

/// ProfileScreenUseCaseのプロバイダ
final profileScreenUseCaseProvider = Provider<ProfileScreenUseCase>(
  (ref) => ProfileScreenUseCase(ref: ref),
);

/// プロフィール画面の関心事に属すロジックを担当するUseCase
class ProfileScreenUseCase {
  /// コンストラクタ
  ProfileScreenUseCase({required this.ref});

  /// Provider参照用のref
  final Ref ref;

  /// プロフィール画面の初期状態を構築する
  Future<ProfileScreenState> initState() async {
    final isLoggedIn = await ref.read(authUseCaseProvider).checkIsLoggedIn();
    if (!isLoggedIn) {
      return const ProfileScreenState();
    }
    final user = await fetchMe();
    return ProfileScreenState(user: user, isLoggedIn: isLoggedIn);
  }

  /// ログインユーザーの基本情報を取得する。失敗時は throw。
  Future<User> fetchMe() async {
    final result = await ref.read(authRepositoryProvider).me();
    return switch (result) {
      SuccessResult(:final value) => value,
      FailureResult(:final error) => () {
        logger.e(message: '[ProfileScreenUseCase] fetchMe error: $error');
        throw error;
      }(),
    };
  }
}
