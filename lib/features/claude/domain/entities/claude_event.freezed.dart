// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'claude_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClaudeEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ClaudeEvent()';
}


}

/// @nodoc
class $ClaudeEventCopyWith<$Res>  {
$ClaudeEventCopyWith(ClaudeEvent _, $Res Function(ClaudeEvent) __);
}


/// Adds pattern-matching-related methods to [ClaudeEvent].
extension ClaudeEventPatterns on ClaudeEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ClaudeEventSessionInit value)?  sessionInit,TResult Function( ClaudeEventTextChunk value)?  textChunk,TResult Function( ClaudeEventToolCall value)?  toolCall,TResult Function( ClaudeEventToolCallUpdate value)?  toolCallUpdate,TResult Function( ClaudeEventToolCallComplete value)?  toolCallComplete,TResult Function( ClaudeEventToolResult value)?  toolResult,TResult Function( ClaudeEventAssistantMessage value)?  assistantMessage,TResult Function( ClaudeEventTaskComplete value)?  taskComplete,TResult Function( ClaudeEventErrorEvent value)?  errorEvent,TResult Function( ClaudeEventRateLimit value)?  rateLimit,TResult Function( ClaudeEventSessionDead value)?  sessionDead,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ClaudeEventSessionInit() when sessionInit != null:
return sessionInit(_that);case ClaudeEventTextChunk() when textChunk != null:
return textChunk(_that);case ClaudeEventToolCall() when toolCall != null:
return toolCall(_that);case ClaudeEventToolCallUpdate() when toolCallUpdate != null:
return toolCallUpdate(_that);case ClaudeEventToolCallComplete() when toolCallComplete != null:
return toolCallComplete(_that);case ClaudeEventToolResult() when toolResult != null:
return toolResult(_that);case ClaudeEventAssistantMessage() when assistantMessage != null:
return assistantMessage(_that);case ClaudeEventTaskComplete() when taskComplete != null:
return taskComplete(_that);case ClaudeEventErrorEvent() when errorEvent != null:
return errorEvent(_that);case ClaudeEventRateLimit() when rateLimit != null:
return rateLimit(_that);case ClaudeEventSessionDead() when sessionDead != null:
return sessionDead(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ClaudeEventSessionInit value)  sessionInit,required TResult Function( ClaudeEventTextChunk value)  textChunk,required TResult Function( ClaudeEventToolCall value)  toolCall,required TResult Function( ClaudeEventToolCallUpdate value)  toolCallUpdate,required TResult Function( ClaudeEventToolCallComplete value)  toolCallComplete,required TResult Function( ClaudeEventToolResult value)  toolResult,required TResult Function( ClaudeEventAssistantMessage value)  assistantMessage,required TResult Function( ClaudeEventTaskComplete value)  taskComplete,required TResult Function( ClaudeEventErrorEvent value)  errorEvent,required TResult Function( ClaudeEventRateLimit value)  rateLimit,required TResult Function( ClaudeEventSessionDead value)  sessionDead,}){
final _that = this;
switch (_that) {
case ClaudeEventSessionInit():
return sessionInit(_that);case ClaudeEventTextChunk():
return textChunk(_that);case ClaudeEventToolCall():
return toolCall(_that);case ClaudeEventToolCallUpdate():
return toolCallUpdate(_that);case ClaudeEventToolCallComplete():
return toolCallComplete(_that);case ClaudeEventToolResult():
return toolResult(_that);case ClaudeEventAssistantMessage():
return assistantMessage(_that);case ClaudeEventTaskComplete():
return taskComplete(_that);case ClaudeEventErrorEvent():
return errorEvent(_that);case ClaudeEventRateLimit():
return rateLimit(_that);case ClaudeEventSessionDead():
return sessionDead(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ClaudeEventSessionInit value)?  sessionInit,TResult? Function( ClaudeEventTextChunk value)?  textChunk,TResult? Function( ClaudeEventToolCall value)?  toolCall,TResult? Function( ClaudeEventToolCallUpdate value)?  toolCallUpdate,TResult? Function( ClaudeEventToolCallComplete value)?  toolCallComplete,TResult? Function( ClaudeEventToolResult value)?  toolResult,TResult? Function( ClaudeEventAssistantMessage value)?  assistantMessage,TResult? Function( ClaudeEventTaskComplete value)?  taskComplete,TResult? Function( ClaudeEventErrorEvent value)?  errorEvent,TResult? Function( ClaudeEventRateLimit value)?  rateLimit,TResult? Function( ClaudeEventSessionDead value)?  sessionDead,}){
final _that = this;
switch (_that) {
case ClaudeEventSessionInit() when sessionInit != null:
return sessionInit(_that);case ClaudeEventTextChunk() when textChunk != null:
return textChunk(_that);case ClaudeEventToolCall() when toolCall != null:
return toolCall(_that);case ClaudeEventToolCallUpdate() when toolCallUpdate != null:
return toolCallUpdate(_that);case ClaudeEventToolCallComplete() when toolCallComplete != null:
return toolCallComplete(_that);case ClaudeEventToolResult() when toolResult != null:
return toolResult(_that);case ClaudeEventAssistantMessage() when assistantMessage != null:
return assistantMessage(_that);case ClaudeEventTaskComplete() when taskComplete != null:
return taskComplete(_that);case ClaudeEventErrorEvent() when errorEvent != null:
return errorEvent(_that);case ClaudeEventRateLimit() when rateLimit != null:
return rateLimit(_that);case ClaudeEventSessionDead() when sessionDead != null:
return sessionDead(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String sessionId,  String model,  List<String> tools)?  sessionInit,TResult Function( String text)?  textChunk,TResult Function( String toolName,  String toolId,  int index)?  toolCall,TResult Function( String toolId,  String partialInput)?  toolCallUpdate,TResult Function( int index,  String? toolId,  Map<String, dynamic>? input)?  toolCallComplete,TResult Function( String toolUseId,  String content,  bool isError)?  toolResult,TResult Function( String text)?  assistantMessage,TResult Function( String? result,  double? costUsd,  int? durationMs,  int? numTurns)?  taskComplete,TResult Function( String message)?  errorEvent,TResult Function( String status,  int? resetsAt)?  rateLimit,TResult Function( int? exitCode,  List<String> stderrTail)?  sessionDead,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ClaudeEventSessionInit() when sessionInit != null:
return sessionInit(_that.sessionId,_that.model,_that.tools);case ClaudeEventTextChunk() when textChunk != null:
return textChunk(_that.text);case ClaudeEventToolCall() when toolCall != null:
return toolCall(_that.toolName,_that.toolId,_that.index);case ClaudeEventToolCallUpdate() when toolCallUpdate != null:
return toolCallUpdate(_that.toolId,_that.partialInput);case ClaudeEventToolCallComplete() when toolCallComplete != null:
return toolCallComplete(_that.index,_that.toolId,_that.input);case ClaudeEventToolResult() when toolResult != null:
return toolResult(_that.toolUseId,_that.content,_that.isError);case ClaudeEventAssistantMessage() when assistantMessage != null:
return assistantMessage(_that.text);case ClaudeEventTaskComplete() when taskComplete != null:
return taskComplete(_that.result,_that.costUsd,_that.durationMs,_that.numTurns);case ClaudeEventErrorEvent() when errorEvent != null:
return errorEvent(_that.message);case ClaudeEventRateLimit() when rateLimit != null:
return rateLimit(_that.status,_that.resetsAt);case ClaudeEventSessionDead() when sessionDead != null:
return sessionDead(_that.exitCode,_that.stderrTail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String sessionId,  String model,  List<String> tools)  sessionInit,required TResult Function( String text)  textChunk,required TResult Function( String toolName,  String toolId,  int index)  toolCall,required TResult Function( String toolId,  String partialInput)  toolCallUpdate,required TResult Function( int index,  String? toolId,  Map<String, dynamic>? input)  toolCallComplete,required TResult Function( String toolUseId,  String content,  bool isError)  toolResult,required TResult Function( String text)  assistantMessage,required TResult Function( String? result,  double? costUsd,  int? durationMs,  int? numTurns)  taskComplete,required TResult Function( String message)  errorEvent,required TResult Function( String status,  int? resetsAt)  rateLimit,required TResult Function( int? exitCode,  List<String> stderrTail)  sessionDead,}) {final _that = this;
switch (_that) {
case ClaudeEventSessionInit():
return sessionInit(_that.sessionId,_that.model,_that.tools);case ClaudeEventTextChunk():
return textChunk(_that.text);case ClaudeEventToolCall():
return toolCall(_that.toolName,_that.toolId,_that.index);case ClaudeEventToolCallUpdate():
return toolCallUpdate(_that.toolId,_that.partialInput);case ClaudeEventToolCallComplete():
return toolCallComplete(_that.index,_that.toolId,_that.input);case ClaudeEventToolResult():
return toolResult(_that.toolUseId,_that.content,_that.isError);case ClaudeEventAssistantMessage():
return assistantMessage(_that.text);case ClaudeEventTaskComplete():
return taskComplete(_that.result,_that.costUsd,_that.durationMs,_that.numTurns);case ClaudeEventErrorEvent():
return errorEvent(_that.message);case ClaudeEventRateLimit():
return rateLimit(_that.status,_that.resetsAt);case ClaudeEventSessionDead():
return sessionDead(_that.exitCode,_that.stderrTail);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String sessionId,  String model,  List<String> tools)?  sessionInit,TResult? Function( String text)?  textChunk,TResult? Function( String toolName,  String toolId,  int index)?  toolCall,TResult? Function( String toolId,  String partialInput)?  toolCallUpdate,TResult? Function( int index,  String? toolId,  Map<String, dynamic>? input)?  toolCallComplete,TResult? Function( String toolUseId,  String content,  bool isError)?  toolResult,TResult? Function( String text)?  assistantMessage,TResult? Function( String? result,  double? costUsd,  int? durationMs,  int? numTurns)?  taskComplete,TResult? Function( String message)?  errorEvent,TResult? Function( String status,  int? resetsAt)?  rateLimit,TResult? Function( int? exitCode,  List<String> stderrTail)?  sessionDead,}) {final _that = this;
switch (_that) {
case ClaudeEventSessionInit() when sessionInit != null:
return sessionInit(_that.sessionId,_that.model,_that.tools);case ClaudeEventTextChunk() when textChunk != null:
return textChunk(_that.text);case ClaudeEventToolCall() when toolCall != null:
return toolCall(_that.toolName,_that.toolId,_that.index);case ClaudeEventToolCallUpdate() when toolCallUpdate != null:
return toolCallUpdate(_that.toolId,_that.partialInput);case ClaudeEventToolCallComplete() when toolCallComplete != null:
return toolCallComplete(_that.index,_that.toolId,_that.input);case ClaudeEventToolResult() when toolResult != null:
return toolResult(_that.toolUseId,_that.content,_that.isError);case ClaudeEventAssistantMessage() when assistantMessage != null:
return assistantMessage(_that.text);case ClaudeEventTaskComplete() when taskComplete != null:
return taskComplete(_that.result,_that.costUsd,_that.durationMs,_that.numTurns);case ClaudeEventErrorEvent() when errorEvent != null:
return errorEvent(_that.message);case ClaudeEventRateLimit() when rateLimit != null:
return rateLimit(_that.status,_that.resetsAt);case ClaudeEventSessionDead() when sessionDead != null:
return sessionDead(_that.exitCode,_that.stderrTail);case _:
  return null;

}
}

}

