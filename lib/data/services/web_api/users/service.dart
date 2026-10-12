import 'package:travel_app/data/services/web_api/users/dto.dart';
import 'package:travel_app/utils/result.dart';

/// インターフェース
abstract class UsersApiService {
  /// [UserDto] を取得
  Future<Result<UserDto>> fetchById();
}
