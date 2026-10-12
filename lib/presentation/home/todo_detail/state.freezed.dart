// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TodoDetailScreenState {

/// 表示対象のTodo
 Todo? get todo;
/// Create a copy of TodoDetailScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodoDetailScreenStateCopyWith<TodoDetailScreenState> get copyWith => _$TodoDetailScreenStateCopyWithImpl<TodoDetailScreenState>(this as TodoDetailScreenState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodoDetailScreenState&&(identical(other.todo, todo) || other.todo == todo));
}


@override
int get hashCode => Object.hash(runtimeType,todo);

@override
String toString() {
  return 'TodoDetailScreenState(todo: $todo)';
}


}

/// @nodoc
abstract mixin class $TodoDetailScreenStateCopyWith<$Res>  {
  factory $TodoDetailScreenStateCopyWith(TodoDetailScreenState value, $Res Function(TodoDetailScreenState) _then) = _$TodoDetailScreenStateCopyWithImpl;
@useResult
$Res call({
 Todo? todo
});


$TodoCopyWith<$Res>? get todo;

}
/// @nodoc
class _$TodoDetailScreenStateCopyWithImpl<$Res>
    implements $TodoDetailScreenStateCopyWith<$Res> {
  _$TodoDetailScreenStateCopyWithImpl(this._self, this._then);

  final TodoDetailScreenState _self;
  final $Res Function(TodoDetailScreenState) _then;

/// Create a copy of TodoDetailScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? todo = freezed,}) {
  return _then(_self.copyWith(
todo: freezed == todo ? _self.todo : todo // ignore: cast_nullable_to_non_nullable
as Todo?,
  ));
}
/// Create a copy of TodoDetailScreenState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodoCopyWith<$Res>? get todo {
    if (_self.todo == null) {
    return null;
  }

  return $TodoCopyWith<$Res>(_self.todo!, (value) {
    return _then(_self.copyWith(todo: value));
  });
}
}


/// Adds pattern-matching-related methods to [TodoDetailScreenState].
extension TodoDetailScreenStatePatterns on TodoDetailScreenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodoDetailScreenState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodoDetailScreenState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodoDetailScreenState value)  $default,){
final _that = this;
switch (_that) {
case _TodoDetailScreenState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodoDetailScreenState value)?  $default,){
final _that = this;
switch (_that) {
case _TodoDetailScreenState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Todo? todo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodoDetailScreenState() when $default != null:
return $default(_that.todo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Todo? todo)  $default,) {final _that = this;
switch (_that) {
case _TodoDetailScreenState():
return $default(_that.todo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Todo? todo)?  $default,) {final _that = this;
switch (_that) {
case _TodoDetailScreenState() when $default != null:
return $default(_that.todo);case _:
  return null;

}
}

}

/// @nodoc


class _TodoDetailScreenState implements TodoDetailScreenState {
  const _TodoDetailScreenState({this.todo});
  

/// 表示対象のTodo
@override final  Todo? todo;

/// Create a copy of TodoDetailScreenState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodoDetailScreenStateCopyWith<_TodoDetailScreenState> get copyWith => __$TodoDetailScreenStateCopyWithImpl<_TodoDetailScreenState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodoDetailScreenState&&(identical(other.todo, todo) || other.todo == todo));
}


@override
int get hashCode => Object.hash(runtimeType,todo);

@override
String toString() {
  return 'TodoDetailScreenState(todo: $todo)';
}


}

/// @nodoc
abstract mixin class _$TodoDetailScreenStateCopyWith<$Res> implements $TodoDetailScreenStateCopyWith<$Res> {
  factory _$TodoDetailScreenStateCopyWith(_TodoDetailScreenState value, $Res Function(_TodoDetailScreenState) _then) = __$TodoDetailScreenStateCopyWithImpl;
@override @useResult
$Res call({
 Todo? todo
});


@override $TodoCopyWith<$Res>? get todo;

}
/// @nodoc
class __$TodoDetailScreenStateCopyWithImpl<$Res>
    implements _$TodoDetailScreenStateCopyWith<$Res> {
  __$TodoDetailScreenStateCopyWithImpl(this._self, this._then);

  final _TodoDetailScreenState _self;
  final $Res Function(_TodoDetailScreenState) _then;

/// Create a copy of TodoDetailScreenState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? todo = freezed,}) {
  return _then(_TodoDetailScreenState(
todo: freezed == todo ? _self.todo : todo // ignore: cast_nullable_to_non_nullable
as Todo?,
  ));
}

/// Create a copy of TodoDetailScreenState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodoCopyWith<$Res>? get todo {
    if (_self.todo == null) {
    return null;
  }

  return $TodoCopyWith<$Res>(_self.todo!, (value) {
    return _then(_self.copyWith(todo: value));
  });
}
}

// dart format on
