// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'terminal_sessions_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TerminalSessionInfo {

 String get shellPath; String get cwd; TerminalRunStatus get status; int? get exitCode; String? get lastError;/// Bumped on each `restart()`. Widgets key off this so the TerminalView
/// rebinds its listeners against the new Terminal instance even if the
/// status stays at `running` across the restart (fast respawn).
 int get incarnation;
/// Create a copy of TerminalSessionInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TerminalSessionInfoCopyWith<TerminalSessionInfo> get copyWith => _$TerminalSessionInfoCopyWithImpl<TerminalSessionInfo>(this as TerminalSessionInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TerminalSessionInfo&&(identical(other.shellPath, shellPath) || other.shellPath == shellPath)&&(identical(other.cwd, cwd) || other.cwd == cwd)&&(identical(other.status, status) || other.status == status)&&(identical(other.exitCode, exitCode) || other.exitCode == exitCode)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&(identical(other.incarnation, incarnation) || other.incarnation == incarnation));
}


@override
int get hashCode => Object.hash(runtimeType,shellPath,cwd,status,exitCode,lastError,incarnation);

@override
String toString() {
  return 'TerminalSessionInfo(shellPath: $shellPath, cwd: $cwd, status: $status, exitCode: $exitCode, lastError: $lastError, incarnation: $incarnation)';
}


}

