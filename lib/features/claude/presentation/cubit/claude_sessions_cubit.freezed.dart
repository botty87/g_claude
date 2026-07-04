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

 String get tabId; List<ClaudeMessage> get messages; ClaudeRunStatus get runStatus; ClaudeModel get model; ClaudePermissionMode get permissionMode; ClaudeEffort get effort; ClaudeThinkingMode get thinkingMode; String? get claudeSessionId; Failure? get lastError; List<String> get stderrTail; List<String> get availableSkills; Set<String> get disabledMcpServers; ChatInputDraft get inputDraft; bool get allowAlwaysActive; QueuedPrompt? get queuedPrompt; SessionUsage? get usage;
/// Create a copy of ClaudeSessionData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeSessionDataCopyWith<ClaudeSessionData> get copyWith => _$ClaudeSessionDataCopyWithImpl<ClaudeSessionData>(this as ClaudeSessionData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeSessionData&&(identical(other.tabId, tabId) || other.tabId == tabId)&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.runStatus, runStatus) || other.runStatus == runStatus)&&(identical(other.model, model) || other.model == model)&&(identical(other.permissionMode, permissionMode) || other.permissionMode == permissionMode)&&(identical(other.effort, effort) || other.effort == effort)&&(identical(other.thinkingMode, thinkingMode) || other.thinkingMode == thinkingMode)&&(identical(other.claudeSessionId, claudeSessionId) || other.claudeSessionId == claudeSessionId)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&const DeepCollectionEquality().equals(other.stderrTail, stderrTail)&&const DeepCollectionEquality().equals(other.availableSkills, availableSkills)&&const DeepCollectionEquality().equals(other.disabledMcpServers, disabledMcpServers)&&(identical(other.inputDraft, inputDraft) || other.inputDraft == inputDraft)&&(identical(other.allowAlwaysActive, allowAlwaysActive) || other.allowAlwaysActive == allowAlwaysActive)&&(identical(other.queuedPrompt, queuedPrompt) || other.queuedPrompt == queuedPrompt)&&(identical(other.usage, usage) || other.usage == usage));
}


@override
int get hashCode => Object.hash(runtimeType,tabId,const DeepCollectionEquality().hash(messages),runStatus,model,permissionMode,effort,thinkingMode,claudeSessionId,lastError,const DeepCollectionEquality().hash(stderrTail),const DeepCollectionEquality().hash(availableSkills),const DeepCollectionEquality().hash(disabledMcpServers),inputDraft,allowAlwaysActive,queuedPrompt,usage);

@override
String toString() {
  return 'ClaudeSessionData(tabId: $tabId, messages: $messages, runStatus: $runStatus, model: $model, permissionMode: $permissionMode, effort: $effort, thinkingMode: $thinkingMode, claudeSessionId: $claudeSessionId, lastError: $lastError, stderrTail: $stderrTail, availableSkills: $availableSkills, disabledMcpServers: $disabledMcpServers, inputDraft: $inputDraft, allowAlwaysActive: $allowAlwaysActive, queuedPrompt: $queuedPrompt, usage: $usage)';
}


}