/// @nodoc


class ClaudeEventSessionInit implements ClaudeEvent {
  const ClaudeEventSessionInit({required this.sessionId, required this.model, final  List<String> tools = const <String>[]}): _tools = tools;
  

 final  String sessionId;
 final  String model;
 final  List<String> _tools;
@JsonKey() List<String> get tools {
  if (_tools is EqualUnmodifiableListView) return _tools;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tools);
}


/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeEventSessionInitCopyWith<ClaudeEventSessionInit> get copyWith => _$ClaudeEventSessionInitCopyWithImpl<ClaudeEventSessionInit>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeEventSessionInit&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.model, model) || other.model == model)&&const DeepCollectionEquality().equals(other._tools, _tools));
}


@override
int get hashCode => Object.hash(runtimeType,sessionId,model,const DeepCollectionEquality().hash(_tools));

@override
String toString() {
  return 'ClaudeEvent.sessionInit(sessionId: $sessionId, model: $model, tools: $tools)';
}


}

/// @nodoc
abstract mixin class $ClaudeEventSessionInitCopyWith<$Res> implements $ClaudeEventCopyWith<$Res> {
  factory $ClaudeEventSessionInitCopyWith(ClaudeEventSessionInit value, $Res Function(ClaudeEventSessionInit) _then) = _$ClaudeEventSessionInitCopyWithImpl;
@useResult
$Res call({
 String sessionId, String model, List<String> tools
});




}
/// @nodoc
class _$ClaudeEventSessionInitCopyWithImpl<$Res>
    implements $ClaudeEventSessionInitCopyWith<$Res> {
  _$ClaudeEventSessionInitCopyWithImpl(this._self, this._then);

  final ClaudeEventSessionInit _self;
  final $Res Function(ClaudeEventSessionInit) _then;

/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? model = null,Object? tools = null,}) {
  return _then(ClaudeEventSessionInit(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,tools: null == tools ? _self._tools : tools // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class ClaudeEventTextChunk implements ClaudeEvent {
  const ClaudeEventTextChunk({required this.text});
  

 final  String text;

/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeEventTextChunkCopyWith<ClaudeEventTextChunk> get copyWith => _$ClaudeEventTextChunkCopyWithImpl<ClaudeEventTextChunk>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeEventTextChunk&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,text);

@override
String toString() {
  return 'ClaudeEvent.textChunk(text: $text)';
}


}

/// @nodoc
abstract mixin class $ClaudeEventTextChunkCopyWith<$Res> implements $ClaudeEventCopyWith<$Res> {
  factory $ClaudeEventTextChunkCopyWith(ClaudeEventTextChunk value, $Res Function(ClaudeEventTextChunk) _then) = _$ClaudeEventTextChunkCopyWithImpl;
@useResult
$Res call({
 String text
});




}
/// @nodoc
class _$ClaudeEventTextChunkCopyWithImpl<$Res>
    implements $ClaudeEventTextChunkCopyWith<$Res> {
  _$ClaudeEventTextChunkCopyWithImpl(this._self, this._then);

  final ClaudeEventTextChunk _self;
  final $Res Function(ClaudeEventTextChunk) _then;

/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? text = null,}) {
  return _then(ClaudeEventTextChunk(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ClaudeEventToolCall implements ClaudeEvent {
  const ClaudeEventToolCall({required this.toolName, required this.toolId, required this.index});
  

 final  String toolName;
 final  String toolId;
 final  int index;

/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeEventToolCallCopyWith<ClaudeEventToolCall> get copyWith => _$ClaudeEventToolCallCopyWithImpl<ClaudeEventToolCall>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeEventToolCall&&(identical(other.toolName, toolName) || other.toolName == toolName)&&(identical(other.toolId, toolId) || other.toolId == toolId)&&(identical(other.index, index) || other.index == index));
}


@override
int get hashCode => Object.hash(runtimeType,toolName,toolId,index);

@override
String toString() {
  return 'ClaudeEvent.toolCall(toolName: $toolName, toolId: $toolId, index: $index)';
}


}

/// @nodoc
abstract mixin class $ClaudeEventToolCallCopyWith<$Res> implements $ClaudeEventCopyWith<$Res> {
  factory $ClaudeEventToolCallCopyWith(ClaudeEventToolCall value, $Res Function(ClaudeEventToolCall) _then) = _$ClaudeEventToolCallCopyWithImpl;
@useResult
$Res call({
 String toolName, String toolId, int index
});




}
/// @nodoc
class _$ClaudeEventToolCallCopyWithImpl<$Res>
    implements $ClaudeEventToolCallCopyWith<$Res> {
  _$ClaudeEventToolCallCopyWithImpl(this._self, this._then);

  final ClaudeEventToolCall _self;
  final $Res Function(ClaudeEventToolCall) _then;

/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? toolName = null,Object? toolId = null,Object? index = null,}) {
  return _then(ClaudeEventToolCall(
toolName: null == toolName ? _self.toolName : toolName // ignore: cast_nullable_to_non_nullable
as String,toolId: null == toolId ? _self.toolId : toolId // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ClaudeEventToolCallUpdate implements ClaudeEvent {
  const ClaudeEventToolCallUpdate({required this.toolId, required this.partialInput});
  

 final  String toolId;
 final  String partialInput;

/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeEventToolCallUpdateCopyWith<ClaudeEventToolCallUpdate> get copyWith => _$ClaudeEventToolCallUpdateCopyWithImpl<ClaudeEventToolCallUpdate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeEventToolCallUpdate&&(identical(other.toolId, toolId) || other.toolId == toolId)&&(identical(other.partialInput, partialInput) || other.partialInput == partialInput));
}


@override
int get hashCode => Object.hash(runtimeType,toolId,partialInput);

@override
String toString() {
  return 'ClaudeEvent.toolCallUpdate(toolId: $toolId, partialInput: $partialInput)';
}


}

