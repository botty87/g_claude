// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dictation_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DictationState {

 DictationMode get mode;
/// Create a copy of DictationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DictationStateCopyWith<DictationState> get copyWith => _$DictationStateCopyWithImpl<DictationState>(this as DictationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DictationState&&(identical(other.mode, mode) || other.mode == mode));
}


@override
int get hashCode => Object.hash(runtimeType,mode);

@override
String toString() {
  return 'DictationState(mode: $mode)';
}


}

/// @nodoc
abstract mixin class $DictationStateCopyWith<$Res>  {
  factory $DictationStateCopyWith(DictationState value, $Res Function(DictationState) _then) = _$DictationStateCopyWithImpl;
@useResult
$Res call({
 DictationMode mode
});




}
/// @nodoc
class _$DictationStateCopyWithImpl<$Res>
    implements $DictationStateCopyWith<$Res> {
  _$DictationStateCopyWithImpl(this._self, this._then);

  final DictationState _self;
  final $Res Function(DictationState) _then;

/// Create a copy of DictationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as DictationMode,
  ));
}

}


/// Adds pattern-matching-related methods to [DictationState].
extension DictationStatePatterns on DictationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DictationStateInitial value)?  initial,TResult Function( DictationStateListening value)?  listening,TResult Function( DictationStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DictationStateInitial() when initial != null:
return initial(_that);case DictationStateListening() when listening != null:
return listening(_that);case DictationStateError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DictationStateInitial value)  initial,required TResult Function( DictationStateListening value)  listening,required TResult Function( DictationStateError value)  error,}){
final _that = this;
switch (_that) {
case DictationStateInitial():
return initial(_that);case DictationStateListening():
return listening(_that);case DictationStateError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DictationStateInitial value)?  initial,TResult? Function( DictationStateListening value)?  listening,TResult? Function( DictationStateError value)?  error,}){
final _that = this;
switch (_that) {
case DictationStateInitial() when initial != null:
return initial(_that);case DictationStateListening() when listening != null:
return listening(_that);case DictationStateError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( DictationMode mode)?  initial,TResult Function( String workspaceId,  String baseText,  int baseOffset,  String currentPartial,  DictationMode mode)?  listening,TResult Function( Failure failure,  DictationMode mode)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DictationStateInitial() when initial != null:
return initial(_that.mode);case DictationStateListening() when listening != null:
return listening(_that.workspaceId,_that.baseText,_that.baseOffset,_that.currentPartial,_that.mode);case DictationStateError() when error != null:
return error(_that.failure,_that.mode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( DictationMode mode)  initial,required TResult Function( String workspaceId,  String baseText,  int baseOffset,  String currentPartial,  DictationMode mode)  listening,required TResult Function( Failure failure,  DictationMode mode)  error,}) {final _that = this;
switch (_that) {
case DictationStateInitial():
return initial(_that.mode);case DictationStateListening():
return listening(_that.workspaceId,_that.baseText,_that.baseOffset,_that.currentPartial,_that.mode);case DictationStateError():
return error(_that.failure,_that.mode);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( DictationMode mode)?  initial,TResult? Function( String workspaceId,  String baseText,  int baseOffset,  String currentPartial,  DictationMode mode)?  listening,TResult? Function( Failure failure,  DictationMode mode)?  error,}) {final _that = this;
switch (_that) {
case DictationStateInitial() when initial != null:
return initial(_that.mode);case DictationStateListening() when listening != null:
return listening(_that.workspaceId,_that.baseText,_that.baseOffset,_that.currentPartial,_that.mode);case DictationStateError() when error != null:
return error(_that.failure,_that.mode);case _:
  return null;

}
}

}

/// @nodoc


class DictationStateInitial implements DictationState {
  const DictationStateInitial({required this.mode});
  

@override final  DictationMode mode;

/// Create a copy of DictationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DictationStateInitialCopyWith<DictationStateInitial> get copyWith => _$DictationStateInitialCopyWithImpl<DictationStateInitial>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DictationStateInitial&&(identical(other.mode, mode) || other.mode == mode));
}


@override
int get hashCode => Object.hash(runtimeType,mode);

@override
String toString() {
  return 'DictationState.initial(mode: $mode)';
}


}

