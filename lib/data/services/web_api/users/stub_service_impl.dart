import 'package:travel_app/data/services/web_api/users/dto.dart';
import 'package:travel_app/data/services/web_api/users/service.dart';
import 'package:travel_app/utils/result.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// プロバイダ
final stubUsersApiServiceImplProvider = Provider<StubUsersApiServiceImpl>(
  (ref) => StubUsersApiServiceImpl(),
);

/// スタブ実装クラス
class StubUsersApiServiceImpl implements UsersApiService {
  /// コンストラクタ
  StubUsersApiServiceImpl();

  @override
  Future<Result<UserDto>> fetchById() async {
    const userDto = UserDto(
      id: 1,
      firstName: 'Emily',
      lastName: 'Johnson',
      maidenName: 'Smith',
      age: 28,
      gender: 'female',
      email: 'emily.johnson@x.dummyjson.com',
      phone: '+81 965-431-3024',
      username: 'emilys',
      password: 'emilyspass',
      birthDate: '1996-5-30',
      image: 'https://placehold.jp/400x400.png',
      bloodGroup: 'O-',
      height: 193.24,
      weight: 63.16,
      eyeColor: 'Green',
      hair: Hair(
        color: 'Brown',
        type: 'Curly',
      ),
      ip: '42.48.100.32',
      address: Address(
        address: '626 Main Street',
        city: 'Phoenix',
        state: 'Mississippi',
        stateCode: 'MS',
        postalCode: '29112',
        coordinates: Coordinates(
          lat: -77.16213,
          lng: -92.084824,
        ),
        country: 'United States',
      ),
      macAddress: '47:fa:41:18:ec:eb',
      university: 'University of Wisconsin--Madison',
      bank: Bank(
        cardExpire: '03/26',
        cardNumber: '9289760655481815',
        cardType: 'Elo',
        currency: 'CNY',
        iban: 'YPUXISOBI7TTHPK2BR3HAIXL',
      ),
      company: Company(
        department: 'Engineering',
        name: 'Dooley, Kozey and Cronin',
        title: 'Sales Manager',
        address: Address(
          address: '263 Tenth Street',
          city: 'San Francisco',
          state: 'Wisconsin',
          stateCode: 'WI',
          postalCode: '37657',
          coordinates: Coordinates(
            lat: 71.814525,
            lng: -161.150263,
          ),
          country: 'United States',
        ),
      ),
      ein: '977-175',
      ssn: '900-590-289',
      userAgent:
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.93 Safari/537.36',
      crypto: Crypto(
        coin: 'Bitcoin',
        wallet: '0xb9fc2fe63b2a6c003f1c324c3bfa53259162181a',
        network: 'Ethereum (ERC20)',
      ),
      role: 'admin',
    );

    return const SuccessResult(userDto);
  }
}
