// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductsDto _$ProductsDtoFromJson(Map<String, dynamic> json) => _ProductsDto(
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => ProductSummaryDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num?)?.toInt(),
  nextCursor: json['next_cursor'] as String?,
);

Map<String, dynamic> _$ProductsDtoToJson(_ProductsDto instance) =>
    <String, dynamic>{
      'data': instance.data,
      'total': instance.total,
      'next_cursor': instance.nextCursor,
    };

_ProductSummaryDto _$ProductSummaryDtoFromJson(Map<String, dynamic> json) =>
    _ProductSummaryDto(
      id: (json['id'] as num?)?.toInt(),
      sellerId: (json['seller_id'] as num?)?.toInt(),
      categoryId: (json['category_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      price: (json['price'] as num?)?.toInt(),
      stock: (json['stock'] as num?)?.toInt(),
      status: json['status'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$ProductSummaryDtoToJson(_ProductSummaryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'seller_id': instance.sellerId,
      'category_id': instance.categoryId,
      'name': instance.name,
      'price': instance.price,
      'stock': instance.stock,
      'status': instance.status,
      'created_at': instance.createdAt,
    };

_ProductDetailDto _$ProductDetailDtoFromJson(Map<String, dynamic> json) =>
    _ProductDetailDto(
      id: (json['id'] as num?)?.toInt(),
      sellerId: (json['seller_id'] as num?)?.toInt(),
      categoryId: (json['category_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toInt(),
      stock: (json['stock'] as num?)?.toInt(),
      status: json['status'] as String?,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => ProductImageDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$ProductDetailDtoToJson(_ProductDetailDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'seller_id': instance.sellerId,
      'category_id': instance.categoryId,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'stock': instance.stock,
      'status': instance.status,
      'images': instance.images,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_ProductImageDto _$ProductImageDtoFromJson(Map<String, dynamic> json) =>
    _ProductImageDto(
      id: (json['id'] as num?)?.toInt(),
      url: json['url'] as String?,
      displayOrder: (json['display_order'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProductImageDtoToJson(_ProductImageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'display_order': instance.displayOrder,
    };
