import 'package:freezed_annotation/freezed_annotation.dart';

part 'dto.freezed.dart';
part 'dto.g.dart';

/// ProductsDto（商品一覧レスポンス）
@freezed
abstract class ProductsDto with _$ProductsDto {
  /// コンストラクタ
  const factory ProductsDto({
    /// 商品サマリーリスト
    List<ProductSummaryDto>? data,

    /// 総件数（OFFSETページング時のみ、カーソルページング時はnull）
    int? total,

    /// 次ページカーソル（最終ページの場合はnull）
    @JsonKey(name: 'next_cursor') String? nextCursor,
  }) = _ProductsDto;

  /// JSONから生成
  factory ProductsDto.fromJson(Map<String, dynamic> json) =>
      _$ProductsDtoFromJson(json);
}

/// ProductSummaryDto（商品一覧用スキーマ）
@freezed
abstract class ProductSummaryDto with _$ProductSummaryDto {
  /// コンストラクタ
  const factory ProductSummaryDto({
    /// 商品ID
    int? id,

    /// 出品者ID
    @JsonKey(name: 'seller_id') int? sellerId,

    /// カテゴリID
    @JsonKey(name: 'category_id') int? categoryId,

    /// 商品名
    String? name,

    /// 価格
    int? price,

    /// 在庫数
    int? stock,

    /// ステータス（draft / published / archived）
    String? status,

    /// 作成日時
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _ProductSummaryDto;

  /// JSONから生成
  factory ProductSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$ProductSummaryDtoFromJson(json);
}

/// ProductDetailDto（商品詳細スキーマ）
@freezed
abstract class ProductDetailDto with _$ProductDetailDto {
  /// コンストラクタ
  const factory ProductDetailDto({
    /// 商品ID
    int? id,

    /// 出品者ID
    @JsonKey(name: 'seller_id') int? sellerId,

    /// カテゴリID
    @JsonKey(name: 'category_id') int? categoryId,

    /// 商品名
    String? name,

    /// 商品説明
    String? description,

    /// 価格
    int? price,

    /// 在庫数
    int? stock,

    /// ステータス（draft / published / archived）
    String? status,

    /// 商品画像リスト
    List<ProductImageDto>? images,

    /// 作成日時
    @JsonKey(name: 'created_at') String? createdAt,

    /// 更新日時
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ProductDetailDto;

  /// JSONから生成
  factory ProductDetailDto.fromJson(Map<String, dynamic> json) =>
      _$ProductDetailDtoFromJson(json);
}

/// ProductImageDto（商品画像スキーマ）
@freezed
abstract class ProductImageDto with _$ProductImageDto {
  /// コンストラクタ
  const factory ProductImageDto({
    /// 画像ID
    int? id,

    /// 画像URL
    String? url,

    /// 表示順
    @JsonKey(name: 'display_order') int? displayOrder,
  }) = _ProductImageDto;

  /// JSONから生成
  factory ProductImageDto.fromJson(Map<String, dynamic> json) =>
      _$ProductImageDtoFromJson(json);
}
