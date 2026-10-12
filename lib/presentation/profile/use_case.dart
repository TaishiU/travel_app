import 'package:travel_app/data/repositories/user/user_repository.dart';
import 'package:travel_app/domain/entities/user/user.dart';
import 'package:travel_app/presentation/profile/state.dart';
import 'package:travel_app/utils/logger.dart';
import 'package:travel_app/utils/result.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    final user = await fetchUser();
    return ProfileScreenState(
      user: user,
    );
  }

  /// ユーザー情報を取得する。失敗時は throw。
  Future<User> fetchUser() async {
    final result = await ref.read(userRepositoryProvider).fetch();
    return switch (result) {
      SuccessResult(:final value) => value,
      FailureResult(:final error) => () {
        logger.e(message: '[ProfileScreenUseCase] fetchUser error: $error');
        throw error;
      }(),
    };
  }
}
