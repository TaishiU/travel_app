// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$User {

/// ID
 int get id;/// 名
 String get firstName;/// 姓
 String get lastName;/// 旧姓
 String get maidenName;/// 年齢
 int get age;/// 性別
 String get gender;/// メールアドレス
 String get email;/// 電話番号
 String get phone;/// ユーザー名
 String get username;/// パスワード
 String get password;/// 生年月日
 String get birthDate;/// 画像
 String get image;/// 血液型
 String get bloodGroup;/// 身長
 double get height;/// 体重
 double get weight;/// 目の色
 String get eyeColor;/// 髪
 Hair get hair;/// IPアドレス
 String get ip;/// 住所
 Address get address;/// MACアドレス
 String get macAddress;/// 大学
 String get university;/// 銀行
 Bank get bank;/// 会社
 Company get company;/// EIN
 String get ein;/// SSN
 String get ssn;/// ユーザーエージェント
 String get userAgent;/// 暗号資産
 Crypto get crypto;/// 役割
 String get role;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.maidenName, maidenName) || other.maidenName == maidenName)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.image, image) || other.image == image)&&(identical(other.bloodGroup, bloodGroup) || other.bloodGroup == bloodGroup)&&(identical(other.height, height) || other.height == height)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.eyeColor, eyeColor) || other.eyeColor == eyeColor)&&(identical(other.hair, hair) || other.hair == hair)&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.address, address) || other.address == address)&&(identical(other.macAddress, macAddress) || other.macAddress == macAddress)&&(identical(other.university, university) || other.university == university)&&(identical(other.bank, bank) || other.bank == bank)&&(identical(other.company, company) || other.company == company)&&(identical(other.ein, ein) || other.ein == ein)&&(identical(other.ssn, ssn) || other.ssn == ssn)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.crypto, crypto) || other.crypto == crypto)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,firstName,lastName,maidenName,age,gender,email,phone,username,password,birthDate,image,bloodGroup,height,weight,eyeColor,hair,ip,address,macAddress,university,bank,company,ein,ssn,userAgent,crypto,role]);

@override
String toString() {
  return 'User(id: $id, firstName: $firstName, lastName: $lastName, maidenName: $maidenName, age: $age, gender: $gender, email: $email, phone: $phone, username: $username, password: $password, birthDate: $birthDate, image: $image, bloodGroup: $bloodGroup, height: $height, weight: $weight, eyeColor: $eyeColor, hair: $hair, ip: $ip, address: $address, macAddress: $macAddress, university: $university, bank: $bank, company: $company, ein: $ein, ssn: $ssn, userAgent: $userAgent, crypto: $crypto, role: $role)';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 int id, String firstName, String lastName, String maidenName, int age, String gender, String email, String phone, String username, String password, String birthDate, String image, String bloodGroup, double height, double weight, String eyeColor, Hair hair, String ip, Address address, String macAddress, String university, Bank bank, Company company, String ein, String ssn, String userAgent, Crypto crypto, String role
});


