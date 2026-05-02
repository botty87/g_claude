// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'claude_sessions_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClaudeSessionData {

 List<ClaudeMessage> get messages; ClaudeRunStatus get runStatus; ClaudeModel get model; ClaudePermissionMode get permissionMode; ClaudeEffort get effort; ClaudeThinkingMode get thinkingMode; String? get claudeSessionId; Failure? get lastError; List<String> get stderrTail; List<String> get availableSkills; Set<String> get disabledMcpServers;
/// Create a copy of ClaudeSessionData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeSessionDataCopyWith<ClaudeSessionData> get copyWith => _$ClaudeSessionDataCopyWithImpl<ClaudeSessionData>(this as ClaudeSessionData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeSessionData&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.runStatus, runStatus) || other.runStatus == runStatus)&&(identical(other.model, model) || other.model == model)&&(identical(other.permissionMode, permissionMode) || other.permissionMode == permissionMode)&&(identical(other.effort, effort) || other.effort == effort)&&(identical(other.thinkingMode, thinkingMode) || other.thinkingMode == thinkingMode)&&(identical(other.claudeSessionId, claudeSessionId) || other.claudeSessionId == claudeSessionId)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&const DeepCollectionEquality().equals(other.stderrTail, stderrTail)&&const DeepCollectionEquality().equals(other.availableSkills, availableSkills)&&const DeepCollectionEquality().equals(other.disabledMcpServers, disabledMcpServers));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(messages),runStatus,model,permissionMode,effort,thinkingMode,claudeSessionId,lastError,const DeepCollectionEquality().hash(stderrTail),const DeepCollectionEquality().hash(availableSkills),const DeepCollectionEquality().hash(disabledMcpServers));

@override
String toString() {
  return 'ClaudeSessionData(messages: $messages, runStatus: $runStatus, model: $model, permissionMode: $permissionMode, effort: $effort, thinkingMode: $thinkingMode, claudeSessionId: $claudeSessionId, lastError: $lastError, stderrTail: $stderrTail, availableSkills: $availableSkills, disabledMcpServers: $disabledMcpServers)';
}


}

