import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/web_api/users/dto.dart' show UserDto;
import 'package:travel_app/data/services/web_api/users/service.dart';
import 'package:travel_app/data/services/web_api/users/service_impl.dart'
    show usersApiServiceProvider;
import 'package:travel_app/domain/entities/user/user.dart';
import 'package:travel_app/domain/errors/app_error.dart';
import 'package:travel_app/utils/logger.dart';
import 'package:travel_app/utils/result.dart';

/// プロバイダ
final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(usersApiService: ref.watch(usersApiServiceProvider)),
);

/// リポジトリクラス
class UserRepository {
  /// コンストラクタ
  UserRepository({required this.usersApiService});

  /// Userに関連するAPI通信を抽象化したサービスインターフェース。
  final UsersApiService usersApiService;

  /// [User] を取得
  Future<Result<User>> fetch() async {
    try {
      final result = await usersApiService.fetchById();

      switch (result) {
        case SuccessResult<UserDto>():
          final user = _toEntity(dto: result.value);
          if (user == null) {
            return const FailureResult(UnknownError());
          }
          return SuccessResult(user);
        case FailureResult<UserDto>():
          logger.e(message: '[UserRepository] ${result.error}');
          return FailureResult(AppError.from(result.error));
      }
    } on Exception catch (error) {
      return FailureResult(AppError.from(error));
    }
  }

  User? _toEntity({required UserDto dto}) {
    final id = dto.id;
    if (id == null) return null;
    return User(id: id.toString(), email: dto.email ?? '');
  }
}