$HairCopyWith<$Res> get hair;$AddressCopyWith<$Res> get address;$BankCopyWith<$Res> get bank;$CompanyCopyWith<$Res> get company;$CryptoCopyWith<$Res> get crypto;

}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? maidenName = null,Object? age = null,Object? gender = null,Object? email = null,Object? phone = null,Object? username = null,Object? password = null,Object? birthDate = null,Object? image = null,Object? bloodGroup = null,Object? height = null,Object? weight = null,Object? eyeColor = null,Object? hair = null,Object? ip = null,Object? address = null,Object? macAddress = null,Object? university = null,Object? bank = null,Object? company = null,Object? ein = null,Object? ssn = null,Object? userAgent = null,Object? crypto = null,Object? role = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,maidenName: null == maidenName ? _self.maidenName : maidenName // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,bloodGroup: null == bloodGroup ? _self.bloodGroup : bloodGroup // ignore: cast_nullable_to_non_nullable
as String,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,eyeColor: null == eyeColor ? _self.eyeColor : eyeColor // ignore: cast_nullable_to_non_nullable
as String,hair: null == hair ? _self.hair : hair // ignore: cast_nullable_to_non_nullable
as Hair,ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as Address,macAddress: null == macAddress ? _self.macAddress : macAddress // ignore: cast_nullable_to_non_nullable
as String,university: null == university ? _self.university : university // ignore: cast_nullable_to_non_nullable
as String,bank: null == bank ? _self.bank : bank // ignore: cast_nullable_to_non_nullable
as Bank,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as Company,ein: null == ein ? _self.ein : ein // ignore: cast_nullable_to_non_nullable
as String,ssn: null == ssn ? _self.ssn : ssn // ignore: cast_nullable_to_non_nullable
as String,userAgent: null == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String,crypto: null == crypto ? _self.crypto : crypto // ignore: cast_nullable_to_non_nullable
as Crypto,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HairCopyWith<$Res> get hair {
  
  return $HairCopyWith<$Res>(_self.hair, (value) {
    return _then(_self.copyWith(hair: value));
  });
}/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressCopyWith<$Res> get address {
  
  return $AddressCopyWith<$Res>(_self.address, (value) {
    return _then(_self.copyWith(address: value));
  });
}/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BankCopyWith<$Res> get bank {
  
  return $BankCopyWith<$Res>(_self.bank, (value) {
    return _then(_self.copyWith(bank: value));
  });
}/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanyCopyWith<$Res> get company {
  
  return $CompanyCopyWith<$Res>(_self.company, (value) {
    return _then(_self.copyWith(company: value));
  });
}/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CryptoCopyWith<$Res> get crypto {
  
  return $CryptoCopyWith<$Res>(_self.crypto, (value) {
    return _then(_self.copyWith(crypto: value));
  });
}
}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String firstName,  String lastName,  String maidenName,  int age,  String gender,  String email,  String phone,  String username,  String password,  String birthDate,  String image,  String bloodGroup,  double height,  double weight,  String eyeColor,  Hair hair,  String ip,  Address address,  String macAddress,  String university,  Bank bank,  Company company,  String ein,  String ssn,  String userAgent,  Crypto crypto,  String role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.maidenName,_that.age,_that.gender,_that.email,_that.phone,_that.username,_that.password,_that.birthDate,_that.image,_that.bloodGroup,_that.height,_that.weight,_that.eyeColor,_that.hair,_that.ip,_that.address,_that.macAddress,_that.university,_that.bank,_that.company,_that.ein,_that.ssn,_that.userAgent,_that.crypto,_that.role);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String firstName,  String lastName,  String maidenName,  int age,  String gender,  String email,  String phone,  String username,  String password,  String birthDate,  String image,  String bloodGroup,  double height,  double weight,  String eyeColor,  Hair hair,  String ip,  Address address,  String macAddress,  String university,  Bank bank,  Company company,  String ein,  String ssn,  String userAgent,  Crypto crypto,  String role)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.firstName,_that.lastName,_that.maidenName,_that.age,_that.gender,_that.email,_that.phone,_that.username,_that.password,_that.birthDate,_that.image,_that.bloodGroup,_that.height,_that.weight,_that.eyeColor,_that.hair,_that.ip,_that.address,_that.macAddress,_that.university,_that.bank,_that.company,_that.ein,_that.ssn,_that.userAgent,_that.crypto,_that.role);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String firstName,  String lastName,  String maidenName,  int age,  String gender,  String email,  String phone,  String username,  String password,  String birthDate,  String image,  String bloodGroup,  double height,  double weight,  String eyeColor,  Hair hair,  String ip,  Address address,  String macAddress,  String university,  Bank bank,  Company company,  String ein,  String ssn,  String userAgent,  Crypto crypto,  String role)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.maidenName,_that.age,_that.gender,_that.email,_that.phone,_that.username,_that.password,_that.birthDate,_that.image,_that.bloodGroup,_that.height,_that.weight,_that.eyeColor,_that.hair,_that.ip,_that.address,_that.macAddress,_that.university,_that.bank,_that.company,_that.ein,_that.ssn,_that.userAgent,_that.crypto,_that.role);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _User implements User {
  const _User({required this.id, required this.firstName, required this.lastName, required this.maidenName, required this.age, required this.gender, required this.email, required this.phone, required this.username, required this.password, required this.birthDate, required this.image, required this.bloodGroup, required this.height, required this.weight, required this.eyeColor, required this.hair, required this.ip, required this.address, required this.macAddress, required this.university, required this.bank, required this.company, required this.ein, required this.ssn, required this.userAgent, required this.crypto, required this.role});
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

/// ID
@override final  int id;
/// 名
@override final  String firstName;
/// 姓
@override final  String lastName;
/// 旧姓
@override final  String maidenName;
/// 年齢
@override final  int age;
/// 性別
@override final  String gender;
/// メールアドレス
@override final  String email;
/// 電話番号
@override final  String phone;
/// ユーザー名
@override final  String username;
/// パスワード
@override final  String password;
/// 生年月日
@override final  String birthDate;
/// 画像
@override final  String image;
/// 血液型
@override final  String bloodGroup;
/// 身長
@override final  double height;
/// 体重
@override final  double weight;
/// 目の色
@override final  String eyeColor;
/// 髪
@override final  Hair hair;
/// IPアドレス
@override final  String ip;
/// 住所
@override final  Address address;
/// MACアドレス
@override final  String macAddress;
/// 大学
@override final  String university;
/// 銀行
@override final  Bank bank;
/// 会社
@override final  Company company;
/// EIN
@override final  String ein;
/// SSN
@override final  String ssn;
/// ユーザーエージェント
@override final  String userAgent;
/// 暗号資産
@override final  Crypto crypto;
/// 役割
@override final  String role;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.maidenName, maidenName) || other.maidenName == maidenName)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.image, image) || other.image == image)&&(identical(other.bloodGroup, bloodGroup) || other.bloodGroup == bloodGroup)&&(identical(other.height, height) || other.height == height)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.eyeColor, eyeColor) || other.eyeColor == eyeColor)&&(identical(other.hair, hair) || other.hair == hair)&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.address, address) || other.address == address)&&(identical(other.macAddress, macAddress) || other.macAddress == macAddress)&&(identical(other.university, university) || other.university == university)&&(identical(other.bank, bank) || other.bank == bank)&&(identical(other.company, company) || other.company == company)&&(identical(other.ein, ein) || other.ein == ein)&&(identical(other.ssn, ssn) || other.ssn == ssn)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.crypto, crypto) || other.crypto == crypto)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,firstName,lastName,maidenName,age,gender,email,phone,username,password,birthDate,image,bloodGroup,height,weight,eyeColor,hair,ip,address,macAddress,university,bank,company,ein,ssn,userAgent,crypto,role]);

