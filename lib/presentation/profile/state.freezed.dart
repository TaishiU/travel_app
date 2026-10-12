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
mixin _$ProfileScreenState {

/// ユーザー
 User get user;
/// Create a copy of ProfileScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileScreenStateCopyWith<ProfileScreenState> get copyWith => _$ProfileScreenStateCopyWithImpl<ProfileScreenState>(this as ProfileScreenState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileScreenState&&(identical(other.user, user) || other.user == user));
}


@override
int get hashCode => Object.hash(runtimeType,user);

@override
String toString() {
  return 'ProfileScreenState(user: $user)';
}


}

/// @nodoc
abstract mixin class $ProfileScreenStateCopyWith<$Res>  {
  factory $ProfileScreenStateCopyWith(ProfileScreenState value, $Res Function(ProfileScreenState) _then) = _$ProfileScreenStateCopyWithImpl;
@useResult
$Res call({
 User user
});


$UserCopyWith<$Res> get user;

}
/// @nodoc
class _$ProfileScreenStateCopyWithImpl<$Res>
    implements $ProfileScreenStateCopyWith<$Res> {
  _$ProfileScreenStateCopyWithImpl(this._self, this._then);

  final ProfileScreenState _self;
  final $Res Function(ProfileScreenState) _then;

/// Create a copy of ProfileScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,}) {
  return _then(_self.copyWith(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,
  ));
}
/// Create a copy of ProfileScreenState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProfileScreenState].
extension ProfileScreenStatePatterns on ProfileScreenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileScreenState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileScreenState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileScreenState value)  $default,){
final _that = this;
switch (_that) {
case _ProfileScreenState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileScreenState value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileScreenState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( User user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileScreenState() when $default != null:
return $default(_that.user);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( User user)  $default,) {final _that = this;
switch (_that) {
case _ProfileScreenState():
return $default(_that.user);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( User user)?  $default,) {final _that = this;
switch (_that) {
case _ProfileScreenState() when $default != null:
return $default(_that.user);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileScreenState implements ProfileScreenState {
  const _ProfileScreenState({required this.user});
  

/// ユーザー
@override final  User user;

/// Create a copy of ProfileScreenState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileScreenStateCopyWith<_ProfileScreenState> get copyWith => __$ProfileScreenStateCopyWithImpl<_ProfileScreenState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileScreenState&&(identical(other.user, user) || other.user == user));
}


@override
int get hashCode => Object.hash(runtimeType,user);

@override
String toString() {
  return 'ProfileScreenState(user: $user)';
}


}

/// @nodoc
abstract mixin class _$ProfileScreenStateCopyWith<$Res> implements $ProfileScreenStateCopyWith<$Res> {
  factory _$ProfileScreenStateCopyWith(_ProfileScreenState value, $Res Function(_ProfileScreenState) _then) = __$ProfileScreenStateCopyWithImpl;
@override @useResult
$Res call({
 User user
});


@override $UserCopyWith<$Res> get user;

}
/// @nodoc
class __$ProfileScreenStateCopyWithImpl<$Res>
    implements _$ProfileScreenStateCopyWith<$Res> {
  __$ProfileScreenStateCopyWithImpl(this._self, this._then);

  final _ProfileScreenState _self;
  final $Res Function(_ProfileScreenState) _then;

/// Create a copy of ProfileScreenState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,}) {
  return _then(_ProfileScreenState(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,
  ));
}

/// Create a copy of ProfileScreenState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