/// @nodoc
abstract mixin class $ClaudeSessionDataCopyWith<$Res>  {
  factory $ClaudeSessionDataCopyWith(ClaudeSessionData value, $Res Function(ClaudeSessionData) _then) = _$ClaudeSessionDataCopyWithImpl;
@useResult
$Res call({
 String tabId, List<ClaudeMessage> messages, ClaudeRunStatus runStatus, ClaudeModel model, ClaudePermissionMode permissionMode, ClaudeEffort effort, ClaudeThinkingMode thinkingMode, String? claudeSessionId, Failure? lastError, List<String> stderrTail, List<String> availableSkills, Set<String> disabledMcpServers, ChatInputDraft inputDraft, bool allowAlwaysActive, QueuedPrompt? queuedPrompt, SessionUsage? usage
});


$ChatInputDraftCopyWith<$Res> get inputDraft;$QueuedPromptCopyWith<$Res>? get queuedPrompt;$SessionUsageCopyWith<$Res>? get usage;

}
/// @nodoc
class _$ClaudeSessionDataCopyWithImpl<$Res>
    implements $ClaudeSessionDataCopyWith<$Res> {
  _$ClaudeSessionDataCopyWithImpl(this._self, this._then);

  final ClaudeSessionData _self;
  final $Res Function(ClaudeSessionData) _then;

/// Create a copy of ClaudeSessionData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tabId = null,Object? messages = null,Object? runStatus = null,Object? model = null,Object? permissionMode = null,Object? effort = null,Object? thinkingMode = null,Object? claudeSessionId = freezed,Object? lastError = freezed,Object? stderrTail = null,Object? availableSkills = null,Object? disabledMcpServers = null,Object? inputDraft = null,Object? allowAlwaysActive = null,Object? queuedPrompt = freezed,Object? usage = freezed,}) {
  return _then(_self.copyWith(
tabId: null == tabId ? _self.tabId : tabId // ignore: cast_nullable_to_non_nullable
as String,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
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
as Set<String>,inputDraft: null == inputDraft ? _self.inputDraft : inputDraft // ignore: cast_nullable_to_non_nullable
as ChatInputDraft,allowAlwaysActive: null == allowAlwaysActive ? _self.allowAlwaysActive : allowAlwaysActive // ignore: cast_nullable_to_non_nullable
as bool,queuedPrompt: freezed == queuedPrompt ? _self.queuedPrompt : queuedPrompt // ignore: cast_nullable_to_non_nullable
as QueuedPrompt?,usage: freezed == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as SessionUsage?,
  ));
}
/// Create a copy of ClaudeSessionData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatInputDraftCopyWith<$Res> get inputDraft {
  
  return $ChatInputDraftCopyWith<$Res>(_self.inputDraft, (value) {
    return _then(_self.copyWith(inputDraft: value));
  });
}/// Create a copy of ClaudeSessionData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QueuedPromptCopyWith<$Res>? get queuedPrompt {
    if (_self.queuedPrompt == null) {
    return null;
  }

  return $QueuedPromptCopyWith<$Res>(_self.queuedPrompt!, (value) {
    return _then(_self.copyWith(queuedPrompt: value));
  });
}/// Create a copy of ClaudeSessionData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionUsageCopyWith<$Res>? get usage {
    if (_self.usage == null) {
    return null;
  }

  return $SessionUsageCopyWith<$Res>(_self.usage!, (value) {
    return _then(_self.copyWith(usage: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tabId,  List<ClaudeMessage> messages,  ClaudeRunStatus runStatus,  ClaudeModel model,  ClaudePermissionMode permissionMode,  ClaudeEffort effort,  ClaudeThinkingMode thinkingMode,  String? claudeSessionId,  Failure? lastError,  List<String> stderrTail,  List<String> availableSkills,  Set<String> disabledMcpServers,  ChatInputDraft inputDraft,  bool allowAlwaysActive,  QueuedPrompt? queuedPrompt,  SessionUsage? usage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClaudeSessionData() when $default != null:
return $default(_that.tabId,_that.messages,_that.runStatus,_that.model,_that.permissionMode,_that.effort,_that.thinkingMode,_that.claudeSessionId,_that.lastError,_that.stderrTail,_that.availableSkills,_that.disabledMcpServers,_that.inputDraft,_that.allowAlwaysActive,_that.queuedPrompt,_that.usage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tabId,  List<ClaudeMessage> messages,  ClaudeRunStatus runStatus,  ClaudeModel model,  ClaudePermissionMode permissionMode,  ClaudeEffort effort,  ClaudeThinkingMode thinkingMode,  String? claudeSessionId,  Failure? lastError,  List<String> stderrTail,  List<String> availableSkills,  Set<String> disabledMcpServers,  ChatInputDraft inputDraft,  bool allowAlwaysActive,  QueuedPrompt? queuedPrompt,  SessionUsage? usage)  $default,) {final _that = this;
switch (_that) {
case _ClaudeSessionData():
return $default(_that.tabId,_that.messages,_that.runStatus,_that.model,_that.permissionMode,_that.effort,_that.thinkingMode,_that.claudeSessionId,_that.lastError,_that.stderrTail,_that.availableSkills,_that.disabledMcpServers,_that.inputDraft,_that.allowAlwaysActive,_that.queuedPrompt,_that.usage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tabId,  List<ClaudeMessage> messages,  ClaudeRunStatus runStatus,  ClaudeModel model,  ClaudePermissionMode permissionMode,  ClaudeEffort effort,  ClaudeThinkingMode thinkingMode,  String? claudeSessionId,  Failure? lastError,  List<String> stderrTail,  List<String> availableSkills,  Set<String> disabledMcpServers,  ChatInputDraft inputDraft,  bool allowAlwaysActive,  QueuedPrompt? queuedPrompt,  SessionUsage? usage)?  $default,) {final _that = this;
switch (_that) {
case _ClaudeSessionData() when $default != null:
return $default(_that.tabId,_that.messages,_that.runStatus,_that.model,_that.permissionMode,_that.effort,_that.thinkingMode,_that.claudeSessionId,_that.lastError,_that.stderrTail,_that.availableSkills,_that.disabledMcpServers,_that.inputDraft,_that.allowAlwaysActive,_that.queuedPrompt,_that.usage);case _:
  return null;

}
}

}

/// @nodoc


class _ClaudeSessionData implements ClaudeSessionData {
  const _ClaudeSessionData({this.tabId = '', final  List<ClaudeMessage> messages = const <ClaudeMessage>[], this.runStatus = ClaudeRunStatus.idle, required this.model, required this.permissionMode, required this.effort, required this.thinkingMode, this.claudeSessionId, this.lastError, final  List<String> stderrTail = const <String>[], final  List<String> availableSkills = const <String>[], final  Set<String> disabledMcpServers = const <String>{}, this.inputDraft = ChatInputDraft.empty, this.allowAlwaysActive = false, this.queuedPrompt, this.usage}): _messages = messages,_stderrTail = stderrTail,_availableSkills = availableSkills,_disabledMcpServers = disabledMcpServers;
  

@override@JsonKey() final  String tabId;
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

@override@JsonKey() final  ChatInputDraft inputDraft;
@override@JsonKey() final  bool allowAlwaysActive;
@override final  QueuedPrompt? queuedPrompt;
@override final  SessionUsage? usage;

/// Create a copy of ClaudeSessionData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClaudeSessionDataCopyWith<_ClaudeSessionData> get copyWith => __$ClaudeSessionDataCopyWithImpl<_ClaudeSessionData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClaudeSessionData&&(identical(other.tabId, tabId) || other.tabId == tabId)&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.runStatus, runStatus) || other.runStatus == runStatus)&&(identical(other.model, model) || other.model == model)&&(identical(other.permissionMode, permissionMode) || other.permissionMode == permissionMode)&&(identical(other.effort, effort) || other.effort == effort)&&(identical(other.thinkingMode, thinkingMode) || other.thinkingMode == thinkingMode)&&(identical(other.claudeSessionId, claudeSessionId) || other.claudeSessionId == claudeSessionId)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&const DeepCollectionEquality().equals(other._stderrTail, _stderrTail)&&const DeepCollectionEquality().equals(other._availableSkills, _availableSkills)&&const DeepCollectionEquality().equals(other._disabledMcpServers, _disabledMcpServers)&&(identical(other.inputDraft, inputDraft) || other.inputDraft == inputDraft)&&(identical(other.allowAlwaysActive, allowAlwaysActive) || other.allowAlwaysActive == allowAlwaysActive)&&(identical(other.queuedPrompt, queuedPrompt) || other.queuedPrompt == queuedPrompt)&&(identical(other.usage, usage) || other.usage == usage));
}


@override
int get hashCode => Object.hash(runtimeType,tabId,const DeepCollectionEquality().hash(_messages),runStatus,model,permissionMode,effort,thinkingMode,claudeSessionId,lastError,const DeepCollectionEquality().hash(_stderrTail),const DeepCollectionEquality().hash(_availableSkills),const DeepCollectionEquality().hash(_disabledMcpServers),inputDraft,allowAlwaysActive,queuedPrompt,usage);

@override
String toString() {
  return 'ClaudeSessionData(tabId: $tabId, messages: $messages, runStatus: $runStatus, model: $model, permissionMode: $permissionMode, effort: $effort, thinkingMode: $thinkingMode, claudeSessionId: $claudeSessionId, lastError: $lastError, stderrTail: $stderrTail, availableSkills: $availableSkills, disabledMcpServers: $disabledMcpServers, inputDraft: $inputDraft, allowAlwaysActive: $allowAlwaysActive, queuedPrompt: $queuedPrompt, usage: $usage)';
}


}

/// @nodoc
abstract mixin class _$ClaudeSessionDataCopyWith<$Res> implements $ClaudeSessionDataCopyWith<$Res> {
  factory _$ClaudeSessionDataCopyWith(_ClaudeSessionData value, $Res Function(_ClaudeSessionData) _then) = __$ClaudeSessionDataCopyWithImpl;
@override @useResult
$Res call({
 String tabId, List<ClaudeMessage> messages, ClaudeRunStatus runStatus, ClaudeModel model, ClaudePermissionMode permissionMode, ClaudeEffort effort, ClaudeThinkingMode thinkingMode, String? claudeSessionId, Failure? lastError, List<String> stderrTail, List<String> availableSkills, Set<String> disabledMcpServers, ChatInputDraft inputDraft, bool allowAlwaysActive, QueuedPrompt? queuedPrompt, SessionUsage? usage
});


@override $ChatInputDraftCopyWith<$Res> get inputDraft;@override $QueuedPromptCopyWith<$Res>? get queuedPrompt;@override $SessionUsageCopyWith<$Res>? get usage;

}
/// @nodoc
class __$ClaudeSessionDataCopyWithImpl<$Res>
    implements _$ClaudeSessionDataCopyWith<$Res> {
  __$ClaudeSessionDataCopyWithImpl(this._self, this._then);

  final _ClaudeSessionData _self;
  final $Res Function(_ClaudeSessionData) _then;

/// Create a copy of ClaudeSessionData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tabId = null,Object? messages = null,Object? runStatus = null,Object? model = null,Object? permissionMode = null,Object? effort = null,Object? thinkingMode = null,Object? claudeSessionId = freezed,Object? lastError = freezed,Object? stderrTail = null,Object? availableSkills = null,Object? disabledMcpServers = null,Object? inputDraft = null,Object? allowAlwaysActive = null,Object? queuedPrompt = freezed,Object? usage = freezed,}) {
  return _then(_ClaudeSessionData(
tabId: null == tabId ? _self.tabId : tabId // ignore: cast_nullable_to_non_nullable
as String,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
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
as Set<String>,inputDraft: null == inputDraft ? _self.inputDraft : inputDraft // ignore: cast_nullable_to_non_nullable
as ChatInputDraft,allowAlwaysActive: null == allowAlwaysActive ? _self.allowAlwaysActive : allowAlwaysActive // ignore: cast_nullable_to_non_nullable
as bool,queuedPrompt: freezed == queuedPrompt ? _self.queuedPrompt : queuedPrompt // ignore: cast_nullable_to_non_nullable
as QueuedPrompt?,usage: freezed == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as SessionUsage?,
  ));
}

/// Create a copy of ClaudeSessionData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatInputDraftCopyWith<$Res> get inputDraft {
  
  return $ChatInputDraftCopyWith<$Res>(_self.inputDraft, (value) {
    return _then(_self.copyWith(inputDraft: value));
  });
}/// Create a copy of ClaudeSessionData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QueuedPromptCopyWith<$Res>? get queuedPrompt {
    if (_self.queuedPrompt == null) {
    return null;
  }

  return $QueuedPromptCopyWith<$Res>(_self.queuedPrompt!, (value) {
    return _then(_self.copyWith(queuedPrompt: value));
  });
}/// Create a copy of ClaudeSessionData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionUsageCopyWith<$Res>? get usage {
    if (_self.usage == null) {
    return null;
  }

  return $SessionUsageCopyWith<$Res>(_self.usage!, (value) {
    return _then(_self.copyWith(usage: value));
  });
}
}