@override
String toString() {
  return 'User(id: $id, firstName: $firstName, lastName: $lastName, maidenName: $maidenName, age: $age, gender: $gender, email: $email, phone: $phone, username: $username, password: $password, birthDate: $birthDate, image: $image, bloodGroup: $bloodGroup, height: $height, weight: $weight, eyeColor: $eyeColor, hair: $hair, ip: $ip, address: $address, macAddress: $macAddress, university: $university, bank: $bank, company: $company, ein: $ein, ssn: $ssn, userAgent: $userAgent, crypto: $crypto, role: $role)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 int id, String firstName, String lastName, String maidenName, int age, String gender, String email, String phone, String username, String password, String birthDate, String image, String bloodGroup, double height, double weight, String eyeColor, Hair hair, String ip, Address address, String macAddress, String university, Bank bank, Company company, String ein, String ssn, String userAgent, Crypto crypto, String role
});


@override $HairCopyWith<$Res> get hair;@override $AddressCopyWith<$Res> get address;@override $BankCopyWith<$Res> get bank;@override $CompanyCopyWith<$Res> get company;@override $CryptoCopyWith<$Res> get crypto;

}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? maidenName = null,Object? age = null,Object? gender = null,Object? email = null,Object? phone = null,Object? username = null,Object? password = null,Object? birthDate = null,Object? image = null,Object? bloodGroup = null,Object? height = null,Object? weight = null,Object? eyeColor = null,Object? hair = null,Object? ip = null,Object? address = null,Object? macAddress = null,Object? university = null,Object? bank = null,Object? company = null,Object? ein = null,Object? ssn = null,Object? userAgent = null,Object? crypto = null,Object? role = null,}) {
  return _then(_User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,maidenName: null == maidenName ? _self.maidenName : maidenName // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,bloodGroup: null == bloodGroup ? _self.bloodGroup : bloodGroup // ignore: cast_nullable_to_non_nullable
as String,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,eyeColor: null == eyeColor ? _self.eyeColor : eyeColor // ignore: cast_nullable_to_non_nullable
as String,hair: null == hair ? _self.hair : hair // ignore: cast_nullable_to_non_nullable
as Hair,ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as Address,macAddress: null == macAddress ? _self.macAddress : macAddress // ignore: cast_nullable_to_non_nullable
as String,university: null == university ? _self.university : university // ignore: cast_nullable_to_non_nullable
as String,bank: null == bank ? _self.bank : bank // ignore: cast_nullable_to_non_nullable
as Bank,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as Company,ein: null == ein ? _self.ein : ein // ignore: cast_nullable_to_non_nullable
as String,ssn: null == ssn ? _self.ssn : ssn // ignore: cast_nullable_to_non_nullable
as String,userAgent: null == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String,crypto: null == crypto ? _self.crypto : crypto // ignore: cast_nullable_to_non_nullable
as Crypto,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HairCopyWith<$Res> get hair {
  
  return $HairCopyWith<$Res>(_self.hair, (value) {
    return _then(_self.copyWith(hair: value));
  });
}/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressCopyWith<$Res> get address {
  
  return $AddressCopyWith<$Res>(_self.address, (value) {
    return _then(_self.copyWith(address: value));
  });
}/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BankCopyWith<$Res> get bank {
  
  return $BankCopyWith<$Res>(_self.bank, (value) {
    return _then(_self.copyWith(bank: value));
  });
}/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanyCopyWith<$Res> get company {
  
  return $CompanyCopyWith<$Res>(_self.company, (value) {
    return _then(_self.copyWith(company: value));
  });
}/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CryptoCopyWith<$Res> get crypto {
  
  return $CryptoCopyWith<$Res>(_self.crypto, (value) {
    return _then(_self.copyWith(crypto: value));
  });
}
}


/// @nodoc
mixin _$Hair {

/// 色
 String get color;/// タイプ
 String get type;
/// Create a copy of Hair
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HairCopyWith<Hair> get copyWith => _$HairCopyWithImpl<Hair>(this as Hair, _$identity);

  /// Serializes this Hair to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Hair&&(identical(other.color, color) || other.color == color)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color,type);

@override
String toString() {
  return 'Hair(color: $color, type: $type)';
}


}

/// @nodoc
abstract mixin class $HairCopyWith<$Res>  {
  factory $HairCopyWith(Hair value, $Res Function(Hair) _then) = _$HairCopyWithImpl;
@useResult
$Res call({
 String color, String type
});




}
/// @nodoc
class _$HairCopyWithImpl<$Res>
    implements $HairCopyWith<$Res> {
  _$HairCopyWithImpl(this._self, this._then);

  final Hair _self;
  final $Res Function(Hair) _then;

/// Create a copy of Hair
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? color = null,Object? type = null,}) {
  return _then(_self.copyWith(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Hair].
extension HairPatterns on Hair {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Hair value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Hair() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Hair value)  $default,){
final _that = this;
switch (_that) {
case _Hair():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Hair value)?  $default,){
final _that = this;
switch (_that) {
case _Hair() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String color,  String type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Hair() when $default != null:
return $default(_that.color,_that.type);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String color,  String type)  $default,) {final _that = this;
switch (_that) {
case _Hair():
return $default(_that.color,_that.type);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String color,  String type)?  $default,) {final _that = this;
switch (_that) {
case _Hair() when $default != null:
return $default(_that.color,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Hair implements Hair {
  const _Hair({required this.color, required this.type});
  factory _Hair.fromJson(Map<String, dynamic> json) => _$HairFromJson(json);

/// 色
@override final  String color;
/// タイプ
@override final  String type;

/// Create a copy of Hair
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HairCopyWith<_Hair> get copyWith => __$HairCopyWithImpl<_Hair>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HairToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Hair&&(identical(other.color, color) || other.color == color)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color,type);

@override
String toString() {
  return 'Hair(color: $color, type: $type)';
}


}

/// @nodoc
abstract mixin class _$HairCopyWith<$Res> implements $HairCopyWith<$Res> {
  factory _$HairCopyWith(_Hair value, $Res Function(_Hair) _then) = __$HairCopyWithImpl;
@override @useResult
$Res call({
 String color, String type
});




}
/// @nodoc
class __$HairCopyWithImpl<$Res>
    implements _$HairCopyWith<$Res> {
  __$HairCopyWithImpl(this._self, this._then);

  final _Hair _self;
  final $Res Function(_Hair) _then;

/// Create a copy of Hair
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? color = null,Object? type = null,}) {
  return _then(_Hair(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Address {

/// 住所
 String get address;/// 市区町村
 String get city;/// 州
 String get state;/// 州コード
 String get stateCode;/// 郵便番号
 String get postalCode;/// 座標
 Coordinates get coordinates;/// 国
 String get country;
/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddressCopyWith<Address> get copyWith => _$AddressCopyWithImpl<Address>(this as Address, _$identity);

  /// Serializes this Address to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Address&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.stateCode, stateCode) || other.stateCode == stateCode)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.coordinates, coordinates) || other.coordinates == coordinates)&&(identical(other.country, country) || other.country == country));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,city,state,stateCode,postalCode,coordinates,country);

@override
String toString() {
  return 'Address(address: $address, city: $city, state: $state, stateCode: $stateCode, postalCode: $postalCode, coordinates: $coordinates, country: $country)';
}


}

/// @nodoc
abstract mixin class $AddressCopyWith<$Res>  {
  factory $AddressCopyWith(Address value, $Res Function(Address) _then) = _$AddressCopyWithImpl;
@useResult
$Res call({
 String address, String city, String state, String stateCode, String postalCode, Coordinates coordinates, String country
});


$CoordinatesCopyWith<$Res> get coordinates;

}
/// @nodoc
class _$AddressCopyWithImpl<$Res>
    implements $AddressCopyWith<$Res> {
  _$AddressCopyWithImpl(this._self, this._then);

  final Address _self;
  final $Res Function(Address) _then;

/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? address = null,Object? city = null,Object? state = null,Object? stateCode = null,Object? postalCode = null,Object? coordinates = null,Object? country = null,}) {
  return _then(_self.copyWith(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,stateCode: null == stateCode ? _self.stateCode : stateCode // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,coordinates: null == coordinates ? _self.coordinates : coordinates // ignore: cast_nullable_to_non_nullable
as Coordinates,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoordinatesCopyWith<$Res> get coordinates {
  
  return $CoordinatesCopyWith<$Res>(_self.coordinates, (value) {
    return _then(_self.copyWith(coordinates: value));
  });
}
}


/// Adds pattern-matching-related methods to [Address].
extension AddressPatterns on Address {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Address value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Address() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Address value)  $default,){
final _that = this;
switch (_that) {
case _Address():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Address value)?  $default,){
final _that = this;
switch (_that) {
case _Address() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String address,  String city,  String state,  String stateCode,  String postalCode,  Coordinates coordinates,  String country)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Address() when $default != null:
return $default(_that.address,_that.city,_that.state,_that.stateCode,_that.postalCode,_that.coordinates,_that.country);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String address,  String city,  String state,  String stateCode,  String postalCode,  Coordinates coordinates,  String country)  $default,) {final _that = this;
switch (_that) {
case _Address():
return $default(_that.address,_that.city,_that.state,_that.stateCode,_that.postalCode,_that.coordinates,_that.country);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String address,  String city,  String state,  String stateCode,  String postalCode,  Coordinates coordinates,  String country)?  $default,) {final _that = this;
switch (_that) {
case _Address() when $default != null:
return $default(_that.address,_that.city,_that.state,_that.stateCode,_that.postalCode,_that.coordinates,_that.country);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Address implements Address {
  const _Address({required this.address, required this.city, required this.state, required this.stateCode, required this.postalCode, required this.coordinates, required this.country});
  factory _Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);

/// 住所
@override final  String address;
/// 市区町村
@override final  String city;
/// 州
@override final  String state;
/// 州コード
@override final  String stateCode;
/// 郵便番号
@override final  String postalCode;
/// 座標
@override final  Coordinates coordinates;
/// 国
@override final  String country;

/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddressCopyWith<_Address> get copyWith => __$AddressCopyWithImpl<_Address>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Address&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.stateCode, stateCode) || other.stateCode == stateCode)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.coordinates, coordinates) || other.coordinates == coordinates)&&(identical(other.country, country) || other.country == country));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,city,state,stateCode,postalCode,coordinates,country);