/// @nodoc
abstract mixin class $ClaudeEventToolCallUpdateCopyWith<$Res> implements $ClaudeEventCopyWith<$Res> {
  factory $ClaudeEventToolCallUpdateCopyWith(ClaudeEventToolCallUpdate value, $Res Function(ClaudeEventToolCallUpdate) _then) = _$ClaudeEventToolCallUpdateCopyWithImpl;
@useResult
$Res call({
 String toolId, String partialInput
});




}
/// @nodoc
class _$ClaudeEventToolCallUpdateCopyWithImpl<$Res>
    implements $ClaudeEventToolCallUpdateCopyWith<$Res> {
  _$ClaudeEventToolCallUpdateCopyWithImpl(this._self, this._then);

  final ClaudeEventToolCallUpdate _self;
  final $Res Function(ClaudeEventToolCallUpdate) _then;

/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? toolId = null,Object? partialInput = null,}) {
  return _then(ClaudeEventToolCallUpdate(
toolId: null == toolId ? _self.toolId : toolId // ignore: cast_nullable_to_non_nullable
as String,partialInput: null == partialInput ? _self.partialInput : partialInput // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ClaudeEventToolCallComplete implements ClaudeEvent {
  const ClaudeEventToolCallComplete({required this.index, this.toolId, final  Map<String, dynamic>? input}): _input = input;
  

 final  int index;
 final  String? toolId;
 final  Map<String, dynamic>? _input;
 Map<String, dynamic>? get input {
  final value = _input;
  if (value == null) return null;
  if (_input is EqualUnmodifiableMapView) return _input;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeEventToolCallCompleteCopyWith<ClaudeEventToolCallComplete> get copyWith => _$ClaudeEventToolCallCompleteCopyWithImpl<ClaudeEventToolCallComplete>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeEventToolCallComplete&&(identical(other.index, index) || other.index == index)&&(identical(other.toolId, toolId) || other.toolId == toolId)&&const DeepCollectionEquality().equals(other._input, _input));
}


@override
int get hashCode => Object.hash(runtimeType,index,toolId,const DeepCollectionEquality().hash(_input));

@override
String toString() {
  return 'ClaudeEvent.toolCallComplete(index: $index, toolId: $toolId, input: $input)';
}


}

/// @nodoc
abstract mixin class $ClaudeEventToolCallCompleteCopyWith<$Res> implements $ClaudeEventCopyWith<$Res> {
  factory $ClaudeEventToolCallCompleteCopyWith(ClaudeEventToolCallComplete value, $Res Function(ClaudeEventToolCallComplete) _then) = _$ClaudeEventToolCallCompleteCopyWithImpl;
@useResult
$Res call({
 int index, String? toolId, Map<String, dynamic>? input
});




}
/// @nodoc
class _$ClaudeEventToolCallCompleteCopyWithImpl<$Res>
    implements $ClaudeEventToolCallCompleteCopyWith<$Res> {
  _$ClaudeEventToolCallCompleteCopyWithImpl(this._self, this._then);

  final ClaudeEventToolCallComplete _self;
  final $Res Function(ClaudeEventToolCallComplete) _then;

/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? index = null,Object? toolId = freezed,Object? input = freezed,}) {
  return _then(ClaudeEventToolCallComplete(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,toolId: freezed == toolId ? _self.toolId : toolId // ignore: cast_nullable_to_non_nullable
as String?,input: freezed == input ? _self._input : input // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

/// @nodoc


class ClaudeEventToolResult implements ClaudeEvent {
  const ClaudeEventToolResult({required this.toolUseId, required this.content, this.isError = false});
  

 final  String toolUseId;
 final  String content;
@JsonKey() final  bool isError;

/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeEventToolResultCopyWith<ClaudeEventToolResult> get copyWith => _$ClaudeEventToolResultCopyWithImpl<ClaudeEventToolResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeEventToolResult&&(identical(other.toolUseId, toolUseId) || other.toolUseId == toolUseId)&&(identical(other.content, content) || other.content == content)&&(identical(other.isError, isError) || other.isError == isError));
}


@override
int get hashCode => Object.hash(runtimeType,toolUseId,content,isError);

@override
String toString() {
  return 'ClaudeEvent.toolResult(toolUseId: $toolUseId, content: $content, isError: $isError)';
}


}

/// @nodoc
abstract mixin class $ClaudeEventToolResultCopyWith<$Res> implements $ClaudeEventCopyWith<$Res> {
  factory $ClaudeEventToolResultCopyWith(ClaudeEventToolResult value, $Res Function(ClaudeEventToolResult) _then) = _$ClaudeEventToolResultCopyWithImpl;
@useResult
$Res call({
 String toolUseId, String content, bool isError
});




}
/// @nodoc
class _$ClaudeEventToolResultCopyWithImpl<$Res>
    implements $ClaudeEventToolResultCopyWith<$Res> {
  _$ClaudeEventToolResultCopyWithImpl(this._self, this._then);

  final ClaudeEventToolResult _self;
  final $Res Function(ClaudeEventToolResult) _then;

/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? toolUseId = null,Object? content = null,Object? isError = null,}) {
  return _then(ClaudeEventToolResult(
toolUseId: null == toolUseId ? _self.toolUseId : toolUseId // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,isError: null == isError ? _self.isError : isError // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class ClaudeEventAssistantMessage implements ClaudeEvent {
  const ClaudeEventAssistantMessage({required this.text});
  

 final  String text;

/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeEventAssistantMessageCopyWith<ClaudeEventAssistantMessage> get copyWith => _$ClaudeEventAssistantMessageCopyWithImpl<ClaudeEventAssistantMessage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeEventAssistantMessage&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,text);

@override
String toString() {
  return 'ClaudeEvent.assistantMessage(text: $text)';
}


}

/// @nodoc
abstract mixin class $ClaudeEventAssistantMessageCopyWith<$Res> implements $ClaudeEventCopyWith<$Res> {
  factory $ClaudeEventAssistantMessageCopyWith(ClaudeEventAssistantMessage value, $Res Function(ClaudeEventAssistantMessage) _then) = _$ClaudeEventAssistantMessageCopyWithImpl;
@useResult
$Res call({
 String text
});




}
/// @nodoc
class _$ClaudeEventAssistantMessageCopyWithImpl<$Res>
    implements $ClaudeEventAssistantMessageCopyWith<$Res> {
  _$ClaudeEventAssistantMessageCopyWithImpl(this._self, this._then);

  final ClaudeEventAssistantMessage _self;
  final $Res Function(ClaudeEventAssistantMessage) _then;

/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? text = null,}) {
  return _then(ClaudeEventAssistantMessage(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ClaudeEventTaskComplete implements ClaudeEvent {
  const ClaudeEventTaskComplete({this.result, this.costUsd, this.durationMs, this.numTurns});
  

 final  String? result;
 final  double? costUsd;
 final  int? durationMs;
 final  int? numTurns;

/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeEventTaskCompleteCopyWith<ClaudeEventTaskComplete> get copyWith => _$ClaudeEventTaskCompleteCopyWithImpl<ClaudeEventTaskComplete>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeEventTaskComplete&&(identical(other.result, result) || other.result == result)&&(identical(other.costUsd, costUsd) || other.costUsd == costUsd)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.numTurns, numTurns) || other.numTurns == numTurns));
}