/// @nodoc
mixin _$WorkspaceSessions {

 List<ClaudeSessionData> get tabs; String get activeTabId;
/// Create a copy of WorkspaceSessions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspaceSessionsCopyWith<WorkspaceSessions> get copyWith => _$WorkspaceSessionsCopyWithImpl<WorkspaceSessions>(this as WorkspaceSessions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceSessions&&const DeepCollectionEquality().equals(other.tabs, tabs)&&(identical(other.activeTabId, activeTabId) || other.activeTabId == activeTabId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(tabs),activeTabId);

@override
String toString() {
  return 'WorkspaceSessions(tabs: $tabs, activeTabId: $activeTabId)';
}


}

/// @nodoc
abstract mixin class $WorkspaceSessionsCopyWith<$Res>  {
  factory $WorkspaceSessionsCopyWith(WorkspaceSessions value, $Res Function(WorkspaceSessions) _then) = _$WorkspaceSessionsCopyWithImpl;
@useResult
$Res call({
 List<ClaudeSessionData> tabs, String activeTabId
});




}
/// @nodoc
class _$WorkspaceSessionsCopyWithImpl<$Res>
    implements $WorkspaceSessionsCopyWith<$Res> {
  _$WorkspaceSessionsCopyWithImpl(this._self, this._then);

  final WorkspaceSessions _self;
  final $Res Function(WorkspaceSessions) _then;

/// Create a copy of WorkspaceSessions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tabs = null,Object? activeTabId = null,}) {
  return _then(_self.copyWith(
tabs: null == tabs ? _self.tabs : tabs // ignore: cast_nullable_to_non_nullable
as List<ClaudeSessionData>,activeTabId: null == activeTabId ? _self.activeTabId : activeTabId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkspaceSessions].
extension WorkspaceSessionsPatterns on WorkspaceSessions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkspaceSessions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkspaceSessions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkspaceSessions value)  $default,){
final _that = this;
switch (_that) {
case _WorkspaceSessions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkspaceSessions value)?  $default,){
final _that = this;
switch (_that) {
case _WorkspaceSessions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ClaudeSessionData> tabs,  String activeTabId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkspaceSessions() when $default != null:
return $default(_that.tabs,_that.activeTabId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ClaudeSessionData> tabs,  String activeTabId)  $default,) {final _that = this;
switch (_that) {
case _WorkspaceSessions():
return $default(_that.tabs,_that.activeTabId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ClaudeSessionData> tabs,  String activeTabId)?  $default,) {final _that = this;
switch (_that) {
case _WorkspaceSessions() when $default != null:
return $default(_that.tabs,_that.activeTabId);case _:
  return null;

}
}

}

/// @nodoc


class _WorkspaceSessions extends WorkspaceSessions {
  const _WorkspaceSessions({final  List<ClaudeSessionData> tabs = const <ClaudeSessionData>[], this.activeTabId = ''}): _tabs = tabs,super._();
  

 final  List<ClaudeSessionData> _tabs;
@override@JsonKey() List<ClaudeSessionData> get tabs {
  if (_tabs is EqualUnmodifiableListView) return _tabs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tabs);
}

@override@JsonKey() final  String activeTabId;

/// Create a copy of WorkspaceSessions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkspaceSessionsCopyWith<_WorkspaceSessions> get copyWith => __$WorkspaceSessionsCopyWithImpl<_WorkspaceSessions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceSessions&&const DeepCollectionEquality().equals(other._tabs, _tabs)&&(identical(other.activeTabId, activeTabId) || other.activeTabId == activeTabId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_tabs),activeTabId);

@override
String toString() {
  return 'WorkspaceSessions(tabs: $tabs, activeTabId: $activeTabId)';
}


}