@override
String toString() {
  return 'Address(address: $address, city: $city, state: $state, stateCode: $stateCode, postalCode: $postalCode, coordinates: $coordinates, country: $country)';
}


}

/// @nodoc
abstract mixin class _$AddressCopyWith<$Res> implements $AddressCopyWith<$Res> {
  factory _$AddressCopyWith(_Address value, $Res Function(_Address) _then) = __$AddressCopyWithImpl;
@override @useResult
$Res call({
 String address, String city, String state, String stateCode, String postalCode, Coordinates coordinates, String country
});


@override $CoordinatesCopyWith<$Res> get coordinates;

}
/// @nodoc
class __$AddressCopyWithImpl<$Res>
    implements _$AddressCopyWith<$Res> {
  __$AddressCopyWithImpl(this._self, this._then);

  final _Address _self;
  final $Res Function(_Address) _then;

/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? address = null,Object? city = null,Object? state = null,Object? stateCode = null,Object? postalCode = null,Object? coordinates = null,Object? country = null,}) {
  return _then(_Address(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,stateCode: null == stateCode ? _self.stateCode : stateCode // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,coordinates: null == coordinates ? _self.coordinates : coordinates // ignore: cast_nullable_to_non_nullable
as Coordinates,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoordinatesCopyWith<$Res> get coordinates {
  
  return $CoordinatesCopyWith<$Res>(_self.coordinates, (value) {
    return _then(_self.copyWith(coordinates: value));
  });
}
}


/// @nodoc
mixin _$Coordinates {

/// 緯度
 double get lat;/// 経度
 double get lng;
/// Create a copy of Coordinates
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoordinatesCopyWith<Coordinates> get copyWith => _$CoordinatesCopyWithImpl<Coordinates>(this as Coordinates, _$identity);

  /// Serializes this Coordinates to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Coordinates&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lat,lng);

@override
String toString() {
  return 'Coordinates(lat: $lat, lng: $lng)';
}


}

/// @nodoc
abstract mixin class $CoordinatesCopyWith<$Res>  {
  factory $CoordinatesCopyWith(Coordinates value, $Res Function(Coordinates) _then) = _$CoordinatesCopyWithImpl;
@useResult
$Res call({
 double lat, double lng
});




}
/// @nodoc
class _$CoordinatesCopyWithImpl<$Res>
    implements $CoordinatesCopyWith<$Res> {
  _$CoordinatesCopyWithImpl(this._self, this._then);

  final Coordinates _self;
  final $Res Function(Coordinates) _then;

/// Create a copy of Coordinates
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lat = null,Object? lng = null,}) {
  return _then(_self.copyWith(
lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Coordinates].
extension CoordinatesPatterns on Coordinates {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Coordinates value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Coordinates() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Coordinates value)  $default,){
final _that = this;
switch (_that) {
case _Coordinates():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Coordinates value)?  $default,){
final _that = this;
switch (_that) {
case _Coordinates() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double lat,  double lng)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Coordinates() when $default != null:
return $default(_that.lat,_that.lng);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double lat,  double lng)  $default,) {final _that = this;
switch (_that) {
case _Coordinates():
return $default(_that.lat,_that.lng);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double lat,  double lng)?  $default,) {final _that = this;
switch (_that) {
case _Coordinates() when $default != null:
return $default(_that.lat,_that.lng);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Coordinates implements Coordinates {
  const _Coordinates({required this.lat, required this.lng});
  factory _Coordinates.fromJson(Map<String, dynamic> json) => _$CoordinatesFromJson(json);

/// 緯度
@override final  double lat;
/// 経度
@override final  double lng;

/// Create a copy of Coordinates
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoordinatesCopyWith<_Coordinates> get copyWith => __$CoordinatesCopyWithImpl<_Coordinates>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoordinatesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Coordinates&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lat,lng);

@override
String toString() {
  return 'Coordinates(lat: $lat, lng: $lng)';
}


}

/// @nodoc
abstract mixin class _$CoordinatesCopyWith<$Res> implements $CoordinatesCopyWith<$Res> {
  factory _$CoordinatesCopyWith(_Coordinates value, $Res Function(_Coordinates) _then) = __$CoordinatesCopyWithImpl;
@override @useResult
$Res call({
 double lat, double lng
});




}
/// @nodoc
class __$CoordinatesCopyWithImpl<$Res>
    implements _$CoordinatesCopyWith<$Res> {
  __$CoordinatesCopyWithImpl(this._self, this._then);

  final _Coordinates _self;
  final $Res Function(_Coordinates) _then;

/// Create a copy of Coordinates
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lat = null,Object? lng = null,}) {
  return _then(_Coordinates(
lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$Bank {

/// カード有効期限
 String get cardExpire;/// カード番号
 String get cardNumber;/// カードタイプ
 String get cardType;/// 通貨
 String get currency;/// IBAN
 String get iban;
/// Create a copy of Bank
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BankCopyWith<Bank> get copyWith => _$BankCopyWithImpl<Bank>(this as Bank, _$identity);

  /// Serializes this Bank to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bank&&(identical(other.cardExpire, cardExpire) || other.cardExpire == cardExpire)&&(identical(other.cardNumber, cardNumber) || other.cardNumber == cardNumber)&&(identical(other.cardType, cardType) || other.cardType == cardType)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.iban, iban) || other.iban == iban));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cardExpire,cardNumber,cardType,currency,iban);

@override
String toString() {
  return 'Bank(cardExpire: $cardExpire, cardNumber: $cardNumber, cardType: $cardType, currency: $currency, iban: $iban)';
}


}

/// @nodoc
abstract mixin class $BankCopyWith<$Res>  {
  factory $BankCopyWith(Bank value, $Res Function(Bank) _then) = _$BankCopyWithImpl;
@useResult
$Res call({
 String cardExpire, String cardNumber, String cardType, String currency, String iban
});




}
/// @nodoc
class _$BankCopyWithImpl<$Res>
    implements $BankCopyWith<$Res> {
  _$BankCopyWithImpl(this._self, this._then);

  final Bank _self;
  final $Res Function(Bank) _then;

/// Create a copy of Bank
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cardExpire = null,Object? cardNumber = null,Object? cardType = null,Object? currency = null,Object? iban = null,}) {
  return _then(_self.copyWith(
cardExpire: null == cardExpire ? _self.cardExpire : cardExpire // ignore: cast_nullable_to_non_nullable
as String,cardNumber: null == cardNumber ? _self.cardNumber : cardNumber // ignore: cast_nullable_to_non_nullable
as String,cardType: null == cardType ? _self.cardType : cardType // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,iban: null == iban ? _self.iban : iban // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Bank].
extension BankPatterns on Bank {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Bank value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Bank() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Bank value)  $default,){
final _that = this;
switch (_that) {
case _Bank():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Bank value)?  $default,){
final _that = this;
switch (_that) {
case _Bank() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String cardExpire,  String cardNumber,  String cardType,  String currency,  String iban)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Bank() when $default != null:
return $default(_that.cardExpire,_that.cardNumber,_that.cardType,_that.currency,_that.iban);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String cardExpire,  String cardNumber,  String cardType,  String currency,  String iban)  $default,) {final _that = this;
switch (_that) {
case _Bank():
return $default(_that.cardExpire,_that.cardNumber,_that.cardType,_that.currency,_that.iban);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String cardExpire,  String cardNumber,  String cardType,  String currency,  String iban)?  $default,) {final _that = this;
switch (_that) {
case _Bank() when $default != null:
return $default(_that.cardExpire,_that.cardNumber,_that.cardType,_that.currency,_that.iban);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Bank implements Bank {
  const _Bank({required this.cardExpire, required this.cardNumber, required this.cardType, required this.currency, required this.iban});
  factory _Bank.fromJson(Map<String, dynamic> json) => _$BankFromJson(json);

/// カード有効期限
@override final  String cardExpire;
/// カード番号
@override final  String cardNumber;
/// カードタイプ
@override final  String cardType;
/// 通貨
@override final  String currency;
/// IBAN
@override final  String iban;

/// Create a copy of Bank
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BankCopyWith<_Bank> get copyWith => __$BankCopyWithImpl<_Bank>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BankToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bank&&(identical(other.cardExpire, cardExpire) || other.cardExpire == cardExpire)&&(identical(other.cardNumber, cardNumber) || other.cardNumber == cardNumber)&&(identical(other.cardType, cardType) || other.cardType == cardType)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.iban, iban) || other.iban == iban));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cardExpire,cardNumber,cardType,currency,iban);

@override
String toString() {
  return 'Bank(cardExpire: $cardExpire, cardNumber: $cardNumber, cardType: $cardType, currency: $currency, iban: $iban)';
}


}

/// @nodoc
abstract mixin class _$BankCopyWith<$Res> implements $BankCopyWith<$Res> {
  factory _$BankCopyWith(_Bank value, $Res Function(_Bank) _then) = __$BankCopyWithImpl;
@override @useResult
$Res call({
 String cardExpire, String cardNumber, String cardType, String currency, String iban
});




}
/// @nodoc
class __$BankCopyWithImpl<$Res>
    implements _$BankCopyWith<$Res> {
  __$BankCopyWithImpl(this._self, this._then);

  final _Bank _self;
  final $Res Function(_Bank) _then;

/// Create a copy of Bank
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cardExpire = null,Object? cardNumber = null,Object? cardType = null,Object? currency = null,Object? iban = null,}) {
  return _then(_Bank(
cardExpire: null == cardExpire ? _self.cardExpire : cardExpire // ignore: cast_nullable_to_non_nullable
as String,cardNumber: null == cardNumber ? _self.cardNumber : cardNumber // ignore: cast_nullable_to_non_nullable
as String,cardType: null == cardType ? _self.cardType : cardType // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,iban: null == iban ? _self.iban : iban // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Company {

/// 部署
 String get department;/// 会社名
 String get name;/// 役職
 String get title;/// 住所
 Address get address;
/// Create a copy of Company
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompanyCopyWith<Company> get copyWith => _$CompanyCopyWithImpl<Company>(this as Company, _$identity);

  /// Serializes this Company to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Company&&(identical(other.department, department) || other.department == department)&&(identical(other.name, name) || other.name == name)&&(identical(other.title, title) || other.title == title)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,department,name,title,address);

@override
String toString() {
  return 'Company(department: $department, name: $name, title: $title, address: $address)';
}


}

/// @nodoc
abstract mixin class $CompanyCopyWith<$Res>  {
  factory $CompanyCopyWith(Company value, $Res Function(Company) _then) = _$CompanyCopyWithImpl;
@useResult
$Res call({
 String department, String name, String title, Address address
});


$AddressCopyWith<$Res> get address;

}
/// @nodoc
class _$CompanyCopyWithImpl<$Res>
    implements $CompanyCopyWith<$Res> {
  _$CompanyCopyWithImpl(this._self, this._then);

  final Company _self;
  final $Res Function(Company) _then;

/// Create a copy of Company
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? department = null,Object? name = null,Object? title = null,Object? address = null,}) {
  return _then(_self.copyWith(
department: null == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as Address,
  ));
}
/// Create a copy of Company
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressCopyWith<$Res> get address {
  
  return $AddressCopyWith<$Res>(_self.address, (value) {
    return _then(_self.copyWith(address: value));
  });
}
}


/// Adds pattern-matching-related methods to [Company].
extension CompanyPatterns on Company {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Company value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Company() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Company value)  $default,){
final _that = this;
switch (_that) {
case _Company():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Company value)?  $default,){
final _that = this;
switch (_that) {
case _Company() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String department,  String name,  String title,  Address address)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Company() when $default != null:
return $default(_that.department,_that.name,_that.title,_that.address);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String department,  String name,  String title,  Address address)  $default,) {final _that = this;
switch (_that) {
case _Company():
return $default(_that.department,_that.name,_that.title,_that.address);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String department,  String name,  String title,  Address address)?  $default,) {final _that = this;
switch (_that) {
case _Company() when $default != null:
return $default(_that.department,_that.name,_that.title,_that.address);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Company implements Company {
  const _Company({required this.department, required this.name, required this.title, required this.address});
  factory _Company.fromJson(Map<String, dynamic> json) => _$CompanyFromJson(json);

/// 部署
@override final  String department;
/// 会社名
@override final  String name;
/// 役職
@override final  String title;
/// 住所
@override final  Address address;

/// Create a copy of Company
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompanyCopyWith<_Company> get copyWith => __$CompanyCopyWithImpl<_Company>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompanyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Company&&(identical(other.department, department) || other.department == department)&&(identical(other.name, name) || other.name == name)&&(identical(other.title, title) || other.title == title)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,department,name,title,address);

@override
String toString() {
  return 'Company(department: $department, name: $name, title: $title, address: $address)';
}


}

/// @nodoc
abstract mixin class _$CompanyCopyWith<$Res> implements $CompanyCopyWith<$Res> {
  factory _$CompanyCopyWith(_Company value, $Res Function(_Company) _then) = __$CompanyCopyWithImpl;
@override @useResult
$Res call({
 String department, String name, String title, Address address
});


@override $AddressCopyWith<$Res> get address;

}
/// @nodoc
class __$CompanyCopyWithImpl<$Res>
    implements _$CompanyCopyWith<$Res> {
  __$CompanyCopyWithImpl(this._self, this._then);

  final _Company _self;
  final $Res Function(_Company) _then;

/// Create a copy of Company
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? department = null,Object? name = null,Object? title = null,Object? address = null,}) {
  return _then(_Company(
department: null == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as Address,
  ));
}

