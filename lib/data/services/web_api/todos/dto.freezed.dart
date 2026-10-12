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
mixin _$TodosDto {

 List<TodoDto>? get todos;
/// Create a copy of TodosDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodosDtoCopyWith<TodosDto> get copyWith => _$TodosDtoCopyWithImpl<TodosDto>(this as TodosDto, _$identity);

  /// Serializes this TodosDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodosDto&&const DeepCollectionEquality().equals(other.todos, todos));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(todos));

@override
String toString() {
  return 'TodosDto(todos: $todos)';
}


}

/// @nodoc
abstract mixin class $TodosDtoCopyWith<$Res>  {
  factory $TodosDtoCopyWith(TodosDto value, $Res Function(TodosDto) _then) = _$TodosDtoCopyWithImpl;
@useResult
$Res call({
 List<TodoDto>? todos
});




}
/// @nodoc
class _$TodosDtoCopyWithImpl<$Res>
    implements $TodosDtoCopyWith<$Res> {
  _$TodosDtoCopyWithImpl(this._self, this._then);

  final TodosDto _self;
  final $Res Function(TodosDto) _then;

/// Create a copy of TodosDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? todos = freezed,}) {
  return _then(_self.copyWith(
todos: freezed == todos ? _self.todos : todos // ignore: cast_nullable_to_non_nullable
as List<TodoDto>?,
  ));
}

}


/// Adds pattern-matching-related methods to [TodosDto].
extension TodosDtoPatterns on TodosDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodosDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodosDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodosDto value)  $default,){
final _that = this;
switch (_that) {
case _TodosDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodosDto value)?  $default,){
final _that = this;
switch (_that) {
case _TodosDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TodoDto>? todos)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodosDto() when $default != null:
return $default(_that.todos);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TodoDto>? todos)  $default,) {final _that = this;
switch (_that) {
case _TodosDto():
return $default(_that.todos);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TodoDto>? todos)?  $default,) {final _that = this;
switch (_that) {
case _TodosDto() when $default != null:
return $default(_that.todos);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TodosDto implements TodosDto {
  const _TodosDto({final  List<TodoDto>? todos}): _todos = todos;
  factory _TodosDto.fromJson(Map<String, dynamic> json) => _$TodosDtoFromJson(json);

 final  List<TodoDto>? _todos;
@override List<TodoDto>? get todos {
  final value = _todos;
  if (value == null) return null;
  if (_todos is EqualUnmodifiableListView) return _todos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of TodosDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodosDtoCopyWith<_TodosDto> get copyWith => __$TodosDtoCopyWithImpl<_TodosDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TodosDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodosDto&&const DeepCollectionEquality().equals(other._todos, _todos));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_todos));

@override
String toString() {
  return 'TodosDto(todos: $todos)';
}


}

/// @nodoc
abstract mixin class _$TodosDtoCopyWith<$Res> implements $TodosDtoCopyWith<$Res> {
  factory _$TodosDtoCopyWith(_TodosDto value, $Res Function(_TodosDto) _then) = __$TodosDtoCopyWithImpl;
@override @useResult
$Res call({
 List<TodoDto>? todos
});




}
/// @nodoc
class __$TodosDtoCopyWithImpl<$Res>
    implements _$TodosDtoCopyWith<$Res> {
  __$TodosDtoCopyWithImpl(this._self, this._then);

  final _TodosDto _self;
  final $Res Function(_TodosDto) _then;

/// Create a copy of TodosDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? todos = freezed,}) {
  return _then(_TodosDto(
todos: freezed == todos ? _self._todos : todos // ignore: cast_nullable_to_non_nullable
as List<TodoDto>?,
  ));
}


}