/// @nodoc
abstract mixin class $ClaudeSessionDataCopyWith<$Res>  {
  factory $ClaudeSessionDataCopyWith(ClaudeSessionData value, $Res Function(ClaudeSessionData) _then) = _$ClaudeSessionDataCopyWithImpl;
@useResult
$Res call({
 List<ClaudeMessage> messages, ClaudeRunStatus runStatus, ClaudeModel model, ClaudePermissionMode permissionMode, ClaudeEffort effort, ClaudeThinkingMode thinkingMode, String? claudeSessionId, Failure? lastError, List<String> stderrTail, List<String> availableSkills, Set<String> disabledMcpServers
});




}
/// @nodoc
class _$ClaudeSessionDataCopyWithImpl<$Res>
    implements $ClaudeSessionDataCopyWith<$Res> {
  _$ClaudeSessionDataCopyWithImpl(this._self, this._then);

  final ClaudeSessionData _self;
  final $Res Function(ClaudeSessionData) _then;

/// Create a copy of ClaudeSessionData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messages = null,Object? runStatus = null,Object? model = null,Object? permissionMode = null,Object? effort = null,Object? thinkingMode = null,Object? claudeSessionId = freezed,Object? lastError = freezed,Object? stderrTail = null,Object? availableSkills = null,Object? disabledMcpServers = null,}) {
  return _then(_self.copyWith(
messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<ClaudeMessage>,runStatus: null == runStatus ? _self.runStatus : runStatus // ignore: cast_nullable_to_non_nullable
as ClaudeRunStatus,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as ClaudeModel,permissionMode: null == permissionMode ? _self.permissionMode : permissionMode // ignore: cast_nullable_to_non_nullable
as ClaudePermissionMode,effort: null == effort ? _self.effort : effort // ignore: cast_nullable_to_non_nullable
as ClaudeEffort,thinkingMode: null == thinkingMode ? _self.thinkingMode : thinkingMode // ignore: cast_nullable_to_non_nullable
as ClaudeThinkingMode,claudeSessionId: freezed == claudeSessionId ? _self.claudeSessionId : claudeSessionId // ignore: cast_nullable_to_non_nullable
as String?,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as Failure?,stderrTail: null == stderrTail ? _self.stderrTail : stderrTail // ignore: cast_nullable_to_non_nullable
as List<String>,availableSkills: null == availableSkills ? _self.availableSkills : availableSkills // ignore: cast_nullable_to_non_nullable
as List<String>,disabledMcpServers: null == disabledMcpServers ? _self.disabledMcpServers : disabledMcpServers // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ClaudeSessionData].
extension ClaudeSessionDataPatterns on ClaudeSessionData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClaudeSessionData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClaudeSessionData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClaudeSessionData value)  $default,){
final _that = this;
switch (_that) {
case _ClaudeSessionData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClaudeSessionData value)?  $default,){
final _that = this;
switch (_that) {
case _ClaudeSessionData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ClaudeMessage> messages,  ClaudeRunStatus runStatus,  ClaudeModel model,  ClaudePermissionMode permissionMode,  ClaudeEffort effort,  ClaudeThinkingMode thinkingMode,  String? claudeSessionId,  Failure? lastError,  List<String> stderrTail,  List<String> availableSkills,  Set<String> disabledMcpServers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClaudeSessionData() when $default != null:
return $default(_that.messages,_that.runStatus,_that.model,_that.permissionMode,_that.effort,_that.thinkingMode,_that.claudeSessionId,_that.lastError,_that.stderrTail,_that.availableSkills,_that.disabledMcpServers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ClaudeMessage> messages,  ClaudeRunStatus runStatus,  ClaudeModel model,  ClaudePermissionMode permissionMode,  ClaudeEffort effort,  ClaudeThinkingMode thinkingMode,  String? claudeSessionId,  Failure? lastError,  List<String> stderrTail,  List<String> availableSkills,  Set<String> disabledMcpServers)  $default,) {final _that = this;
switch (_that) {
case _ClaudeSessionData():
return $default(_that.messages,_that.runStatus,_that.model,_that.permissionMode,_that.effort,_that.thinkingMode,_that.claudeSessionId,_that.lastError,_that.stderrTail,_that.availableSkills,_that.disabledMcpServers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ClaudeMessage> messages,  ClaudeRunStatus runStatus,  ClaudeModel model,  ClaudePermissionMode permissionMode,  ClaudeEffort effort,  ClaudeThinkingMode thinkingMode,  String? claudeSessionId,  Failure? lastError,  List<String> stderrTail,  List<String> availableSkills,  Set<String> disabledMcpServers)?  $default,) {final _that = this;
switch (_that) {
case _ClaudeSessionData() when $default != null:
return $default(_that.messages,_that.runStatus,_that.model,_that.permissionMode,_that.effort,_that.thinkingMode,_that.claudeSessionId,_that.lastError,_that.stderrTail,_that.availableSkills,_that.disabledMcpServers);case _:
  return null;

}
}

}

/// @nodoc


class _ClaudeSessionData implements ClaudeSessionData {
  const _ClaudeSessionData({final  List<ClaudeMessage> messages = const <ClaudeMessage>[], this.runStatus = ClaudeRunStatus.idle, required this.model, required this.permissionMode, required this.effort, required this.thinkingMode, this.claudeSessionId, this.lastError, final  List<String> stderrTail = const <String>[], final  List<String> availableSkills = const <String>[], final  Set<String> disabledMcpServers = const <String>{}}): _messages = messages,_stderrTail = stderrTail,_availableSkills = availableSkills,_disabledMcpServers = disabledMcpServers;
  

 final  List<ClaudeMessage> _messages;
@override@JsonKey() List<ClaudeMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

@override@JsonKey() final  ClaudeRunStatus runStatus;
@override final  ClaudeModel model;
@override final  ClaudePermissionMode permissionMode;
@override final  ClaudeEffort effort;
@override final  ClaudeThinkingMode thinkingMode;
@override final  String? claudeSessionId;
@override final  Failure? lastError;
 final  List<String> _stderrTail;
@override@JsonKey() List<String> get stderrTail {
  if (_stderrTail is EqualUnmodifiableListView) return _stderrTail;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stderrTail);
}

 final  List<String> _availableSkills;
@override@JsonKey() List<String> get availableSkills {
  if (_availableSkills is EqualUnmodifiableListView) return _availableSkills;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableSkills);
}

 final  Set<String> _disabledMcpServers;
@override@JsonKey() Set<String> get disabledMcpServers {
  if (_disabledMcpServers is EqualUnmodifiableSetView) return _disabledMcpServers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_disabledMcpServers);
}