/// @nodoc
abstract mixin class _$WorkspaceSessionsCopyWith<$Res> implements $WorkspaceSessionsCopyWith<$Res> {
  factory _$WorkspaceSessionsCopyWith(_WorkspaceSessions value, $Res Function(_WorkspaceSessions) _then) = __$WorkspaceSessionsCopyWithImpl;
@override @useResult
$Res call({
 List<ClaudeSessionData> tabs, String activeTabId
});




}
/// @nodoc
class __$WorkspaceSessionsCopyWithImpl<$Res>
    implements _$WorkspaceSessionsCopyWith<$Res> {
  __$WorkspaceSessionsCopyWithImpl(this._self, this._then);

  final _WorkspaceSessions _self;
  final $Res Function(_WorkspaceSessions) _then;

/// Create a copy of WorkspaceSessions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tabs = null,Object? activeTabId = null,}) {
  return _then(_WorkspaceSessions(
tabs: null == tabs ? _self._tabs : tabs // ignore: cast_nullable_to_non_nullable
as List<ClaudeSessionData>,activeTabId: null == activeTabId ? _self.activeTabId : activeTabId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ClaudeSessionsState {

 Map<String, WorkspaceSessions> get workspaces;// Account-wide MCP server list (from `claude mcp list` + sessionInit merge).
// Global, not per-workspace; kept in state so the "N active" count is reactive.
 List<McpServer> get mcpServers;// Server names with an OAuth flow in flight — guards the auth button against
// re-entrancy (a double-click would otherwise spawn duplicate ephemeral
// sidecar queries) and drives its pending affordance.
 Set<String> get mcpAuthInFlight;
/// Create a copy of ClaudeSessionsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeSessionsStateCopyWith<ClaudeSessionsState> get copyWith => _$ClaudeSessionsStateCopyWithImpl<ClaudeSessionsState>(this as ClaudeSessionsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeSessionsState&&const DeepCollectionEquality().equals(other.workspaces, workspaces)&&const DeepCollectionEquality().equals(other.mcpServers, mcpServers)&&const DeepCollectionEquality().equals(other.mcpAuthInFlight, mcpAuthInFlight));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(workspaces),const DeepCollectionEquality().hash(mcpServers),const DeepCollectionEquality().hash(mcpAuthInFlight));

@override
String toString() {
  return 'ClaudeSessionsState(workspaces: $workspaces, mcpServers: $mcpServers, mcpAuthInFlight: $mcpAuthInFlight)';
}


}

/// @nodoc
abstract mixin class $ClaudeSessionsStateCopyWith<$Res>  {
  factory $ClaudeSessionsStateCopyWith(ClaudeSessionsState value, $Res Function(ClaudeSessionsState) _then) = _$ClaudeSessionsStateCopyWithImpl;
@useResult
$Res call({
 Map<String, WorkspaceSessions> workspaces, List<McpServer> mcpServers, Set<String> mcpAuthInFlight
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
@pragma('vm:prefer-inline') @override $Res call({Object? workspaces = null,Object? mcpServers = null,Object? mcpAuthInFlight = null,}) {
  return _then(_self.copyWith(
workspaces: null == workspaces ? _self.workspaces : workspaces // ignore: cast_nullable_to_non_nullable
as Map<String, WorkspaceSessions>,mcpServers: null == mcpServers ? _self.mcpServers : mcpServers // ignore: cast_nullable_to_non_nullable
as List<McpServer>,mcpAuthInFlight: null == mcpAuthInFlight ? _self.mcpAuthInFlight : mcpAuthInFlight // ignore: cast_nullable_to_non_nullable
as Set<String>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, WorkspaceSessions> workspaces,  List<McpServer> mcpServers,  Set<String> mcpAuthInFlight)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClaudeSessionsState() when $default != null:
return $default(_that.workspaces,_that.mcpServers,_that.mcpAuthInFlight);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, WorkspaceSessions> workspaces,  List<McpServer> mcpServers,  Set<String> mcpAuthInFlight)  $default,) {final _that = this;
switch (_that) {
case _ClaudeSessionsState():
return $default(_that.workspaces,_that.mcpServers,_that.mcpAuthInFlight);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, WorkspaceSessions> workspaces,  List<McpServer> mcpServers,  Set<String> mcpAuthInFlight)?  $default,) {final _that = this;
switch (_that) {
case _ClaudeSessionsState() when $default != null:
return $default(_that.workspaces,_that.mcpServers,_that.mcpAuthInFlight);case _:
  return null;

}
}

}

/// @nodoc


class _ClaudeSessionsState extends ClaudeSessionsState {
  const _ClaudeSessionsState({final  Map<String, WorkspaceSessions> workspaces = const <String, WorkspaceSessions>{}, final  List<McpServer> mcpServers = const <McpServer>[], final  Set<String> mcpAuthInFlight = const <String>{}}): _workspaces = workspaces,_mcpServers = mcpServers,_mcpAuthInFlight = mcpAuthInFlight,super._();
  

 final  Map<String, WorkspaceSessions> _workspaces;
@override@JsonKey() Map<String, WorkspaceSessions> get workspaces {
  if (_workspaces is EqualUnmodifiableMapView) return _workspaces;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_workspaces);
}

// Account-wide MCP server list (from `claude mcp list` + sessionInit merge).
// Global, not per-workspace; kept in state so the "N active" count is reactive.
 final  List<McpServer> _mcpServers;
// Account-wide MCP server list (from `claude mcp list` + sessionInit merge).
// Global, not per-workspace; kept in state so the "N active" count is reactive.
@override@JsonKey() List<McpServer> get mcpServers {
  if (_mcpServers is EqualUnmodifiableListView) return _mcpServers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mcpServers);
}

// Server names with an OAuth flow in flight — guards the auth button against
// re-entrancy (a double-click would otherwise spawn duplicate ephemeral
// sidecar queries) and drives its pending affordance.
 final  Set<String> _mcpAuthInFlight;
// Server names with an OAuth flow in flight — guards the auth button against
// re-entrancy (a double-click would otherwise spawn duplicate ephemeral
// sidecar queries) and drives its pending affordance.
@override@JsonKey() Set<String> get mcpAuthInFlight {
  if (_mcpAuthInFlight is EqualUnmodifiableSetView) return _mcpAuthInFlight;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_mcpAuthInFlight);
}


/// Create a copy of ClaudeSessionsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClaudeSessionsStateCopyWith<_ClaudeSessionsState> get copyWith => __$ClaudeSessionsStateCopyWithImpl<_ClaudeSessionsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClaudeSessionsState&&const DeepCollectionEquality().equals(other._workspaces, _workspaces)&&const DeepCollectionEquality().equals(other._mcpServers, _mcpServers)&&const DeepCollectionEquality().equals(other._mcpAuthInFlight, _mcpAuthInFlight));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_workspaces),const DeepCollectionEquality().hash(_mcpServers),const DeepCollectionEquality().hash(_mcpAuthInFlight));

@override
String toString() {
  return 'ClaudeSessionsState(workspaces: $workspaces, mcpServers: $mcpServers, mcpAuthInFlight: $mcpAuthInFlight)';
}


}

/// @nodoc
abstract mixin class _$ClaudeSessionsStateCopyWith<$Res> implements $ClaudeSessionsStateCopyWith<$Res> {
  factory _$ClaudeSessionsStateCopyWith(_ClaudeSessionsState value, $Res Function(_ClaudeSessionsState) _then) = __$ClaudeSessionsStateCopyWithImpl;
@override @useResult
$Res call({
 Map<String, WorkspaceSessions> workspaces, List<McpServer> mcpServers, Set<String> mcpAuthInFlight
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
@override @pragma('vm:prefer-inline') $Res call({Object? workspaces = null,Object? mcpServers = null,Object? mcpAuthInFlight = null,}) {
  return _then(_ClaudeSessionsState(
workspaces: null == workspaces ? _self._workspaces : workspaces // ignore: cast_nullable_to_non_nullable
as Map<String, WorkspaceSessions>,mcpServers: null == mcpServers ? _self._mcpServers : mcpServers // ignore: cast_nullable_to_non_nullable
as List<McpServer>,mcpAuthInFlight: null == mcpAuthInFlight ? _self._mcpAuthInFlight : mcpAuthInFlight // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

// dart format on
