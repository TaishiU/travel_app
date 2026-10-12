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
mixin _$TodoListScreenState {

/// SSOTから提供されるTodoリスト
 List<Todo> get todos;/// 検索クエリ
 String get searchQuery;
/// Create a copy of TodoListScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodoListScreenStateCopyWith<TodoListScreenState> get copyWith => _$TodoListScreenStateCopyWithImpl<TodoListScreenState>(this as TodoListScreenState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodoListScreenState&&const DeepCollectionEquality().equals(other.todos, todos)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(todos),searchQuery);

@override
String toString() {
  return 'TodoListScreenState(todos: $todos, searchQuery: $searchQuery)';
}


}

/// @nodoc
abstract mixin class $TodoListScreenStateCopyWith<$Res>  {
  factory $TodoListScreenStateCopyWith(TodoListScreenState value, $Res Function(TodoListScreenState) _then) = _$TodoListScreenStateCopyWithImpl;
@useResult
$Res call({
 List<Todo> todos, String searchQuery
});




}
/// @nodoc
class _$TodoListScreenStateCopyWithImpl<$Res>
    implements $TodoListScreenStateCopyWith<$Res> {
  _$TodoListScreenStateCopyWithImpl(this._self, this._then);

  final TodoListScreenState _self;
  final $Res Function(TodoListScreenState) _then;

/// Create a copy of TodoListScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? todos = null,Object? searchQuery = null,}) {
  return _then(_self.copyWith(
todos: null == todos ? _self.todos : todos // ignore: cast_nullable_to_non_nullable
as List<Todo>,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TodoListScreenState].
extension TodoListScreenStatePatterns on TodoListScreenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodoListScreenState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodoListScreenState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodoListScreenState value)  $default,){
final _that = this;
switch (_that) {
case _TodoListScreenState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodoListScreenState value)?  $default,){
final _that = this;
switch (_that) {
case _TodoListScreenState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Todo> todos,  String searchQuery)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodoListScreenState() when $default != null:
return $default(_that.todos,_that.searchQuery);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Todo> todos,  String searchQuery)  $default,) {final _that = this;
switch (_that) {
case _TodoListScreenState():
return $default(_that.todos,_that.searchQuery);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Todo> todos,  String searchQuery)?  $default,) {final _that = this;
switch (_that) {
case _TodoListScreenState() when $default != null:
return $default(_that.todos,_that.searchQuery);case _:
  return null;

}
}

}

/// @nodoc


class _TodoListScreenState implements TodoListScreenState {
  const _TodoListScreenState({required final  List<Todo> todos, required this.searchQuery}): _todos = todos;
  

/// SSOTから提供されるTodoリスト
 final  List<Todo> _todos;
/// SSOTから提供されるTodoリスト
@override List<Todo> get todos {
  if (_todos is EqualUnmodifiableListView) return _todos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_todos);
}

/// 検索クエリ
@override final  String searchQuery;

/// Create a copy of TodoListScreenState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodoListScreenStateCopyWith<_TodoListScreenState> get copyWith => __$TodoListScreenStateCopyWithImpl<_TodoListScreenState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodoListScreenState&&const DeepCollectionEquality().equals(other._todos, _todos)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_todos),searchQuery);

@override
String toString() {
  return 'TodoListScreenState(todos: $todos, searchQuery: $searchQuery)';
}


}

/// @nodoc
abstract mixin class _$TodoListScreenStateCopyWith<$Res> implements $TodoListScreenStateCopyWith<$Res> {
  factory _$TodoListScreenStateCopyWith(_TodoListScreenState value, $Res Function(_TodoListScreenState) _then) = __$TodoListScreenStateCopyWithImpl;
@override @useResult
$Res call({
 List<Todo> todos, String searchQuery
});




}
/// @nodoc
class __$TodoListScreenStateCopyWithImpl<$Res>
    implements _$TodoListScreenStateCopyWith<$Res> {
  __$TodoListScreenStateCopyWithImpl(this._self, this._then);

  final _TodoListScreenState _self;
  final $Res Function(_TodoListScreenState) _then;

/// Create a copy of TodoListScreenState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? todos = null,Object? searchQuery = null,}) {
  return _then(_TodoListScreenState(
todos: null == todos ? _self._todos : todos // ignore: cast_nullable_to_non_nullable
as List<Todo>,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
