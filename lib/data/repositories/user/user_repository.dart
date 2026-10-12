import 'package:travel_app/data/services/web_api/users/dto.dart' as dto;
import 'package:travel_app/data/services/web_api/users/dto.dart'
    show UserDto;
import 'package:travel_app/data/services/web_api/users/service.dart';
import 'package:travel_app/data/services/web_api/users/service_impl.dart'
    show usersApiServiceProvider;
import 'package:travel_app/domain/entities/user/user.dart';
import 'package:travel_app/domain/errors/app_error.dart';
import 'package:travel_app/utils/logger.dart';
import 'package:travel_app/utils/result.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// プロバイダ
final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(
    usersApiService: ref.watch(usersApiServiceProvider),
  ),
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

  /// [UserDto] を [User] エンティティに変換します。
  User? _toEntity({required UserDto dto}) {
    // 必須フィールドが欠損している場合はnullを返す
    if (dto.id == null) {
      return null;
    }

    return User(
      id: dto.id!,
      firstName: dto.firstName ?? '',
      lastName: dto.lastName ?? '',
      maidenName: dto.maidenName ?? '',
      age: dto.age ?? 0,
      gender: dto.gender ?? '',
      email: dto.email ?? '',
      phone: dto.phone ?? '',
      username: dto.username ?? '',
      password: dto.password ?? '',
      birthDate: dto.birthDate ?? '',
      image: dto.image ?? '',
      bloodGroup: dto.bloodGroup ?? '',
      height: dto.height ?? 0.0,
      weight: dto.weight ?? 0.0,
      eyeColor: dto.eyeColor ?? '',
      hair: _toHairEntity(hairDto: dto.hair),
      ip: dto.ip ?? '',
      address: _toAddressEntity(addressDto: dto.address),
      macAddress: dto.macAddress ?? '',
      university: dto.university ?? '',
      bank: _toBankEntity(bankDto: dto.bank),
      company: _toCompanyEntity(companyDto: dto.company),
      ein: dto.ein ?? '',
      ssn: dto.ssn ?? '',
      userAgent: dto.userAgent ?? '',
      crypto: _toCryptoEntity(cryptoDto: dto.crypto),
      role: dto.role ?? '',
    );
  }

  Hair _toHairEntity({required dto.Hair? hairDto}) {
    return Hair(
      color: hairDto?.color ?? '',
      type: hairDto?.type ?? '',
    );
  }

  Address _toAddressEntity({required dto.Address? addressDto}) {
    return Address(
      address: addressDto?.address ?? '',
      city: addressDto?.city ?? '',
      state: addressDto?.state ?? '',
      stateCode: addressDto?.stateCode ?? '',
      postalCode: addressDto?.postalCode ?? '',
      coordinates: _toCoordinatesEntity(
        coordinatesDto: addressDto?.coordinates,
      ),
      country: addressDto?.country ?? '',
    );
  }

  Coordinates _toCoordinatesEntity({required dto.Coordinates? coordinatesDto}) {
    return Coordinates(
      lat: coordinatesDto?.lat ?? 0.0,
      lng: coordinatesDto?.lng ?? 0.0,
    );
  }

  Bank _toBankEntity({required dto.Bank? bankDto}) {
    return Bank(
      cardExpire: bankDto?.cardExpire ?? '',
      cardNumber: bankDto?.cardNumber ?? '',
      cardType: bankDto?.cardType ?? '',
      currency: bankDto?.currency ?? '',
      iban: bankDto?.iban ?? '',
    );
  }

  Company _toCompanyEntity({required dto.Company? companyDto}) {
    return Company(
      department: companyDto?.department ?? '',
      name: companyDto?.name ?? '',
      title: companyDto?.title ?? '',
      address: _toAddressEntity(addressDto: companyDto?.address),
    );
  }

  Crypto _toCryptoEntity({required dto.Crypto? cryptoDto}) {
    return Crypto(
      coin: cryptoDto?.coin ?? '',
      wallet: cryptoDto?.wallet ?? '',
      network: cryptoDto?.network ?? '',
    );
  }
}