/// @nodoc
mixin _$TodoDto {

/// ID
 int? get id;/// ユーザーID
 int? get userId;/// タイトル
@JsonKey(name: 'todo') String? get todo;/// 完了したかどうか
 bool? get completed;
/// Create a copy of TodoDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodoDtoCopyWith<TodoDto> get copyWith => _$TodoDtoCopyWithImpl<TodoDto>(this as TodoDto, _$identity);

  /// Serializes this TodoDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodoDto&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.todo, todo) || other.todo == todo)&&(identical(other.completed, completed) || other.completed == completed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,todo,completed);

@override
String toString() {
  return 'TodoDto(id: $id, userId: $userId, todo: $todo, completed: $completed)';
}


}

/// @nodoc
abstract mixin class $TodoDtoCopyWith<$Res>  {
  factory $TodoDtoCopyWith(TodoDto value, $Res Function(TodoDto) _then) = _$TodoDtoCopyWithImpl;
@useResult
$Res call({
 int? id, int? userId,@JsonKey(name: 'todo') String? todo, bool? completed
});




}
/// @nodoc
class _$TodoDtoCopyWithImpl<$Res>
    implements $TodoDtoCopyWith<$Res> {
  _$TodoDtoCopyWithImpl(this._self, this._then);

  final TodoDto _self;
  final $Res Function(TodoDto) _then;

/// Create a copy of TodoDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? userId = freezed,Object? todo = freezed,Object? completed = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,todo: freezed == todo ? _self.todo : todo // ignore: cast_nullable_to_non_nullable
as String?,completed: freezed == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [TodoDto].
extension TodoDtoPatterns on TodoDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodoDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodoDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodoDto value)  $default,){
final _that = this;
switch (_that) {
case _TodoDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodoDto value)?  $default,){
final _that = this;
switch (_that) {
case _TodoDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int? userId, @JsonKey(name: 'todo')  String? todo,  bool? completed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodoDto() when $default != null:
return $default(_that.id,_that.userId,_that.todo,_that.completed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int? userId, @JsonKey(name: 'todo')  String? todo,  bool? completed)  $default,) {final _that = this;
switch (_that) {
case _TodoDto():
return $default(_that.id,_that.userId,_that.todo,_that.completed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int? userId, @JsonKey(name: 'todo')  String? todo,  bool? completed)?  $default,) {final _that = this;
switch (_that) {
case _TodoDto() when $default != null:
return $default(_that.id,_that.userId,_that.todo,_that.completed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TodoDto implements TodoDto {
  const _TodoDto({this.id, this.userId, @JsonKey(name: 'todo') this.todo, this.completed});
  factory _TodoDto.fromJson(Map<String, dynamic> json) => _$TodoDtoFromJson(json);

/// ID
@override final  int? id;
/// ユーザーID
@override final  int? userId;
/// タイトル
@override@JsonKey(name: 'todo') final  String? todo;
/// 完了したかどうか
@override final  bool? completed;

/// Create a copy of TodoDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodoDtoCopyWith<_TodoDto> get copyWith => __$TodoDtoCopyWithImpl<_TodoDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TodoDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodoDto&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.todo, todo) || other.todo == todo)&&(identical(other.completed, completed) || other.completed == completed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,todo,completed);

@override
String toString() {
  return 'TodoDto(id: $id, userId: $userId, todo: $todo, completed: $completed)';
}


}

/// @nodoc
abstract mixin class _$TodoDtoCopyWith<$Res> implements $TodoDtoCopyWith<$Res> {
  factory _$TodoDtoCopyWith(_TodoDto value, $Res Function(_TodoDto) _then) = __$TodoDtoCopyWithImpl;
@override @useResult
$Res call({
 int? id, int? userId,@JsonKey(name: 'todo') String? todo, bool? completed
});




}
/// @nodoc
class __$TodoDtoCopyWithImpl<$Res>
    implements _$TodoDtoCopyWith<$Res> {
  __$TodoDtoCopyWithImpl(this._self, this._then);

  final _TodoDto _self;
  final $Res Function(_TodoDto) _then;

/// Create a copy of TodoDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? userId = freezed,Object? todo = freezed,Object? completed = freezed,}) {
  return _then(_TodoDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,todo: freezed == todo ? _self.todo : todo // ignore: cast_nullable_to_non_nullable
as String?,completed: freezed == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