/// @nodoc
abstract mixin class $DictationStateInitialCopyWith<$Res> implements $DictationStateCopyWith<$Res> {
  factory $DictationStateInitialCopyWith(DictationStateInitial value, $Res Function(DictationStateInitial) _then) = _$DictationStateInitialCopyWithImpl;
@override @useResult
$Res call({
 DictationMode mode
});




}
/// @nodoc
class _$DictationStateInitialCopyWithImpl<$Res>
    implements $DictationStateInitialCopyWith<$Res> {
  _$DictationStateInitialCopyWithImpl(this._self, this._then);

  final DictationStateInitial _self;
  final $Res Function(DictationStateInitial) _then;

/// Create a copy of DictationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,}) {
  return _then(DictationStateInitial(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as DictationMode,
  ));
}


}

/// @nodoc


class DictationStateListening implements DictationState {
  const DictationStateListening({required this.workspaceId, required this.baseText, required this.baseOffset, required this.currentPartial, required this.mode});
  

 final  String workspaceId;
 final  String baseText;
 final  int baseOffset;
 final  String currentPartial;
@override final  DictationMode mode;

/// Create a copy of DictationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DictationStateListeningCopyWith<DictationStateListening> get copyWith => _$DictationStateListeningCopyWithImpl<DictationStateListening>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DictationStateListening&&(identical(other.workspaceId, workspaceId) || other.workspaceId == workspaceId)&&(identical(other.baseText, baseText) || other.baseText == baseText)&&(identical(other.baseOffset, baseOffset) || other.baseOffset == baseOffset)&&(identical(other.currentPartial, currentPartial) || other.currentPartial == currentPartial)&&(identical(other.mode, mode) || other.mode == mode));
}


@override
int get hashCode => Object.hash(runtimeType,workspaceId,baseText,baseOffset,currentPartial,mode);

@override
String toString() {
  return 'DictationState.listening(workspaceId: $workspaceId, baseText: $baseText, baseOffset: $baseOffset, currentPartial: $currentPartial, mode: $mode)';
}


}

/// @nodoc
abstract mixin class $DictationStateListeningCopyWith<$Res> implements $DictationStateCopyWith<$Res> {
  factory $DictationStateListeningCopyWith(DictationStateListening value, $Res Function(DictationStateListening) _then) = _$DictationStateListeningCopyWithImpl;
@override @useResult
$Res call({
 String workspaceId, String baseText, int baseOffset, String currentPartial, DictationMode mode
});




}
/// @nodoc
class _$DictationStateListeningCopyWithImpl<$Res>
    implements $DictationStateListeningCopyWith<$Res> {
  _$DictationStateListeningCopyWithImpl(this._self, this._then);

  final DictationStateListening _self;
  final $Res Function(DictationStateListening) _then;

/// Create a copy of DictationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? workspaceId = null,Object? baseText = null,Object? baseOffset = null,Object? currentPartial = null,Object? mode = null,}) {
  return _then(DictationStateListening(
workspaceId: null == workspaceId ? _self.workspaceId : workspaceId // ignore: cast_nullable_to_non_nullable
as String,baseText: null == baseText ? _self.baseText : baseText // ignore: cast_nullable_to_non_nullable
as String,baseOffset: null == baseOffset ? _self.baseOffset : baseOffset // ignore: cast_nullable_to_non_nullable
as int,currentPartial: null == currentPartial ? _self.currentPartial : currentPartial // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as DictationMode,
  ));
}


}

/// @nodoc


class DictationStateError implements DictationState {
  const DictationStateError({required this.failure, required this.mode});
  

 final  Failure failure;
@override final  DictationMode mode;

/// Create a copy of DictationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DictationStateErrorCopyWith<DictationStateError> get copyWith => _$DictationStateErrorCopyWithImpl<DictationStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DictationStateError&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.mode, mode) || other.mode == mode));
}


@override
int get hashCode => Object.hash(runtimeType,failure,mode);

@override
String toString() {
  return 'DictationState.error(failure: $failure, mode: $mode)';
}


}

/// @nodoc
abstract mixin class $DictationStateErrorCopyWith<$Res> implements $DictationStateCopyWith<$Res> {
  factory $DictationStateErrorCopyWith(DictationStateError value, $Res Function(DictationStateError) _then) = _$DictationStateErrorCopyWithImpl;
@override @useResult
$Res call({
 Failure failure, DictationMode mode
});




}
/// @nodoc
class _$DictationStateErrorCopyWithImpl<$Res>
    implements $DictationStateErrorCopyWith<$Res> {
  _$DictationStateErrorCopyWithImpl(this._self, this._then);

  final DictationStateError _self;
  final $Res Function(DictationStateError) _then;

/// Create a copy of DictationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? failure = null,Object? mode = null,}) {
  return _then(DictationStateError(
failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as DictationMode,
  ));
}


}

// dart format on
