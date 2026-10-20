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
mixin _$LoginScreenState {

 bool get isLoading;
/// Create a copy of LoginScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginScreenStateCopyWith<LoginScreenState> get copyWith => _$LoginScreenStateCopyWithImpl<LoginScreenState>(this as LoginScreenState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LoginScreenState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginScreenState&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading));
}


@override
int get hashCode {
  final _this = this as LoginScreenState;
  return Object.hash(runtimeType,_this.isLoading);
}

@override
String toString() {
  final _this = this as LoginScreenState;
  return 'LoginScreenState(isLoading: ${_this.isLoading})';
}


}

/// @nodoc
abstract mixin class $LoginScreenStateCopyWith<$Res>  {
  factory $LoginScreenStateCopyWith(LoginScreenState value, $Res Function(LoginScreenState) _then) = _$LoginScreenStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading
});




}
/// @nodoc
class _$LoginScreenStateCopyWithImpl<$Res>
    implements $LoginScreenStateCopyWith<$Res> {
  _$LoginScreenStateCopyWithImpl(this._self, this._then);

  final LoginScreenState _self;
  final $Res Function(LoginScreenState) _then;

/// Create a copy of LoginScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,}) {
  return _then(LoginScreenState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginScreenState].
extension LoginScreenStatePatterns on LoginScreenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginScreenState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginScreenState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginScreenState value)  $default,){
final _that = this;
switch (_that) {
case _LoginScreenState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginScreenState value)?  $default,){
final _that = this;
switch (_that) {
case _LoginScreenState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginScreenState() when $default != null:
return $default(_that.isLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading)  $default,) {final _that = this;
switch (_that) {
case _LoginScreenState():
return $default(_that.isLoading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case _LoginScreenState() when $default != null:
return $default(_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc


class _LoginScreenState implements LoginScreenState {
  const _LoginScreenState({this.isLoading = false});
  

@override@JsonKey() final  bool isLoading;

/// Create a copy of LoginScreenState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginScreenStateCopyWith<_LoginScreenState> get copyWith => __$LoginScreenStateCopyWithImpl<_LoginScreenState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginScreenState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isLoading);
}

@override
String toString() {
    return 'LoginScreenState(isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$LoginScreenStateCopyWith<$Res> implements $LoginScreenStateCopyWith<$Res> {
  factory _$LoginScreenStateCopyWith(_LoginScreenState value, $Res Function(_LoginScreenState) _then) = __$LoginScreenStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading
});




}
/// @nodoc
class __$LoginScreenStateCopyWithImpl<$Res>
    implements _$LoginScreenStateCopyWith<$Res> {
  __$LoginScreenStateCopyWithImpl(this._self, this._then);

  final _LoginScreenState _self;
  final $Res Function(_LoginScreenState) _then;

/// Create a copy of LoginScreenState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,}) {
  return _then(_LoginScreenState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
