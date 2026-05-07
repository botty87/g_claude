// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pty_session_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PtySessionEvent {

 String get workspaceId;
/// Create a copy of PtySessionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PtySessionEventCopyWith<PtySessionEvent> get copyWith => _$PtySessionEventCopyWithImpl<PtySessionEvent>(this as PtySessionEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PtySessionEvent&&(identical(other.workspaceId, workspaceId) || other.workspaceId == workspaceId));
}


@override
int get hashCode => Object.hash(runtimeType,workspaceId);

@override
String toString() {
  return 'PtySessionEvent(workspaceId: $workspaceId)';
}


}

/// @nodoc
abstract mixin class $PtySessionEventCopyWith<$Res>  {
  factory $PtySessionEventCopyWith(PtySessionEvent value, $Res Function(PtySessionEvent) _then) = _$PtySessionEventCopyWithImpl;
@useResult
$Res call({
 String workspaceId
});




}
/// @nodoc
class _$PtySessionEventCopyWithImpl<$Res>
    implements $PtySessionEventCopyWith<$Res> {
  _$PtySessionEventCopyWithImpl(this._self, this._then);

  final PtySessionEvent _self;
  final $Res Function(PtySessionEvent) _then;

/// Create a copy of PtySessionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? workspaceId = null,}) {
  return _then(_self.copyWith(
workspaceId: null == workspaceId ? _self.workspaceId : workspaceId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PtySessionEvent].
extension PtySessionEventPatterns on PtySessionEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PtySessionEventRunning value)?  running,TResult Function( PtySessionEventExited value)?  exited,TResult Function( PtySessionEventFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PtySessionEventRunning() when running != null:
return running(_that);case PtySessionEventExited() when exited != null:
return exited(_that);case PtySessionEventFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PtySessionEventRunning value)  running,required TResult Function( PtySessionEventExited value)  exited,required TResult Function( PtySessionEventFailed value)  failed,}){
final _that = this;
switch (_that) {
case PtySessionEventRunning():
return running(_that);case PtySessionEventExited():
return exited(_that);case PtySessionEventFailed():
return failed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PtySessionEventRunning value)?  running,TResult? Function( PtySessionEventExited value)?  exited,TResult? Function( PtySessionEventFailed value)?  failed,}){
final _that = this;
switch (_that) {
case PtySessionEventRunning() when running != null:
return running(_that);case PtySessionEventExited() when exited != null:
return exited(_that);case PtySessionEventFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String workspaceId)?  running,TResult Function( String workspaceId,  int exitCode)?  exited,TResult Function( String workspaceId,  String error)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PtySessionEventRunning() when running != null:
return running(_that.workspaceId);case PtySessionEventExited() when exited != null:
return exited(_that.workspaceId,_that.exitCode);case PtySessionEventFailed() when failed != null:
return failed(_that.workspaceId,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String workspaceId)  running,required TResult Function( String workspaceId,  int exitCode)  exited,required TResult Function( String workspaceId,  String error)  failed,}) {final _that = this;
switch (_that) {
case PtySessionEventRunning():
return running(_that.workspaceId);case PtySessionEventExited():
return exited(_that.workspaceId,_that.exitCode);case PtySessionEventFailed():
return failed(_that.workspaceId,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String workspaceId)?  running,TResult? Function( String workspaceId,  int exitCode)?  exited,TResult? Function( String workspaceId,  String error)?  failed,}) {final _that = this;
switch (_that) {
case PtySessionEventRunning() when running != null:
return running(_that.workspaceId);case PtySessionEventExited() when exited != null:
return exited(_that.workspaceId,_that.exitCode);case PtySessionEventFailed() when failed != null:
return failed(_that.workspaceId,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class PtySessionEventRunning implements PtySessionEvent {
  const PtySessionEventRunning({required this.workspaceId});
  

@override final  String workspaceId;

/// Create a copy of PtySessionEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PtySessionEventRunningCopyWith<PtySessionEventRunning> get copyWith => _$PtySessionEventRunningCopyWithImpl<PtySessionEventRunning>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PtySessionEventRunning&&(identical(other.workspaceId, workspaceId) || other.workspaceId == workspaceId));
}


@override
int get hashCode => Object.hash(runtimeType,workspaceId);

@override
String toString() {
  return 'PtySessionEvent.running(workspaceId: $workspaceId)';
}


}

/// @nodoc
abstract mixin class $PtySessionEventRunningCopyWith<$Res> implements $PtySessionEventCopyWith<$Res> {
  factory $PtySessionEventRunningCopyWith(PtySessionEventRunning value, $Res Function(PtySessionEventRunning) _then) = _$PtySessionEventRunningCopyWithImpl;
@override @useResult
$Res call({
 String workspaceId
});




}
/// @nodoc
class _$PtySessionEventRunningCopyWithImpl<$Res>
    implements $PtySessionEventRunningCopyWith<$Res> {
  _$PtySessionEventRunningCopyWithImpl(this._self, this._then);

  final PtySessionEventRunning _self;
  final $Res Function(PtySessionEventRunning) _then;

/// Create a copy of PtySessionEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? workspaceId = null,}) {
  return _then(PtySessionEventRunning(
workspaceId: null == workspaceId ? _self.workspaceId : workspaceId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PtySessionEventExited implements PtySessionEvent {
  const PtySessionEventExited({required this.workspaceId, required this.exitCode});
  

@override final  String workspaceId;
 final  int exitCode;

/// Create a copy of PtySessionEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PtySessionEventExitedCopyWith<PtySessionEventExited> get copyWith => _$PtySessionEventExitedCopyWithImpl<PtySessionEventExited>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PtySessionEventExited&&(identical(other.workspaceId, workspaceId) || other.workspaceId == workspaceId)&&(identical(other.exitCode, exitCode) || other.exitCode == exitCode));
}


@override
int get hashCode => Object.hash(runtimeType,workspaceId,exitCode);

@override
String toString() {
  return 'PtySessionEvent.exited(workspaceId: $workspaceId, exitCode: $exitCode)';
}


}

/// @nodoc
abstract mixin class $PtySessionEventExitedCopyWith<$Res> implements $PtySessionEventCopyWith<$Res> {
  factory $PtySessionEventExitedCopyWith(PtySessionEventExited value, $Res Function(PtySessionEventExited) _then) = _$PtySessionEventExitedCopyWithImpl;
@override @useResult
$Res call({
 String workspaceId, int exitCode
});




}
/// @nodoc
class _$PtySessionEventExitedCopyWithImpl<$Res>
    implements $PtySessionEventExitedCopyWith<$Res> {
  _$PtySessionEventExitedCopyWithImpl(this._self, this._then);

  final PtySessionEventExited _self;
  final $Res Function(PtySessionEventExited) _then;

/// Create a copy of PtySessionEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? workspaceId = null,Object? exitCode = null,}) {
  return _then(PtySessionEventExited(
workspaceId: null == workspaceId ? _self.workspaceId : workspaceId // ignore: cast_nullable_to_non_nullable
as String,exitCode: null == exitCode ? _self.exitCode : exitCode // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class PtySessionEventFailed implements PtySessionEvent {
  const PtySessionEventFailed({required this.workspaceId, required this.error});
  

@override final  String workspaceId;
 final  String error;

/// Create a copy of PtySessionEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PtySessionEventFailedCopyWith<PtySessionEventFailed> get copyWith => _$PtySessionEventFailedCopyWithImpl<PtySessionEventFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PtySessionEventFailed&&(identical(other.workspaceId, workspaceId) || other.workspaceId == workspaceId)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,workspaceId,error);

@override
String toString() {
  return 'PtySessionEvent.failed(workspaceId: $workspaceId, error: $error)';
}


}

/// @nodoc
abstract mixin class $PtySessionEventFailedCopyWith<$Res> implements $PtySessionEventCopyWith<$Res> {
  factory $PtySessionEventFailedCopyWith(PtySessionEventFailed value, $Res Function(PtySessionEventFailed) _then) = _$PtySessionEventFailedCopyWithImpl;
@override @useResult
$Res call({
 String workspaceId, String error
});




}
/// @nodoc
class _$PtySessionEventFailedCopyWithImpl<$Res>
    implements $PtySessionEventFailedCopyWith<$Res> {
  _$PtySessionEventFailedCopyWithImpl(this._self, this._then);

  final PtySessionEventFailed _self;
  final $Res Function(PtySessionEventFailed) _then;

/// Create a copy of PtySessionEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? workspaceId = null,Object? error = null,}) {
  return _then(PtySessionEventFailed(
workspaceId: null == workspaceId ? _self.workspaceId : workspaceId // ignore: cast_nullable_to_non_nullable
as String,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
