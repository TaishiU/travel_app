// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskScreenState {

/// タスク一覧
 List<Task> get tasks;/// ログイン済みかどうか
 bool get isLoggedIn;
/// Create a copy of TaskScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskScreenStateCopyWith<TaskScreenState> get copyWith => _$TaskScreenStateCopyWithImpl<TaskScreenState>(this as TaskScreenState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TaskScreenState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskScreenState&&const DeepCollectionEquality().equals(other.tasks, _this.tasks)&&(identical(other.isLoggedIn, _this.isLoggedIn) || other.isLoggedIn == _this.isLoggedIn));
}


@override
int get hashCode {
  final _this = this as TaskScreenState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.tasks),_this.isLoggedIn);
}

@override
String toString() {
  final _this = this as TaskScreenState;
  return 'TaskScreenState(tasks: ${_this.tasks}, isLoggedIn: ${_this.isLoggedIn})';
}


}

/// @nodoc
abstract mixin class $TaskScreenStateCopyWith<$Res>  {
  factory $TaskScreenStateCopyWith(TaskScreenState value, $Res Function(TaskScreenState) _then) = _$TaskScreenStateCopyWithImpl;
@useResult
$Res call({
 List<Task> tasks, bool isLoggedIn
});




}
/// @nodoc
class _$TaskScreenStateCopyWithImpl<$Res>
    implements $TaskScreenStateCopyWith<$Res> {
  _$TaskScreenStateCopyWithImpl(this._self, this._then);

  final TaskScreenState _self;
  final $Res Function(TaskScreenState) _then;

/// Create a copy of TaskScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tasks = null,Object? isLoggedIn = null,}) {
  return _then(TaskScreenState(
tasks: null == tasks ? _self.tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<Task>,isLoggedIn: null == isLoggedIn ? _self.isLoggedIn : isLoggedIn // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskScreenState].
extension TaskScreenStatePatterns on TaskScreenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskScreenState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskScreenState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskScreenState value)  $default,){
final _that = this;
switch (_that) {
case _TaskScreenState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskScreenState value)?  $default,){
final _that = this;
switch (_that) {
case _TaskScreenState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Task> tasks,  bool isLoggedIn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskScreenState() when $default != null:
return $default(_that.tasks,_that.isLoggedIn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Task> tasks,  bool isLoggedIn)  $default,) {final _that = this;
switch (_that) {
case _TaskScreenState():
return $default(_that.tasks,_that.isLoggedIn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Task> tasks,  bool isLoggedIn)?  $default,) {final _that = this;
switch (_that) {
case _TaskScreenState() when $default != null:
return $default(_that.tasks,_that.isLoggedIn);case _:
  return null;

}
}

}

/// @nodoc


class _TaskScreenState implements TaskScreenState {
  const _TaskScreenState({required  List<Task> tasks, this.isLoggedIn = false}): _tasks = tasks;
  

/// タスク一覧
 final  List<Task> _tasks;
/// タスク一覧
@override List<Task> get tasks {
  if (_tasks is EqualUnmodifiableListView) return _tasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tasks);
}

/// ログイン済みかどうか
@override@JsonKey() final  bool isLoggedIn;

/// Create a copy of TaskScreenState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskScreenStateCopyWith<_TaskScreenState> get copyWith => __$TaskScreenStateCopyWithImpl<_TaskScreenState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskScreenState&&const DeepCollectionEquality().equals(other.tasks, _tasks)&&(identical(other.isLoggedIn, isLoggedIn) || other.isLoggedIn == isLoggedIn));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_tasks),isLoggedIn);
}

@override
String toString() {
    return 'TaskScreenState(tasks: $tasks, isLoggedIn: $isLoggedIn)';
}


}

/// @nodoc
abstract mixin class _$TaskScreenStateCopyWith<$Res> implements $TaskScreenStateCopyWith<$Res> {
  factory _$TaskScreenStateCopyWith(_TaskScreenState value, $Res Function(_TaskScreenState) _then) = __$TaskScreenStateCopyWithImpl;
@override @useResult
$Res call({
 List<Task> tasks, bool isLoggedIn
});




}
/// @nodoc
class __$TaskScreenStateCopyWithImpl<$Res>
    implements _$TaskScreenStateCopyWith<$Res> {
  __$TaskScreenStateCopyWithImpl(this._self, this._then);

  final _TaskScreenState _self;
  final $Res Function(_TaskScreenState) _then;

/// Create a copy of TaskScreenState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tasks = null,Object? isLoggedIn = null,}) {
  return _then(_TaskScreenState(
tasks: null == tasks ? _self._tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<Task>,isLoggedIn: null == isLoggedIn ? _self.isLoggedIn : isLoggedIn // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