/// Create a copy of ClaudeSessionData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClaudeSessionDataCopyWith<_ClaudeSessionData> get copyWith => __$ClaudeSessionDataCopyWithImpl<_ClaudeSessionData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClaudeSessionData&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.runStatus, runStatus) || other.runStatus == runStatus)&&(identical(other.model, model) || other.model == model)&&(identical(other.permissionMode, permissionMode) || other.permissionMode == permissionMode)&&(identical(other.effort, effort) || other.effort == effort)&&(identical(other.thinkingMode, thinkingMode) || other.thinkingMode == thinkingMode)&&(identical(other.claudeSessionId, claudeSessionId) || other.claudeSessionId == claudeSessionId)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&const DeepCollectionEquality().equals(other._stderrTail, _stderrTail)&&const DeepCollectionEquality().equals(other._availableSkills, _availableSkills)&&const DeepCollectionEquality().equals(other._disabledMcpServers, _disabledMcpServers));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_messages),runStatus,model,permissionMode,effort,thinkingMode,claudeSessionId,lastError,const DeepCollectionEquality().hash(_stderrTail),const DeepCollectionEquality().hash(_availableSkills),const DeepCollectionEquality().hash(_disabledMcpServers));

@override
String toString() {
  return 'ClaudeSessionData(messages: $messages, runStatus: $runStatus, model: $model, permissionMode: $permissionMode, effort: $effort, thinkingMode: $thinkingMode, claudeSessionId: $claudeSessionId, lastError: $lastError, stderrTail: $stderrTail, availableSkills: $availableSkills, disabledMcpServers: $disabledMcpServers)';
}


}

/// @nodoc
abstract mixin class _$ClaudeSessionDataCopyWith<$Res> implements $ClaudeSessionDataCopyWith<$Res> {
  factory _$ClaudeSessionDataCopyWith(_ClaudeSessionData value, $Res Function(_ClaudeSessionData) _then) = __$ClaudeSessionDataCopyWithImpl;
@override @useResult
$Res call({
 List<ClaudeMessage> messages, ClaudeRunStatus runStatus, ClaudeModel model, ClaudePermissionMode permissionMode, ClaudeEffort effort, ClaudeThinkingMode thinkingMode, String? claudeSessionId, Failure? lastError, List<String> stderrTail, List<String> availableSkills, Set<String> disabledMcpServers
});




}
/// @nodoc
class __$ClaudeSessionDataCopyWithImpl<$Res>
    implements _$ClaudeSessionDataCopyWith<$Res> {
  __$ClaudeSessionDataCopyWithImpl(this._self, this._then);

  final _ClaudeSessionData _self;
  final $Res Function(_ClaudeSessionData) _then;

/// Create a copy of ClaudeSessionData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messages = null,Object? runStatus = null,Object? model = null,Object? permissionMode = null,Object? effort = null,Object? thinkingMode = null,Object? claudeSessionId = freezed,Object? lastError = freezed,Object? stderrTail = null,Object? availableSkills = null,Object? disabledMcpServers = null,}) {
  return _then(_ClaudeSessionData(
messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<ClaudeMessage>,runStatus: null == runStatus ? _self.runStatus : runStatus // ignore: cast_nullable_to_non_nullable
as ClaudeRunStatus,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as ClaudeModel,permissionMode: null == permissionMode ? _self.permissionMode : permissionMode // ignore: cast_nullable_to_non_nullable
as ClaudePermissionMode,effort: null == effort ? _self.effort : effort // ignore: cast_nullable_to_non_nullable
as ClaudeEffort,thinkingMode: null == thinkingMode ? _self.thinkingMode : thinkingMode // ignore: cast_nullable_to_non_nullable
as ClaudeThinkingMode,claudeSessionId: freezed == claudeSessionId ? _self.claudeSessionId : claudeSessionId // ignore: cast_nullable_to_non_nullable
as String?,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as Failure?,stderrTail: null == stderrTail ? _self._stderrTail : stderrTail // ignore: cast_nullable_to_non_nullable
as List<String>,availableSkills: null == availableSkills ? _self._availableSkills : availableSkills // ignore: cast_nullable_to_non_nullable
as List<String>,disabledMcpServers: null == disabledMcpServers ? _self._disabledMcpServers : disabledMcpServers // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

/// @nodoc
mixin _$ClaudeSessionsState {

 Map<String, ClaudeSessionData> get sessions;
/// Create a copy of ClaudeSessionsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeSessionsStateCopyWith<ClaudeSessionsState> get copyWith => _$ClaudeSessionsStateCopyWithImpl<ClaudeSessionsState>(this as ClaudeSessionsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeSessionsState&&const DeepCollectionEquality().equals(other.sessions, sessions));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(sessions));

@override
String toString() {
  return 'ClaudeSessionsState(sessions: $sessions)';
}


}

/// @nodoc
abstract mixin class $ClaudeSessionsStateCopyWith<$Res>  {
  factory $ClaudeSessionsStateCopyWith(ClaudeSessionsState value, $Res Function(ClaudeSessionsState) _then) = _$ClaudeSessionsStateCopyWithImpl;
@useResult
$Res call({
 Map<String, ClaudeSessionData> sessions
});




}
/// @nodoc
class _$ClaudeSessionsStateCopyWithImpl<$Res>
    implements $ClaudeSessionsStateCopyWith<$Res> {
  _$ClaudeSessionsStateCopyWithImpl(this._self, this._then);

  final ClaudeSessionsState _self;
  final $Res Function(ClaudeSessionsState) _then;

/// Create a copy of ClaudeSessionsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessions = null,}) {
  return _then(_self.copyWith(
sessions: null == sessions ? _self.sessions : sessions // ignore: cast_nullable_to_non_nullable
as Map<String, ClaudeSessionData>,
  ));
}

}


/// Adds pattern-matching-related methods to [ClaudeSessionsState].
extension ClaudeSessionsStatePatterns on ClaudeSessionsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClaudeSessionsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClaudeSessionsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClaudeSessionsState value)  $default,){
final _that = this;
switch (_that) {
case _ClaudeSessionsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClaudeSessionsState value)?  $default,){
final _that = this;
switch (_that) {
case _ClaudeSessionsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, ClaudeSessionData> sessions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClaudeSessionsState() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, ClaudeSessionData> sessions)  $default,) {final _that = this;
switch (_that) {
case _ClaudeSessionsState():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, ClaudeSessionData> sessions)?  $default,) {final _that = this;
switch (_that) {
case _ClaudeSessionsState() when $default != null:
return $default(_that.sessions);case _:
  return null;

}
}

}