/// @nodoc
abstract mixin class $TerminalSessionInfoCopyWith<$Res>  {
  factory $TerminalSessionInfoCopyWith(TerminalSessionInfo value, $Res Function(TerminalSessionInfo) _then) = _$TerminalSessionInfoCopyWithImpl;
@useResult
$Res call({
 String shellPath, String cwd, TerminalRunStatus status, int? exitCode, String? lastError, int incarnation
});




}
/// @nodoc
class _$TerminalSessionInfoCopyWithImpl<$Res>
    implements $TerminalSessionInfoCopyWith<$Res> {
  _$TerminalSessionInfoCopyWithImpl(this._self, this._then);

  final TerminalSessionInfo _self;
  final $Res Function(TerminalSessionInfo) _then;

/// Create a copy of TerminalSessionInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? shellPath = null,Object? cwd = null,Object? status = null,Object? exitCode = freezed,Object? lastError = freezed,Object? incarnation = null,}) {
  return _then(_self.copyWith(
shellPath: null == shellPath ? _self.shellPath : shellPath // ignore: cast_nullable_to_non_nullable
as String,cwd: null == cwd ? _self.cwd : cwd // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TerminalRunStatus,exitCode: freezed == exitCode ? _self.exitCode : exitCode // ignore: cast_nullable_to_non_nullable
as int?,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,incarnation: null == incarnation ? _self.incarnation : incarnation // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TerminalSessionInfo].
extension TerminalSessionInfoPatterns on TerminalSessionInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TerminalSessionInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TerminalSessionInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TerminalSessionInfo value)  $default,){
final _that = this;
switch (_that) {
case _TerminalSessionInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TerminalSessionInfo value)?  $default,){
final _that = this;
switch (_that) {
case _TerminalSessionInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String shellPath,  String cwd,  TerminalRunStatus status,  int? exitCode,  String? lastError,  int incarnation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TerminalSessionInfo() when $default != null:
return $default(_that.shellPath,_that.cwd,_that.status,_that.exitCode,_that.lastError,_that.incarnation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String shellPath,  String cwd,  TerminalRunStatus status,  int? exitCode,  String? lastError,  int incarnation)  $default,) {final _that = this;
switch (_that) {
case _TerminalSessionInfo():
return $default(_that.shellPath,_that.cwd,_that.status,_that.exitCode,_that.lastError,_that.incarnation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String shellPath,  String cwd,  TerminalRunStatus status,  int? exitCode,  String? lastError,  int incarnation)?  $default,) {final _that = this;
switch (_that) {
case _TerminalSessionInfo() when $default != null:
return $default(_that.shellPath,_that.cwd,_that.status,_that.exitCode,_that.lastError,_that.incarnation);case _:
  return null;

}
}

}

/// @nodoc


class _TerminalSessionInfo implements TerminalSessionInfo {
  const _TerminalSessionInfo({required this.shellPath, required this.cwd, this.status = TerminalRunStatus.starting, this.exitCode, this.lastError, this.incarnation = 0});
  

@override final  String shellPath;
@override final  String cwd;
@override@JsonKey() final  TerminalRunStatus status;
@override final  int? exitCode;
@override final  String? lastError;
/// Bumped on each `restart()`. Widgets key off this so the TerminalView
/// rebinds its listeners against the new Terminal instance even if the
/// status stays at `running` across the restart (fast respawn).
@override@JsonKey() final  int incarnation;

/// Create a copy of TerminalSessionInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TerminalSessionInfoCopyWith<_TerminalSessionInfo> get copyWith => __$TerminalSessionInfoCopyWithImpl<_TerminalSessionInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TerminalSessionInfo&&(identical(other.shellPath, shellPath) || other.shellPath == shellPath)&&(identical(other.cwd, cwd) || other.cwd == cwd)&&(identical(other.status, status) || other.status == status)&&(identical(other.exitCode, exitCode) || other.exitCode == exitCode)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&(identical(other.incarnation, incarnation) || other.incarnation == incarnation));
}


@override
int get hashCode => Object.hash(runtimeType,shellPath,cwd,status,exitCode,lastError,incarnation);

@override
String toString() {
  return 'TerminalSessionInfo(shellPath: $shellPath, cwd: $cwd, status: $status, exitCode: $exitCode, lastError: $lastError, incarnation: $incarnation)';
}


}

/// @nodoc
abstract mixin class _$TerminalSessionInfoCopyWith<$Res> implements $TerminalSessionInfoCopyWith<$Res> {
  factory _$TerminalSessionInfoCopyWith(_TerminalSessionInfo value, $Res Function(_TerminalSessionInfo) _then) = __$TerminalSessionInfoCopyWithImpl;
@override @useResult
$Res call({
 String shellPath, String cwd, TerminalRunStatus status, int? exitCode, String? lastError, int incarnation
});




}
/// @nodoc
class __$TerminalSessionInfoCopyWithImpl<$Res>
    implements _$TerminalSessionInfoCopyWith<$Res> {
  __$TerminalSessionInfoCopyWithImpl(this._self, this._then);

  final _TerminalSessionInfo _self;
  final $Res Function(_TerminalSessionInfo) _then;

/// Create a copy of TerminalSessionInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? shellPath = null,Object? cwd = null,Object? status = null,Object? exitCode = freezed,Object? lastError = freezed,Object? incarnation = null,}) {
  return _then(_TerminalSessionInfo(
shellPath: null == shellPath ? _self.shellPath : shellPath // ignore: cast_nullable_to_non_nullable
as String,cwd: null == cwd ? _self.cwd : cwd // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TerminalRunStatus,exitCode: freezed == exitCode ? _self.exitCode : exitCode // ignore: cast_nullable_to_non_nullable
as int?,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,incarnation: null == incarnation ? _self.incarnation : incarnation // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$TerminalSessionsState {

 Map<String, TerminalSessionInfo> get sessions;
/// Create a copy of TerminalSessionsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TerminalSessionsStateCopyWith<TerminalSessionsState> get copyWith => _$TerminalSessionsStateCopyWithImpl<TerminalSessionsState>(this as TerminalSessionsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TerminalSessionsState&&const DeepCollectionEquality().equals(other.sessions, sessions));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(sessions));

@override
String toString() {
  return 'TerminalSessionsState(sessions: $sessions)';
}


}

/// @nodoc
abstract mixin class $TerminalSessionsStateCopyWith<$Res>  {
  factory $TerminalSessionsStateCopyWith(TerminalSessionsState value, $Res Function(TerminalSessionsState) _then) = _$TerminalSessionsStateCopyWithImpl;
@useResult
$Res call({
 Map<String, TerminalSessionInfo> sessions
});




}
/// @nodoc
class _$TerminalSessionsStateCopyWithImpl<$Res>
    implements $TerminalSessionsStateCopyWith<$Res> {
  _$TerminalSessionsStateCopyWithImpl(this._self, this._then);

  final TerminalSessionsState _self;
  final $Res Function(TerminalSessionsState) _then;

/// Create a copy of TerminalSessionsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessions = null,}) {
  return _then(_self.copyWith(
sessions: null == sessions ? _self.sessions : sessions // ignore: cast_nullable_to_non_nullable
as Map<String, TerminalSessionInfo>,
  ));
}

}


/// Adds pattern-matching-related methods to [TerminalSessionsState].
extension TerminalSessionsStatePatterns on TerminalSessionsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TerminalSessionsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TerminalSessionsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TerminalSessionsState value)  $default,){
final _that = this;
switch (_that) {
case _TerminalSessionsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TerminalSessionsState value)?  $default,){
final _that = this;
switch (_that) {
case _TerminalSessionsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, TerminalSessionInfo> sessions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TerminalSessionsState() when $default != null:
return $default(_that.sessions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, TerminalSessionInfo> sessions)  $default,) {final _that = this;
switch (_that) {
case _TerminalSessionsState():
return $default(_that.sessions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, TerminalSessionInfo> sessions)?  $default,) {final _that = this;
switch (_that) {
case _TerminalSessionsState() when $default != null:
return $default(_that.sessions);case _:
  return null;

}
}

}

/// @nodoc


class _TerminalSessionsState implements TerminalSessionsState {
  const _TerminalSessionsState({final  Map<String, TerminalSessionInfo> sessions = const <String, TerminalSessionInfo>{}}): _sessions = sessions;
  

 final  Map<String, TerminalSessionInfo> _sessions;
@override@JsonKey() Map<String, TerminalSessionInfo> get sessions {
  if (_sessions is EqualUnmodifiableMapView) return _sessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_sessions);
}


/// Create a copy of TerminalSessionsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TerminalSessionsStateCopyWith<_TerminalSessionsState> get copyWith => __$TerminalSessionsStateCopyWithImpl<_TerminalSessionsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TerminalSessionsState&&const DeepCollectionEquality().equals(other._sessions, _sessions));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_sessions));

@override
String toString() {
  return 'TerminalSessionsState(sessions: $sessions)';
}


}

/// @nodoc
abstract mixin class _$TerminalSessionsStateCopyWith<$Res> implements $TerminalSessionsStateCopyWith<$Res> {
  factory _$TerminalSessionsStateCopyWith(_TerminalSessionsState value, $Res Function(_TerminalSessionsState) _then) = __$TerminalSessionsStateCopyWithImpl;
@override @useResult
$Res call({
 Map<String, TerminalSessionInfo> sessions
});




}
/// @nodoc
class __$TerminalSessionsStateCopyWithImpl<$Res>
    implements _$TerminalSessionsStateCopyWith<$Res> {
  __$TerminalSessionsStateCopyWithImpl(this._self, this._then);

  final _TerminalSessionsState _self;
  final $Res Function(_TerminalSessionsState) _then;

/// Create a copy of TerminalSessionsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessions = null,}) {
  return _then(_TerminalSessionsState(
sessions: null == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as Map<String, TerminalSessionInfo>,
  ));
}


}

// dart format on
