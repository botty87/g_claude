// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dictation_partial.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DictationPartial {

 String get text; bool get isFinal;
/// Create a copy of DictationPartial
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DictationPartialCopyWith<DictationPartial> get copyWith => _$DictationPartialCopyWithImpl<DictationPartial>(this as DictationPartial, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DictationPartial&&(identical(other.text, text) || other.text == text)&&(identical(other.isFinal, isFinal) || other.isFinal == isFinal));
}


@override
int get hashCode => Object.hash(runtimeType,text,isFinal);

@override
String toString() {
  return 'DictationPartial(text: $text, isFinal: $isFinal)';
}


}

/// @nodoc
abstract mixin class $DictationPartialCopyWith<$Res>  {
  factory $DictationPartialCopyWith(DictationPartial value, $Res Function(DictationPartial) _then) = _$DictationPartialCopyWithImpl;
@useResult
$Res call({
 String text, bool isFinal
});




}
/// @nodoc
class _$DictationPartialCopyWithImpl<$Res>
    implements $DictationPartialCopyWith<$Res> {
  _$DictationPartialCopyWithImpl(this._self, this._then);

  final DictationPartial _self;
  final $Res Function(DictationPartial) _then;

/// Create a copy of DictationPartial
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? isFinal = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,isFinal: null == isFinal ? _self.isFinal : isFinal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DictationPartial].
extension DictationPartialPatterns on DictationPartial {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DictationPartial value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DictationPartial() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DictationPartial value)  $default,){
final _that = this;
switch (_that) {
case _DictationPartial():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DictationPartial value)?  $default,){
final _that = this;
switch (_that) {
case _DictationPartial() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  bool isFinal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DictationPartial() when $default != null:
return $default(_that.text,_that.isFinal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  bool isFinal)  $default,) {final _that = this;
switch (_that) {
case _DictationPartial():
return $default(_that.text,_that.isFinal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  bool isFinal)?  $default,) {final _that = this;
switch (_that) {
case _DictationPartial() when $default != null:
return $default(_that.text,_that.isFinal);case _:
  return null;

}
}

}

/// @nodoc


class _DictationPartial implements DictationPartial {
  const _DictationPartial({required this.text, required this.isFinal});
  

@override final  String text;
@override final  bool isFinal;

/// Create a copy of DictationPartial
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DictationPartialCopyWith<_DictationPartial> get copyWith => __$DictationPartialCopyWithImpl<_DictationPartial>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DictationPartial&&(identical(other.text, text) || other.text == text)&&(identical(other.isFinal, isFinal) || other.isFinal == isFinal));
}


@override
int get hashCode => Object.hash(runtimeType,text,isFinal);

@override
String toString() {
  return 'DictationPartial(text: $text, isFinal: $isFinal)';
}


}

/// @nodoc
abstract mixin class _$DictationPartialCopyWith<$Res> implements $DictationPartialCopyWith<$Res> {
  factory _$DictationPartialCopyWith(_DictationPartial value, $Res Function(_DictationPartial) _then) = __$DictationPartialCopyWithImpl;
@override @useResult
$Res call({
 String text, bool isFinal
});




}
/// @nodoc
class __$DictationPartialCopyWithImpl<$Res>
    implements _$DictationPartialCopyWith<$Res> {
  __$DictationPartialCopyWithImpl(this._self, this._then);

  final _DictationPartial _self;
  final $Res Function(_DictationPartial) _then;

/// Create a copy of DictationPartial
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? isFinal = null,}) {
  return _then(_DictationPartial(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,isFinal: null == isFinal ? _self.isFinal : isFinal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
