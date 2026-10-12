import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// ユーザー情報を表すエンティティ
@freezed
abstract class User with _$User {
  /// コンストラクタ
  const factory User({
    /// ID
    required int id,

    /// 名
    required String firstName,

    /// 姓
    required String lastName,

    /// 旧姓
    required String maidenName,

    /// 年齢
    required int age,

    /// 性別
    required String gender,

    /// メールアドレス
    required String email,

    /// 電話番号
    required String phone,

    /// ユーザー名
    required String username,

    /// パスワード
    required String password,

    /// 生年月日
    required String birthDate,

    /// 画像
    required String image,

    /// 血液型
    required String bloodGroup,

    /// 身長
    required double height,

    /// 体重
    required double weight,

    /// 目の色
    required String eyeColor,

    /// 髪
    required Hair hair,

    /// IPアドレス
    required String ip,

    /// 住所
    required Address address,

    /// MACアドレス
    required String macAddress,

    /// 大学
    required String university,

    /// 銀行
    required Bank bank,

    /// 会社
    required Company company,

    /// EIN
    required String ein,

    /// SSN
    required String ssn,

    /// ユーザーエージェント
    required String userAgent,

    /// 暗号資産
    required Crypto crypto,

    /// 役割
    required String role,
  }) = _User;

  /// JSONから生成
  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);
}

/// 髪の情報を表すエンティティ
@freezed
abstract class Hair with _$Hair {
  /// コンストラクタ
  const factory Hair({
    /// 色
    required String color,

    /// タイプ
    required String type,
  }) = _Hair;

  /// JSONから生成
  factory Hair.fromJson(Map<String, Object?> json) => _$HairFromJson(json);
}

/// 住所情報を表すエンティティ
@freezed
abstract class Address with _$Address {
  /// コンストラクタ
  const factory Address({
    /// 住所
    required String address,

    /// 市区町村
    required String city,

    /// 州
    required String state,

    /// 州コード
    required String stateCode,

    /// 郵便番号
    required String postalCode,

    /// 座標
    required Coordinates coordinates,

    /// 国
    required String country,
  }) = _Address;

  /// JSONから生成
  factory Address.fromJson(Map<String, Object?> json) =>
      _$AddressFromJson(json);
}

/// 座標情報を表すエンティティ
@freezed
abstract class Coordinates with _$Coordinates {
  /// コンストラクタ
  const factory Coordinates({
    /// 緯度
    required double lat,

    /// 経度
    required double lng,
  }) = _Coordinates;

  /// JSONから生成
  factory Coordinates.fromJson(Map<String, Object?> json) =>
      _$CoordinatesFromJson(json);
}

/// 銀行情報を表すエンティティ
@freezed
abstract class Bank with _$Bank {
  /// コンストラクタ
  const factory Bank({
    /// カード有効期限
    required String cardExpire,

    /// カード番号
    required String cardNumber,

    /// カードタイプ
    required String cardType,

    /// 通貨
    required String currency,

    /// IBAN
    required String iban,
  }) = _Bank;

  /// JSONから生成
  factory Bank.fromJson(Map<String, Object?> json) => _$BankFromJson(json);
}

/// 会社情報を表すエンティティ
@freezed
abstract class Company with _$Company {
  /// コンストラクタ
  const factory Company({
    /// 部署
    required String department,

    /// 会社名
    required String name,

    /// 役職
    required String title,

    /// 住所
    required Address address,
  }) = _Company;

  /// JSONから生成
  factory Company.fromJson(Map<String, Object?> json) =>
      _$CompanyFromJson(json);
}

/// 暗号資産情報を表すエンティティ
@freezed
abstract class Crypto with _$Crypto {
  /// コンストラクタ
  const factory Crypto({
    /// コイン
    required String coin,

    /// ウォレット
    required String wallet,

    /// ネットワーク
    required String network,
  }) = _Crypto;

  /// JSONから生成
  factory Crypto.fromJson(Map<String, Object?> json) => _$CryptoFromJson(json);
}