@override
int get hashCode => Object.hash(runtimeType,result,costUsd,durationMs,numTurns);

@override
String toString() {
  return 'ClaudeEvent.taskComplete(result: $result, costUsd: $costUsd, durationMs: $durationMs, numTurns: $numTurns)';
}


}

/// @nodoc
abstract mixin class $ClaudeEventTaskCompleteCopyWith<$Res> implements $ClaudeEventCopyWith<$Res> {
  factory $ClaudeEventTaskCompleteCopyWith(ClaudeEventTaskComplete value, $Res Function(ClaudeEventTaskComplete) _then) = _$ClaudeEventTaskCompleteCopyWithImpl;
@useResult
$Res call({
 String? result, double? costUsd, int? durationMs, int? numTurns
});




}
/// @nodoc
class _$ClaudeEventTaskCompleteCopyWithImpl<$Res>
    implements $ClaudeEventTaskCompleteCopyWith<$Res> {
  _$ClaudeEventTaskCompleteCopyWithImpl(this._self, this._then);

  final ClaudeEventTaskComplete _self;
  final $Res Function(ClaudeEventTaskComplete) _then;

/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? result = freezed,Object? costUsd = freezed,Object? durationMs = freezed,Object? numTurns = freezed,}) {
  return _then(ClaudeEventTaskComplete(
result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as String?,costUsd: freezed == costUsd ? _self.costUsd : costUsd // ignore: cast_nullable_to_non_nullable
as double?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,numTurns: freezed == numTurns ? _self.numTurns : numTurns // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class ClaudeEventErrorEvent implements ClaudeEvent {
  const ClaudeEventErrorEvent({required this.message});
  

 final  String message;

/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeEventErrorEventCopyWith<ClaudeEventErrorEvent> get copyWith => _$ClaudeEventErrorEventCopyWithImpl<ClaudeEventErrorEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeEventErrorEvent&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ClaudeEvent.errorEvent(message: $message)';
}


}

/// @nodoc
abstract mixin class $ClaudeEventErrorEventCopyWith<$Res> implements $ClaudeEventCopyWith<$Res> {
  factory $ClaudeEventErrorEventCopyWith(ClaudeEventErrorEvent value, $Res Function(ClaudeEventErrorEvent) _then) = _$ClaudeEventErrorEventCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ClaudeEventErrorEventCopyWithImpl<$Res>
    implements $ClaudeEventErrorEventCopyWith<$Res> {
  _$ClaudeEventErrorEventCopyWithImpl(this._self, this._then);

  final ClaudeEventErrorEvent _self;
  final $Res Function(ClaudeEventErrorEvent) _then;

/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ClaudeEventErrorEvent(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ClaudeEventRateLimit implements ClaudeEvent {
  const ClaudeEventRateLimit({required this.status, this.resetsAt});
  

 final  String status;
 final  int? resetsAt;

/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeEventRateLimitCopyWith<ClaudeEventRateLimit> get copyWith => _$ClaudeEventRateLimitCopyWithImpl<ClaudeEventRateLimit>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeEventRateLimit&&(identical(other.status, status) || other.status == status)&&(identical(other.resetsAt, resetsAt) || other.resetsAt == resetsAt));
}


@override
int get hashCode => Object.hash(runtimeType,status,resetsAt);

@override
String toString() {
  return 'ClaudeEvent.rateLimit(status: $status, resetsAt: $resetsAt)';
}


}

/// @nodoc
abstract mixin class $ClaudeEventRateLimitCopyWith<$Res> implements $ClaudeEventCopyWith<$Res> {
  factory $ClaudeEventRateLimitCopyWith(ClaudeEventRateLimit value, $Res Function(ClaudeEventRateLimit) _then) = _$ClaudeEventRateLimitCopyWithImpl;
@useResult
$Res call({
 String status, int? resetsAt
});




}
/// @nodoc
class _$ClaudeEventRateLimitCopyWithImpl<$Res>
    implements $ClaudeEventRateLimitCopyWith<$Res> {
  _$ClaudeEventRateLimitCopyWithImpl(this._self, this._then);

  final ClaudeEventRateLimit _self;
  final $Res Function(ClaudeEventRateLimit) _then;

/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? status = null,Object? resetsAt = freezed,}) {
  return _then(ClaudeEventRateLimit(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,resetsAt: freezed == resetsAt ? _self.resetsAt : resetsAt // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class ClaudeEventSessionDead implements ClaudeEvent {
  const ClaudeEventSessionDead({this.exitCode, final  List<String> stderrTail = const <String>[]}): _stderrTail = stderrTail;
  

 final  int? exitCode;
 final  List<String> _stderrTail;
@JsonKey() List<String> get stderrTail {
  if (_stderrTail is EqualUnmodifiableListView) return _stderrTail;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stderrTail);
}


/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeEventSessionDeadCopyWith<ClaudeEventSessionDead> get copyWith => _$ClaudeEventSessionDeadCopyWithImpl<ClaudeEventSessionDead>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeEventSessionDead&&(identical(other.exitCode, exitCode) || other.exitCode == exitCode)&&const DeepCollectionEquality().equals(other._stderrTail, _stderrTail));
}


@override
int get hashCode => Object.hash(runtimeType,exitCode,const DeepCollectionEquality().hash(_stderrTail));

@override
String toString() {
  return 'ClaudeEvent.sessionDead(exitCode: $exitCode, stderrTail: $stderrTail)';
}


}

/// @nodoc
abstract mixin class $ClaudeEventSessionDeadCopyWith<$Res> implements $ClaudeEventCopyWith<$Res> {
  factory $ClaudeEventSessionDeadCopyWith(ClaudeEventSessionDead value, $Res Function(ClaudeEventSessionDead) _then) = _$ClaudeEventSessionDeadCopyWithImpl;
@useResult
$Res call({
 int? exitCode, List<String> stderrTail
});




}
/// @nodoc
class _$ClaudeEventSessionDeadCopyWithImpl<$Res>
    implements $ClaudeEventSessionDeadCopyWith<$Res> {
  _$ClaudeEventSessionDeadCopyWithImpl(this._self, this._then);

  final ClaudeEventSessionDead _self;
  final $Res Function(ClaudeEventSessionDead) _then;

/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? exitCode = freezed,Object? stderrTail = null,}) {
  return _then(ClaudeEventSessionDead(
exitCode: freezed == exitCode ? _self.exitCode : exitCode // ignore: cast_nullable_to_non_nullable
as int?,stderrTail: null == stderrTail ? _self._stderrTail : stderrTail // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
