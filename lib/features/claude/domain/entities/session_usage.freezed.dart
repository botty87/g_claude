// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_usage.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SessionUsage {

 int get inputTokens; int get cacheReadTokens; int get cacheCreationTokens; int get outputTokens;
/// Create a copy of SessionUsage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionUsageCopyWith<SessionUsage> get copyWith => _$SessionUsageCopyWithImpl<SessionUsage>(this as SessionUsage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionUsage&&(identical(other.inputTokens, inputTokens) || other.inputTokens == inputTokens)&&(identical(other.cacheReadTokens, cacheReadTokens) || other.cacheReadTokens == cacheReadTokens)&&(identical(other.cacheCreationTokens, cacheCreationTokens) || other.cacheCreationTokens == cacheCreationTokens)&&(identical(other.outputTokens, outputTokens) || other.outputTokens == outputTokens));
}


@override
int get hashCode => Object.hash(runtimeType,inputTokens,cacheReadTokens,cacheCreationTokens,outputTokens);

@override
String toString() {
  return 'SessionUsage(inputTokens: $inputTokens, cacheReadTokens: $cacheReadTokens, cacheCreationTokens: $cacheCreationTokens, outputTokens: $outputTokens)';
}


}

/// @nodoc
abstract mixin class $SessionUsageCopyWith<$Res>  {
  factory $SessionUsageCopyWith(SessionUsage value, $Res Function(SessionUsage) _then) = _$SessionUsageCopyWithImpl;
@useResult
$Res call({
 int inputTokens, int cacheReadTokens, int cacheCreationTokens, int outputTokens
});




}
/// @nodoc
class _$SessionUsageCopyWithImpl<$Res>
    implements $SessionUsageCopyWith<$Res> {
  _$SessionUsageCopyWithImpl(this._self, this._then);

  final SessionUsage _self;
  final $Res Function(SessionUsage) _then;

/// Create a copy of SessionUsage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? inputTokens = null,Object? cacheReadTokens = null,Object? cacheCreationTokens = null,Object? outputTokens = null,}) {
  return _then(_self.copyWith(
inputTokens: null == inputTokens ? _self.inputTokens : inputTokens // ignore: cast_nullable_to_non_nullable
as int,cacheReadTokens: null == cacheReadTokens ? _self.cacheReadTokens : cacheReadTokens // ignore: cast_nullable_to_non_nullable
as int,cacheCreationTokens: null == cacheCreationTokens ? _self.cacheCreationTokens : cacheCreationTokens // ignore: cast_nullable_to_non_nullable
as int,outputTokens: null == outputTokens ? _self.outputTokens : outputTokens // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionUsage].
extension SessionUsagePatterns on SessionUsage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionUsage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionUsage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionUsage value)  $default,){
final _that = this;
switch (_that) {
case _SessionUsage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionUsage value)?  $default,){
final _that = this;
switch (_that) {
case _SessionUsage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int inputTokens,  int cacheReadTokens,  int cacheCreationTokens,  int outputTokens)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionUsage() when $default != null:
return $default(_that.inputTokens,_that.cacheReadTokens,_that.cacheCreationTokens,_that.outputTokens);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int inputTokens,  int cacheReadTokens,  int cacheCreationTokens,  int outputTokens)  $default,) {final _that = this;
switch (_that) {
case _SessionUsage():
return $default(_that.inputTokens,_that.cacheReadTokens,_that.cacheCreationTokens,_that.outputTokens);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int inputTokens,  int cacheReadTokens,  int cacheCreationTokens,  int outputTokens)?  $default,) {final _that = this;
switch (_that) {
case _SessionUsage() when $default != null:
return $default(_that.inputTokens,_that.cacheReadTokens,_that.cacheCreationTokens,_that.outputTokens);case _:
  return null;

}
}

}

/// @nodoc


class _SessionUsage extends SessionUsage {
  const _SessionUsage({this.inputTokens = 0, this.cacheReadTokens = 0, this.cacheCreationTokens = 0, this.outputTokens = 0}): super._();
  

@override@JsonKey() final  int inputTokens;
@override@JsonKey() final  int cacheReadTokens;
@override@JsonKey() final  int cacheCreationTokens;
@override@JsonKey() final  int outputTokens;

/// Create a copy of SessionUsage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionUsageCopyWith<_SessionUsage> get copyWith => __$SessionUsageCopyWithImpl<_SessionUsage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionUsage&&(identical(other.inputTokens, inputTokens) || other.inputTokens == inputTokens)&&(identical(other.cacheReadTokens, cacheReadTokens) || other.cacheReadTokens == cacheReadTokens)&&(identical(other.cacheCreationTokens, cacheCreationTokens) || other.cacheCreationTokens == cacheCreationTokens)&&(identical(other.outputTokens, outputTokens) || other.outputTokens == outputTokens));
}


@override
int get hashCode => Object.hash(runtimeType,inputTokens,cacheReadTokens,cacheCreationTokens,outputTokens);

@override
String toString() {
  return 'SessionUsage(inputTokens: $inputTokens, cacheReadTokens: $cacheReadTokens, cacheCreationTokens: $cacheCreationTokens, outputTokens: $outputTokens)';
}


}

/// @nodoc
abstract mixin class _$SessionUsageCopyWith<$Res> implements $SessionUsageCopyWith<$Res> {
  factory _$SessionUsageCopyWith(_SessionUsage value, $Res Function(_SessionUsage) _then) = __$SessionUsageCopyWithImpl;
@override @useResult
$Res call({
 int inputTokens, int cacheReadTokens, int cacheCreationTokens, int outputTokens
});




}
/// @nodoc
class __$SessionUsageCopyWithImpl<$Res>
    implements _$SessionUsageCopyWith<$Res> {
  __$SessionUsageCopyWithImpl(this._self, this._then);

  final _SessionUsage _self;
  final $Res Function(_SessionUsage) _then;

/// Create a copy of SessionUsage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? inputTokens = null,Object? cacheReadTokens = null,Object? cacheCreationTokens = null,Object? outputTokens = null,}) {
  return _then(_SessionUsage(
inputTokens: null == inputTokens ? _self.inputTokens : inputTokens // ignore: cast_nullable_to_non_nullable
as int,cacheReadTokens: null == cacheReadTokens ? _self.cacheReadTokens : cacheReadTokens // ignore: cast_nullable_to_non_nullable
as int,cacheCreationTokens: null == cacheCreationTokens ? _self.cacheCreationTokens : cacheCreationTokens // ignore: cast_nullable_to_non_nullable
as int,outputTokens: null == outputTokens ? _self.outputTokens : outputTokens // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
