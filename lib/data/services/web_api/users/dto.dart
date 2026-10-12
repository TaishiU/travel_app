import 'package:freezed_annotation/freezed_annotation.dart';

part 'dto.freezed.dart';
part 'dto.g.dart';

/// UserDto
@freezed
abstract class UserDto with _$UserDto {
  /// コンストラクタ
  const factory UserDto({
    /// ID
    int? id,

    /// 名
    String? firstName,

    /// 姓
    String? lastName,

    /// 旧姓
    String? maidenName,

    /// 年齢
    int? age,

    /// 性別
    String? gender,

    /// メールアドレス
    String? email,

    /// 電話番号
    String? phone,

    /// ユーザー名
    String? username,

    /// パスワード
    String? password,

    /// 生年月日
    String? birthDate,

    /// 画像
    String? image,

    /// 血液型
    String? bloodGroup,

    /// 身長
    double? height,

    /// 体重
    double? weight,

    /// 目の色
    String? eyeColor,

    /// 髪
    Hair? hair,

    /// IPアドレス
    String? ip,

    /// 住所
    Address? address,

    /// MACアドレス
    String? macAddress,

    /// 大学
    String? university,

    /// 銀行
    Bank? bank,

    /// 会社
    Company? company,

    /// EIN
    String? ein,

    /// SSN
    String? ssn,

    /// ユーザーエージェント
    String? userAgent,

    /// 暗号資産
    Crypto? crypto,

    /// 役割
    String? role,
  }) = _UserDto;

  /// JSONから生成
  factory UserDto.fromJson(Map<String, Object?> json) =>
      _$UserDtoFromJson(json);
}

/// Hair
@freezed
abstract class Hair with _$Hair {
  /// コンストラクタ
  const factory Hair({
    /// 色
    String? color,

    /// タイプ
    String? type,
  }) = _Hair;

  /// JSONから生成
  factory Hair.fromJson(Map<String, Object?> json) => _$HairFromJson(json);
}

/// Address
@freezed
abstract class Address with _$Address {
  /// コンストラクタ
  const factory Address({
    /// 住所
    String? address,

    /// 市区町村
    String? city,

    /// 州
    String? state,

    /// 州コード
    String? stateCode,

    /// 郵便番号
    String? postalCode,

    /// 座標
    Coordinates? coordinates,

    /// 国
    String? country,
  }) = _Address;

  /// JSONから生成
  factory Address.fromJson(Map<String, Object?> json) =>
      _$AddressFromJson(json);
}

/// Coordinates
@freezed
abstract class Coordinates with _$Coordinates {
  /// コンストラクタ
  const factory Coordinates({
    /// 緯度
    double? lat,

    /// 経度
    double? lng,
  }) = _Coordinates;

  /// JSONから生成
  factory Coordinates.fromJson(Map<String, Object?> json) =>
      _$CoordinatesFromJson(json);
}

/// Bank
@freezed
abstract class Bank with _$Bank {
  /// コンストラクタ
  const factory Bank({
    /// カード有効期限
    String? cardExpire,

    /// カード番号
    String? cardNumber,

    /// カードタイプ
    String? cardType,

    /// 通貨
    String? currency,

    /// IBAN
    String? iban,
  }) = _Bank;

  /// JSONから生成
  factory Bank.fromJson(Map<String, Object?> json) => _$BankFromJson(json);
}

/// Company
@freezed
abstract class Company with _$Company {
  /// コンストラクタ
  const factory Company({
    /// 部署
    String? department,

    /// 会社名
    String? name,

    /// 役職
    String? title,

    /// 住所
    Address? address,
  }) = _Company;

  /// JSONから生成
  factory Company.fromJson(Map<String, Object?> json) =>
      _$CompanyFromJson(json);
}

/// Crypto
@freezed
abstract class Crypto with _$Crypto {
  /// コンストラクタ
  const factory Crypto({
    /// コイン
    String? coin,

    /// ウォレット
    String? wallet,

    /// ネットワーク
    String? network,
  }) = _Crypto;

  /// JSONから生成
  factory Crypto.fromJson(Map<String, Object?> json) => _$CryptoFromJson(json);
}
