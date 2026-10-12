// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: (json['id'] as num).toInt(),
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  maidenName: json['maidenName'] as String,
  age: (json['age'] as num).toInt(),
  gender: json['gender'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
  username: json['username'] as String,
  password: json['password'] as String,
  birthDate: json['birthDate'] as String,
  image: json['image'] as String,
  bloodGroup: json['bloodGroup'] as String,
  height: (json['height'] as num).toDouble(),
  weight: (json['weight'] as num).toDouble(),
  eyeColor: json['eyeColor'] as String,
  hair: Hair.fromJson(json['hair'] as Map<String, dynamic>),
  ip: json['ip'] as String,
  address: Address.fromJson(json['address'] as Map<String, dynamic>),
  macAddress: json['macAddress'] as String,
  university: json['university'] as String,
  bank: Bank.fromJson(json['bank'] as Map<String, dynamic>),
  company: Company.fromJson(json['company'] as Map<String, dynamic>),
  ein: json['ein'] as String,
  ssn: json['ssn'] as String,
  userAgent: json['userAgent'] as String,
  crypto: Crypto.fromJson(json['crypto'] as Map<String, dynamic>),
  role: json['role'] as String,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'maidenName': instance.maidenName,
  'age': instance.age,
  'gender': instance.gender,
  'email': instance.email,
  'phone': instance.phone,
  'username': instance.username,
  'password': instance.password,
  'birthDate': instance.birthDate,
  'image': instance.image,
  'bloodGroup': instance.bloodGroup,
  'height': instance.height,
  'weight': instance.weight,
  'eyeColor': instance.eyeColor,
  'hair': instance.hair,
  'ip': instance.ip,
  'address': instance.address,
  'macAddress': instance.macAddress,
  'university': instance.university,
  'bank': instance.bank,
  'company': instance.company,
  'ein': instance.ein,
  'ssn': instance.ssn,
  'userAgent': instance.userAgent,
  'crypto': instance.crypto,
  'role': instance.role,
};

_Hair _$HairFromJson(Map<String, dynamic> json) =>
    _Hair(color: json['color'] as String, type: json['type'] as String);

Map<String, dynamic> _$HairToJson(_Hair instance) => <String, dynamic>{
  'color': instance.color,
  'type': instance.type,
};

_Address _$AddressFromJson(Map<String, dynamic> json) => _Address(
  address: json['address'] as String,
  city: json['city'] as String,
  state: json['state'] as String,
  stateCode: json['stateCode'] as String,
  postalCode: json['postalCode'] as String,
  coordinates: Coordinates.fromJson(
    json['coordinates'] as Map<String, dynamic>,
  ),
  country: json['country'] as String,
);

Map<String, dynamic> _$AddressToJson(_Address instance) => <String, dynamic>{
  'address': instance.address,
  'city': instance.city,
  'state': instance.state,
  'stateCode': instance.stateCode,
  'postalCode': instance.postalCode,
  'coordinates': instance.coordinates,
  'country': instance.country,
};

_Coordinates _$CoordinatesFromJson(Map<String, dynamic> json) => _Coordinates(
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
);

Map<String, dynamic> _$CoordinatesToJson(_Coordinates instance) =>
    <String, dynamic>{'lat': instance.lat, 'lng': instance.lng};

_Bank _$BankFromJson(Map<String, dynamic> json) => _Bank(
  cardExpire: json['cardExpire'] as String,
  cardNumber: json['cardNumber'] as String,
  cardType: json['cardType'] as String,
  currency: json['currency'] as String,
  iban: json['iban'] as String,
);

Map<String, dynamic> _$BankToJson(_Bank instance) => <String, dynamic>{
  'cardExpire': instance.cardExpire,
  'cardNumber': instance.cardNumber,
  'cardType': instance.cardType,
  'currency': instance.currency,
  'iban': instance.iban,
};

_Company _$CompanyFromJson(Map<String, dynamic> json) => _Company(
  department: json['department'] as String,
  name: json['name'] as String,
  title: json['title'] as String,
  address: Address.fromJson(json['address'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CompanyToJson(_Company instance) => <String, dynamic>{
  'department': instance.department,
  'name': instance.name,
  'title': instance.title,
  'address': instance.address,
};

_Crypto _$CryptoFromJson(Map<String, dynamic> json) => _Crypto(
  coin: json['coin'] as String,
  wallet: json['wallet'] as String,
  network: json['network'] as String,
);

Map<String, dynamic> _$CryptoToJson(_Crypto instance) => <String, dynamic>{
  'coin': instance.coin,
  'wallet': instance.wallet,
  'network': instance.network,
};
