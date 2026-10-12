// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductsDto {

/// 商品サマリーリスト
 List<ProductSummaryDto>? get data;/// 総件数（OFFSETページング時のみ、カーソルページング時はnull）
 int? get total;/// 次ページカーソル（最終ページの場合はnull）
@JsonKey(name: 'next_cursor') String? get nextCursor;
/// Create a copy of ProductsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductsDtoCopyWith<ProductsDto> get copyWith => _$ProductsDtoCopyWithImpl<ProductsDto>(this as ProductsDto, _$identity);

  /// Serializes this ProductsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductsDto&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.total, total) || other.total == total)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data),total,nextCursor);

@override
String toString() {
  return 'ProductsDto(data: $data, total: $total, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class $ProductsDtoCopyWith<$Res>  {
  factory $ProductsDtoCopyWith(ProductsDto value, $Res Function(ProductsDto) _then) = _$ProductsDtoCopyWithImpl;
@useResult
$Res call({
 List<ProductSummaryDto>? data, int? total,@JsonKey(name: 'next_cursor') String? nextCursor
});




}
/// @nodoc
class _$ProductsDtoCopyWithImpl<$Res>
    implements $ProductsDtoCopyWith<$Res> {
  _$ProductsDtoCopyWithImpl(this._self, this._then);

  final ProductsDto _self;
  final $Res Function(ProductsDto) _then;

/// Create a copy of ProductsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = freezed,Object? total = freezed,Object? nextCursor = freezed,}) {
  return _then(_self.copyWith(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as List<ProductSummaryDto>?,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductsDto].
extension ProductsDtoPatterns on ProductsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductsDto value)  $default,){
final _that = this;
switch (_that) {
case _ProductsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductsDto value)?  $default,){
final _that = this;
switch (_that) {
case _ProductsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ProductSummaryDto>? data,  int? total, @JsonKey(name: 'next_cursor')  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductsDto() when $default != null:
return $default(_that.data,_that.total,_that.nextCursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ProductSummaryDto>? data,  int? total, @JsonKey(name: 'next_cursor')  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _ProductsDto():
return $default(_that.data,_that.total,_that.nextCursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ProductSummaryDto>? data,  int? total, @JsonKey(name: 'next_cursor')  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _ProductsDto() when $default != null:
return $default(_that.data,_that.total,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductsDto implements ProductsDto {
  const _ProductsDto({final  List<ProductSummaryDto>? data, this.total, @JsonKey(name: 'next_cursor') this.nextCursor}): _data = data;
  factory _ProductsDto.fromJson(Map<String, dynamic> json) => _$ProductsDtoFromJson(json);

/// 商品サマリーリスト
 final  List<ProductSummaryDto>? _data;
/// 商品サマリーリスト
@override List<ProductSummaryDto>? get data {
  final value = _data;
  if (value == null) return null;
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// 総件数（OFFSETページング時のみ、カーソルページング時はnull）
@override final  int? total;
/// 次ページカーソル（最終ページの場合はnull）
@override@JsonKey(name: 'next_cursor') final  String? nextCursor;

/// Create a copy of ProductsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductsDtoCopyWith<_ProductsDto> get copyWith => __$ProductsDtoCopyWithImpl<_ProductsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductsDto&&const DeepCollectionEquality().equals(other._data, _data)&&(identical(other.total, total) || other.total == total)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data),total,nextCursor);

@override
String toString() {
  return 'ProductsDto(data: $data, total: $total, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$ProductsDtoCopyWith<$Res> implements $ProductsDtoCopyWith<$Res> {
  factory _$ProductsDtoCopyWith(_ProductsDto value, $Res Function(_ProductsDto) _then) = __$ProductsDtoCopyWithImpl;
@override @useResult
$Res call({
 List<ProductSummaryDto>? data, int? total,@JsonKey(name: 'next_cursor') String? nextCursor
});




}
/// @nodoc
class __$ProductsDtoCopyWithImpl<$Res>
    implements _$ProductsDtoCopyWith<$Res> {
  __$ProductsDtoCopyWithImpl(this._self, this._then);

  final _ProductsDto _self;
  final $Res Function(_ProductsDto) _then;

/// Create a copy of ProductsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = freezed,Object? total = freezed,Object? nextCursor = freezed,}) {
  return _then(_ProductsDto(
data: freezed == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<ProductSummaryDto>?,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ProductSummaryDto {

/// 商品ID
 int? get id;/// 出品者ID
@JsonKey(name: 'seller_id') int? get sellerId;/// カテゴリID
@JsonKey(name: 'category_id') int? get categoryId;/// 商品名
 String? get name;/// 価格
 int? get price;/// 在庫数
 int? get stock;/// ステータス（draft / published / archived）
 String? get status;/// 作成日時
@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of ProductSummaryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductSummaryDtoCopyWith<ProductSummaryDto> get copyWith => _$ProductSummaryDtoCopyWithImpl<ProductSummaryDto>(this as ProductSummaryDto, _$identity);

  /// Serializes this ProductSummaryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductSummaryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.stock, stock) || other.stock == stock)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sellerId,categoryId,name,price,stock,status,createdAt);

@override
String toString() {
  return 'ProductSummaryDto(id: $id, sellerId: $sellerId, categoryId: $categoryId, name: $name, price: $price, stock: $stock, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ProductSummaryDtoCopyWith<$Res>  {
  factory $ProductSummaryDtoCopyWith(ProductSummaryDto value, $Res Function(ProductSummaryDto) _then) = _$ProductSummaryDtoCopyWithImpl;
@useResult
$Res call({
 int? id,@JsonKey(name: 'seller_id') int? sellerId,@JsonKey(name: 'category_id') int? categoryId, String? name, int? price, int? stock, String? status,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$ProductSummaryDtoCopyWithImpl<$Res>
    implements $ProductSummaryDtoCopyWith<$Res> {
  _$ProductSummaryDtoCopyWithImpl(this._self, this._then);

  final ProductSummaryDto _self;
  final $Res Function(ProductSummaryDto) _then;

/// Create a copy of ProductSummaryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? sellerId = freezed,Object? categoryId = freezed,Object? name = freezed,Object? price = freezed,Object? stock = freezed,Object? status = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,sellerId: freezed == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as int?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int?,stock: freezed == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductSummaryDto].
extension ProductSummaryDtoPatterns on ProductSummaryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductSummaryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductSummaryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductSummaryDto value)  $default,){
final _that = this;
switch (_that) {
case _ProductSummaryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductSummaryDto value)?  $default,){
final _that = this;
switch (_that) {
case _ProductSummaryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id, @JsonKey(name: 'seller_id')  int? sellerId, @JsonKey(name: 'category_id')  int? categoryId,  String? name,  int? price,  int? stock,  String? status, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductSummaryDto() when $default != null:
return $default(_that.id,_that.sellerId,_that.categoryId,_that.name,_that.price,_that.stock,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id, @JsonKey(name: 'seller_id')  int? sellerId, @JsonKey(name: 'category_id')  int? categoryId,  String? name,  int? price,  int? stock,  String? status, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ProductSummaryDto():
return $default(_that.id,_that.sellerId,_that.categoryId,_that.name,_that.price,_that.stock,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id, @JsonKey(name: 'seller_id')  int? sellerId, @JsonKey(name: 'category_id')  int? categoryId,  String? name,  int? price,  int? stock,  String? status, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ProductSummaryDto() when $default != null:
return $default(_that.id,_that.sellerId,_that.categoryId,_that.name,_that.price,_that.stock,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductSummaryDto implements ProductSummaryDto {
  const _ProductSummaryDto({this.id, @JsonKey(name: 'seller_id') this.sellerId, @JsonKey(name: 'category_id') this.categoryId, this.name, this.price, this.stock, this.status, @JsonKey(name: 'created_at') this.createdAt});
  factory _ProductSummaryDto.fromJson(Map<String, dynamic> json) => _$ProductSummaryDtoFromJson(json);

/// 商品ID
@override final  int? id;
/// 出品者ID
@override@JsonKey(name: 'seller_id') final  int? sellerId;
/// カテゴリID
@override@JsonKey(name: 'category_id') final  int? categoryId;
/// 商品名
@override final  String? name;
/// 価格
@override final  int? price;
/// 在庫数
@override final  int? stock;
/// ステータス（draft / published / archived）
@override final  String? status;
/// 作成日時
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of ProductSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductSummaryDtoCopyWith<_ProductSummaryDto> get copyWith => __$ProductSummaryDtoCopyWithImpl<_ProductSummaryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductSummaryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductSummaryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.stock, stock) || other.stock == stock)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sellerId,categoryId,name,price,stock,status,createdAt);

@override
String toString() {
  return 'ProductSummaryDto(id: $id, sellerId: $sellerId, categoryId: $categoryId, name: $name, price: $price, stock: $stock, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ProductSummaryDtoCopyWith<$Res> implements $ProductSummaryDtoCopyWith<$Res> {
  factory _$ProductSummaryDtoCopyWith(_ProductSummaryDto value, $Res Function(_ProductSummaryDto) _then) = __$ProductSummaryDtoCopyWithImpl;
@override @useResult
$Res call({
 int? id,@JsonKey(name: 'seller_id') int? sellerId,@JsonKey(name: 'category_id') int? categoryId, String? name, int? price, int? stock, String? status,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$ProductSummaryDtoCopyWithImpl<$Res>
    implements _$ProductSummaryDtoCopyWith<$Res> {
  __$ProductSummaryDtoCopyWithImpl(this._self, this._then);

  final _ProductSummaryDto _self;
  final $Res Function(_ProductSummaryDto) _then;

/// Create a copy of ProductSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? sellerId = freezed,Object? categoryId = freezed,Object? name = freezed,Object? price = freezed,Object? stock = freezed,Object? status = freezed,Object? createdAt = freezed,}) {
  return _then(_ProductSummaryDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,sellerId: freezed == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as int?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int?,stock: freezed == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ProductDetailDto {

/// 商品ID
 int? get id;/// 出品者ID
@JsonKey(name: 'seller_id') int? get sellerId;/// カテゴリID
@JsonKey(name: 'category_id') int? get categoryId;/// 商品名
 String? get name;/// 商品説明
 String? get description;/// 価格
 int? get price;/// 在庫数
 int? get stock;/// ステータス（draft / published / archived）
 String? get status;/// 商品画像リスト
 List<ProductImageDto>? get images;/// 作成日時
@JsonKey(name: 'created_at') String? get createdAt;/// 更新日時
@JsonKey(name: 'updated_at') String? get updatedAt;
/// Create a copy of ProductDetailDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductDetailDtoCopyWith<ProductDetailDto> get copyWith => _$ProductDetailDtoCopyWithImpl<ProductDetailDto>(this as ProductDetailDto, _$identity);

  /// Serializes this ProductDetailDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductDetailDto&&(identical(other.id, id) || other.id == id)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.stock, stock) || other.stock == stock)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sellerId,categoryId,name,description,price,stock,status,const DeepCollectionEquality().hash(images),createdAt,updatedAt);

@override
String toString() {
  return 'ProductDetailDto(id: $id, sellerId: $sellerId, categoryId: $categoryId, name: $name, description: $description, price: $price, stock: $stock, status: $status, images: $images, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ProductDetailDtoCopyWith<$Res>  {
  factory $ProductDetailDtoCopyWith(ProductDetailDto value, $Res Function(ProductDetailDto) _then) = _$ProductDetailDtoCopyWithImpl;
@useResult
$Res call({
 int? id,@JsonKey(name: 'seller_id') int? sellerId,@JsonKey(name: 'category_id') int? categoryId, String? name, String? description, int? price, int? stock, String? status, List<ProductImageDto>? images,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class _$ProductDetailDtoCopyWithImpl<$Res>
    implements $ProductDetailDtoCopyWith<$Res> {
  _$ProductDetailDtoCopyWithImpl(this._self, this._then);

  final ProductDetailDto _self;
  final $Res Function(ProductDetailDto) _then;

/// Create a copy of ProductDetailDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? sellerId = freezed,Object? categoryId = freezed,Object? name = freezed,Object? description = freezed,Object? price = freezed,Object? stock = freezed,Object? status = freezed,Object? images = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,sellerId: freezed == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as int?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int?,stock: freezed == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,images: freezed == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<ProductImageDto>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductDetailDto].
extension ProductDetailDtoPatterns on ProductDetailDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductDetailDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductDetailDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductDetailDto value)  $default,){
final _that = this;
switch (_that) {
case _ProductDetailDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductDetailDto value)?  $default,){
final _that = this;
switch (_that) {
case _ProductDetailDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id, @JsonKey(name: 'seller_id')  int? sellerId, @JsonKey(name: 'category_id')  int? categoryId,  String? name,  String? description,  int? price,  int? stock,  String? status,  List<ProductImageDto>? images, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductDetailDto() when $default != null:
return $default(_that.id,_that.sellerId,_that.categoryId,_that.name,_that.description,_that.price,_that.stock,_that.status,_that.images,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id, @JsonKey(name: 'seller_id')  int? sellerId, @JsonKey(name: 'category_id')  int? categoryId,  String? name,  String? description,  int? price,  int? stock,  String? status,  List<ProductImageDto>? images, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ProductDetailDto():
return $default(_that.id,_that.sellerId,_that.categoryId,_that.name,_that.description,_that.price,_that.stock,_that.status,_that.images,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id, @JsonKey(name: 'seller_id')  int? sellerId, @JsonKey(name: 'category_id')  int? categoryId,  String? name,  String? description,  int? price,  int? stock,  String? status,  List<ProductImageDto>? images, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProductDetailDto() when $default != null:
return $default(_that.id,_that.sellerId,_that.categoryId,_that.name,_that.description,_that.price,_that.stock,_that.status,_that.images,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductDetailDto implements ProductDetailDto {
  const _ProductDetailDto({this.id, @JsonKey(name: 'seller_id') this.sellerId, @JsonKey(name: 'category_id') this.categoryId, this.name, this.description, this.price, this.stock, this.status, final  List<ProductImageDto>? images, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt}): _images = images;
  factory _ProductDetailDto.fromJson(Map<String, dynamic> json) => _$ProductDetailDtoFromJson(json);

/// 商品ID
@override final  int? id;
/// 出品者ID
@override@JsonKey(name: 'seller_id') final  int? sellerId;
/// カテゴリID
@override@JsonKey(name: 'category_id') final  int? categoryId;
/// 商品名
@override final  String? name;
/// 商品説明
@override final  String? description;
/// 価格
@override final  int? price;
/// 在庫数
@override final  int? stock;
/// ステータス（draft / published / archived）
@override final  String? status;
/// 商品画像リスト
 final  List<ProductImageDto>? _images;
/// 商品画像リスト
@override List<ProductImageDto>? get images {
  final value = _images;
  if (value == null) return null;
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// 作成日時
@override@JsonKey(name: 'created_at') final  String? createdAt;
/// 更新日時
@override@JsonKey(name: 'updated_at') final  String? updatedAt;

/// Create a copy of ProductDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductDetailDtoCopyWith<_ProductDetailDto> get copyWith => __$ProductDetailDtoCopyWithImpl<_ProductDetailDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductDetailDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductDetailDto&&(identical(other.id, id) || other.id == id)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.stock, stock) || other.stock == stock)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sellerId,categoryId,name,description,price,stock,status,const DeepCollectionEquality().hash(_images),createdAt,updatedAt);

@override
String toString() {
  return 'ProductDetailDto(id: $id, sellerId: $sellerId, categoryId: $categoryId, name: $name, description: $description, price: $price, stock: $stock, status: $status, images: $images, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProductDetailDtoCopyWith<$Res> implements $ProductDetailDtoCopyWith<$Res> {
  factory _$ProductDetailDtoCopyWith(_ProductDetailDto value, $Res Function(_ProductDetailDto) _then) = __$ProductDetailDtoCopyWithImpl;
@override @useResult
$Res call({
 int? id,@JsonKey(name: 'seller_id') int? sellerId,@JsonKey(name: 'category_id') int? categoryId, String? name, String? description, int? price, int? stock, String? status, List<ProductImageDto>? images,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class __$ProductDetailDtoCopyWithImpl<$Res>
    implements _$ProductDetailDtoCopyWith<$Res> {
  __$ProductDetailDtoCopyWithImpl(this._self, this._then);

  final _ProductDetailDto _self;
  final $Res Function(_ProductDetailDto) _then;

/// Create a copy of ProductDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? sellerId = freezed,Object? categoryId = freezed,Object? name = freezed,Object? description = freezed,Object? price = freezed,Object? stock = freezed,Object? status = freezed,Object? images = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ProductDetailDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,sellerId: freezed == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as int?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int?,stock: freezed == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,images: freezed == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<ProductImageDto>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ProductImageDto {

/// 画像ID
 int? get id;/// 画像URL
 String? get url;/// 表示順
@JsonKey(name: 'display_order') int? get displayOrder;
/// Create a copy of ProductImageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductImageDtoCopyWith<ProductImageDto> get copyWith => _$ProductImageDtoCopyWithImpl<ProductImageDto>(this as ProductImageDto, _$identity);

  /// Serializes this ProductImageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductImageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,displayOrder);

@override
String toString() {
  return 'ProductImageDto(id: $id, url: $url, displayOrder: $displayOrder)';
}


}

/// @nodoc
abstract mixin class $ProductImageDtoCopyWith<$Res>  {
  factory $ProductImageDtoCopyWith(ProductImageDto value, $Res Function(ProductImageDto) _then) = _$ProductImageDtoCopyWithImpl;
@useResult
$Res call({
 int? id, String? url,@JsonKey(name: 'display_order') int? displayOrder
});




}
/// @nodoc
class _$ProductImageDtoCopyWithImpl<$Res>
    implements $ProductImageDtoCopyWith<$Res> {
  _$ProductImageDtoCopyWithImpl(this._self, this._then);

  final ProductImageDto _self;
  final $Res Function(ProductImageDto) _then;

/// Create a copy of ProductImageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? url = freezed,Object? displayOrder = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,displayOrder: freezed == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductImageDto].
extension ProductImageDtoPatterns on ProductImageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductImageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductImageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductImageDto value)  $default,){
final _that = this;
switch (_that) {
case _ProductImageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductImageDto value)?  $default,){
final _that = this;
switch (_that) {
case _ProductImageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String? url, @JsonKey(name: 'display_order')  int? displayOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductImageDto() when $default != null:
return $default(_that.id,_that.url,_that.displayOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String? url, @JsonKey(name: 'display_order')  int? displayOrder)  $default,) {final _that = this;
switch (_that) {
case _ProductImageDto():
return $default(_that.id,_that.url,_that.displayOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String? url, @JsonKey(name: 'display_order')  int? displayOrder)?  $default,) {final _that = this;
switch (_that) {
case _ProductImageDto() when $default != null:
return $default(_that.id,_that.url,_that.displayOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductImageDto implements ProductImageDto {
  const _ProductImageDto({this.id, this.url, @JsonKey(name: 'display_order') this.displayOrder});
  factory _ProductImageDto.fromJson(Map<String, dynamic> json) => _$ProductImageDtoFromJson(json);

/// 画像ID
@override final  int? id;
/// 画像URL
@override final  String? url;
/// 表示順
@override@JsonKey(name: 'display_order') final  int? displayOrder;

/// Create a copy of ProductImageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductImageDtoCopyWith<_ProductImageDto> get copyWith => __$ProductImageDtoCopyWithImpl<_ProductImageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductImageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductImageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,displayOrder);

@override
String toString() {
  return 'ProductImageDto(id: $id, url: $url, displayOrder: $displayOrder)';
}


}

/// @nodoc
abstract mixin class _$ProductImageDtoCopyWith<$Res> implements $ProductImageDtoCopyWith<$Res> {
  factory _$ProductImageDtoCopyWith(_ProductImageDto value, $Res Function(_ProductImageDto) _then) = __$ProductImageDtoCopyWithImpl;
@override @useResult
$Res call({
 int? id, String? url,@JsonKey(name: 'display_order') int? displayOrder
});




}
/// @nodoc
class __$ProductImageDtoCopyWithImpl<$Res>
    implements _$ProductImageDtoCopyWith<$Res> {
  __$ProductImageDtoCopyWithImpl(this._self, this._then);

  final _ProductImageDto _self;
  final $Res Function(_ProductImageDto) _then;

/// Create a copy of ProductImageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? url = freezed,Object? displayOrder = freezed,}) {
  return _then(_ProductImageDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,displayOrder: freezed == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