/// Create a copy of Company
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressCopyWith<$Res> get address {
  
  return $AddressCopyWith<$Res>(_self.address, (value) {
    return _then(_self.copyWith(address: value));
  });
}
}


/// @nodoc
mixin _$Crypto {

/// コイン
 String get coin;/// ウォレット
 String get wallet;/// ネットワーク
 String get network;
/// Create a copy of Crypto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CryptoCopyWith<Crypto> get copyWith => _$CryptoCopyWithImpl<Crypto>(this as Crypto, _$identity);

  /// Serializes this Crypto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Crypto&&(identical(other.coin, coin) || other.coin == coin)&&(identical(other.wallet, wallet) || other.wallet == wallet)&&(identical(other.network, network) || other.network == network));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,coin,wallet,network);

@override
String toString() {
  return 'Crypto(coin: $coin, wallet: $wallet, network: $network)';
}


}

/// @nodoc
abstract mixin class $CryptoCopyWith<$Res>  {
  factory $CryptoCopyWith(Crypto value, $Res Function(Crypto) _then) = _$CryptoCopyWithImpl;
@useResult
$Res call({
 String coin, String wallet, String network
});




}
/// @nodoc
class _$CryptoCopyWithImpl<$Res>
    implements $CryptoCopyWith<$Res> {
  _$CryptoCopyWithImpl(this._self, this._then);

  final Crypto _self;
  final $Res Function(Crypto) _then;

/// Create a copy of Crypto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coin = null,Object? wallet = null,Object? network = null,}) {
  return _then(_self.copyWith(
coin: null == coin ? _self.coin : coin // ignore: cast_nullable_to_non_nullable
as String,wallet: null == wallet ? _self.wallet : wallet // ignore: cast_nullable_to_non_nullable
as String,network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Crypto].
extension CryptoPatterns on Crypto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Crypto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Crypto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Crypto value)  $default,){
final _that = this;
switch (_that) {
case _Crypto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Crypto value)?  $default,){
final _that = this;
switch (_that) {
case _Crypto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String coin,  String wallet,  String network)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Crypto() when $default != null:
return $default(_that.coin,_that.wallet,_that.network);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String coin,  String wallet,  String network)  $default,) {final _that = this;
switch (_that) {
case _Crypto():
return $default(_that.coin,_that.wallet,_that.network);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String coin,  String wallet,  String network)?  $default,) {final _that = this;
switch (_that) {
case _Crypto() when $default != null:
return $default(_that.coin,_that.wallet,_that.network);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Crypto implements Crypto {
  const _Crypto({required this.coin, required this.wallet, required this.network});
  factory _Crypto.fromJson(Map<String, dynamic> json) => _$CryptoFromJson(json);

/// コイン
@override final  String coin;
/// ウォレット
@override final  String wallet;
/// ネットワーク
@override final  String network;

/// Create a copy of Crypto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CryptoCopyWith<_Crypto> get copyWith => __$CryptoCopyWithImpl<_Crypto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CryptoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Crypto&&(identical(other.coin, coin) || other.coin == coin)&&(identical(other.wallet, wallet) || other.wallet == wallet)&&(identical(other.network, network) || other.network == network));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,coin,wallet,network);

@override
String toString() {
  return 'Crypto(coin: $coin, wallet: $wallet, network: $network)';
}


}

/// @nodoc
abstract mixin class _$CryptoCopyWith<$Res> implements $CryptoCopyWith<$Res> {
  factory _$CryptoCopyWith(_Crypto value, $Res Function(_Crypto) _then) = __$CryptoCopyWithImpl;
@override @useResult
$Res call({
 String coin, String wallet, String network
});




}
/// @nodoc
class __$CryptoCopyWithImpl<$Res>
    implements _$CryptoCopyWith<$Res> {
  __$CryptoCopyWithImpl(this._self, this._then);

  final _Crypto _self;
  final $Res Function(_Crypto) _then;

/// Create a copy of Crypto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coin = null,Object? wallet = null,Object? network = null,}) {
  return _then(_Crypto(
coin: null == coin ? _self.coin : coin // ignore: cast_nullable_to_non_nullable
as String,wallet: null == wallet ? _self.wallet : wallet // ignore: cast_nullable_to_non_nullable
as String,network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