/// @nodoc


class _ClaudeSessionsState extends ClaudeSessionsState {
  const _ClaudeSessionsState({final  Map<String, ClaudeSessionData> sessions = const <String, ClaudeSessionData>{}}): _sessions = sessions,super._();
  

 final  Map<String, ClaudeSessionData> _sessions;
@override@JsonKey() Map<String, ClaudeSessionData> get sessions {
  if (_sessions is EqualUnmodifiableMapView) return _sessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_sessions);
}


/// Create a copy of ClaudeSessionsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClaudeSessionsStateCopyWith<_ClaudeSessionsState> get copyWith => __$ClaudeSessionsStateCopyWithImpl<_ClaudeSessionsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClaudeSessionsState&&const DeepCollectionEquality().equals(other._sessions, _sessions));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_sessions));

@override
String toString() {
  return 'ClaudeSessionsState(sessions: $sessions)';
}


}

/// @nodoc
abstract mixin class _$ClaudeSessionsStateCopyWith<$Res> implements $ClaudeSessionsStateCopyWith<$Res> {
  factory _$ClaudeSessionsStateCopyWith(_ClaudeSessionsState value, $Res Function(_ClaudeSessionsState) _then) = __$ClaudeSessionsStateCopyWithImpl;
@override @useResult
$Res call({
 Map<String, ClaudeSessionData> sessions
});




}
/// @nodoc
class __$ClaudeSessionsStateCopyWithImpl<$Res>
    implements _$ClaudeSessionsStateCopyWith<$Res> {
  __$ClaudeSessionsStateCopyWithImpl(this._self, this._then);

  final _ClaudeSessionsState _self;
  final $Res Function(_ClaudeSessionsState) _then;

/// Create a copy of ClaudeSessionsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessions = null,}) {
  return _then(_ClaudeSessionsState(
sessions: null == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as Map<String, ClaudeSessionData>,
  ));
}


}

// dart format on
