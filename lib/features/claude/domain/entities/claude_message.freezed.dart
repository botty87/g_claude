// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'claude_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClaudeMessage {

 String get id; DateTime get createdAt;
/// Create a copy of ClaudeMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeMessageCopyWith<ClaudeMessage> get copyWith => _$ClaudeMessageCopyWithImpl<ClaudeMessage>(this as ClaudeMessage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,createdAt);

@override
String toString() {
  return 'ClaudeMessage(id: $id, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ClaudeMessageCopyWith<$Res>  {
  factory $ClaudeMessageCopyWith(ClaudeMessage value, $Res Function(ClaudeMessage) _then) = _$ClaudeMessageCopyWithImpl;
@useResult
$Res call({
 String id, DateTime createdAt
});




}
/// @nodoc
class _$ClaudeMessageCopyWithImpl<$Res>
    implements $ClaudeMessageCopyWith<$Res> {
  _$ClaudeMessageCopyWithImpl(this._self, this._then);

  final ClaudeMessage _self;
  final $Res Function(ClaudeMessage) _then;

/// Create a copy of ClaudeMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ClaudeMessage].
extension ClaudeMessagePatterns on ClaudeMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ClaudeMessageUser value)?  user,TResult Function( ClaudeMessageAssistant value)?  assistant,TResult Function( ClaudeMessageTool value)?  tool,TResult Function( ClaudeMessageSystem value)?  system,TResult Function( ClaudeMessageAskUserQuestion value)?  askUserQuestion,TResult Function( ClaudeMessagePermissionRequest value)?  permissionRequest,TResult Function( ClaudeMessageCompactSummary value)?  compactSummary,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ClaudeMessageUser() when user != null:
return user(_that);case ClaudeMessageAssistant() when assistant != null:
return assistant(_that);case ClaudeMessageTool() when tool != null:
return tool(_that);case ClaudeMessageSystem() when system != null:
return system(_that);case ClaudeMessageAskUserQuestion() when askUserQuestion != null:
return askUserQuestion(_that);case ClaudeMessagePermissionRequest() when permissionRequest != null:
return permissionRequest(_that);case ClaudeMessageCompactSummary() when compactSummary != null:
return compactSummary(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ClaudeMessageUser value)  user,required TResult Function( ClaudeMessageAssistant value)  assistant,required TResult Function( ClaudeMessageTool value)  tool,required TResult Function( ClaudeMessageSystem value)  system,required TResult Function( ClaudeMessageAskUserQuestion value)  askUserQuestion,required TResult Function( ClaudeMessagePermissionRequest value)  permissionRequest,required TResult Function( ClaudeMessageCompactSummary value)  compactSummary,}){
final _that = this;
switch (_that) {
case ClaudeMessageUser():
return user(_that);case ClaudeMessageAssistant():
return assistant(_that);case ClaudeMessageTool():
return tool(_that);case ClaudeMessageSystem():
return system(_that);case ClaudeMessageAskUserQuestion():
return askUserQuestion(_that);case ClaudeMessagePermissionRequest():
return permissionRequest(_that);case ClaudeMessageCompactSummary():
return compactSummary(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ClaudeMessageUser value)?  user,TResult? Function( ClaudeMessageAssistant value)?  assistant,TResult? Function( ClaudeMessageTool value)?  tool,TResult? Function( ClaudeMessageSystem value)?  system,TResult? Function( ClaudeMessageAskUserQuestion value)?  askUserQuestion,TResult? Function( ClaudeMessagePermissionRequest value)?  permissionRequest,TResult? Function( ClaudeMessageCompactSummary value)?  compactSummary,}){
final _that = this;
switch (_that) {
case ClaudeMessageUser() when user != null:
return user(_that);case ClaudeMessageAssistant() when assistant != null:
return assistant(_that);case ClaudeMessageTool() when tool != null:
return tool(_that);case ClaudeMessageSystem() when system != null:
return system(_that);case ClaudeMessageAskUserQuestion() when askUserQuestion != null:
return askUserQuestion(_that);case ClaudeMessagePermissionRequest() when permissionRequest != null:
return permissionRequest(_that);case ClaudeMessageCompactSummary() when compactSummary != null:
return compactSummary(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id,  String text,  DateTime createdAt,  List<String> slashTriggers,  List<ChatAttachment> attachments)?  user,TResult Function( String id,  String text,  bool isStreaming,  DateTime createdAt)?  assistant,TResult Function( String id,  String toolName,  ClaudeToolStatus status,  DateTime createdAt,  String? toolUseId,  Map<String, dynamic>? input,  String? output,  bool isError)?  tool,TResult Function( String id,  String text,  DateTime createdAt)?  system,TResult Function( String id,  String toolUseId,  List<AskUserQuestionItem> questions,  DateTime createdAt,  Map<String, String> answers,  bool answered)?  askUserQuestion,TResult Function( String id,  String requestId,  String toolName,  Map<String, dynamic> toolInput,  DateTime createdAt,  ClaudePermissionDecision? decision,  bool answered)?  permissionRequest,TResult Function( String id,  String summary,  int hiddenMessageCount,  DateTime createdAt,  bool expanded)?  compactSummary,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ClaudeMessageUser() when user != null:
return user(_that.id,_that.text,_that.createdAt,_that.slashTriggers,_that.attachments);case ClaudeMessageAssistant() when assistant != null:
return assistant(_that.id,_that.text,_that.isStreaming,_that.createdAt);case ClaudeMessageTool() when tool != null:
return tool(_that.id,_that.toolName,_that.status,_that.createdAt,_that.toolUseId,_that.input,_that.output,_that.isError);case ClaudeMessageSystem() when system != null:
return system(_that.id,_that.text,_that.createdAt);case ClaudeMessageAskUserQuestion() when askUserQuestion != null:
return askUserQuestion(_that.id,_that.toolUseId,_that.questions,_that.createdAt,_that.answers,_that.answered);case ClaudeMessagePermissionRequest() when permissionRequest != null:
return permissionRequest(_that.id,_that.requestId,_that.toolName,_that.toolInput,_that.createdAt,_that.decision,_that.answered);case ClaudeMessageCompactSummary() when compactSummary != null:
return compactSummary(_that.id,_that.summary,_that.hiddenMessageCount,_that.createdAt,_that.expanded);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id,  String text,  DateTime createdAt,  List<String> slashTriggers,  List<ChatAttachment> attachments)  user,required TResult Function( String id,  String text,  bool isStreaming,  DateTime createdAt)  assistant,required TResult Function( String id,  String toolName,  ClaudeToolStatus status,  DateTime createdAt,  String? toolUseId,  Map<String, dynamic>? input,  String? output,  bool isError)  tool,required TResult Function( String id,  String text,  DateTime createdAt)  system,required TResult Function( String id,  String toolUseId,  List<AskUserQuestionItem> questions,  DateTime createdAt,  Map<String, String> answers,  bool answered)  askUserQuestion,required TResult Function( String id,  String requestId,  String toolName,  Map<String, dynamic> toolInput,  DateTime createdAt,  ClaudePermissionDecision? decision,  bool answered)  permissionRequest,required TResult Function( String id,  String summary,  int hiddenMessageCount,  DateTime createdAt,  bool expanded)  compactSummary,}) {final _that = this;
switch (_that) {
case ClaudeMessageUser():
return user(_that.id,_that.text,_that.createdAt,_that.slashTriggers,_that.attachments);case ClaudeMessageAssistant():
return assistant(_that.id,_that.text,_that.isStreaming,_that.createdAt);case ClaudeMessageTool():
return tool(_that.id,_that.toolName,_that.status,_that.createdAt,_that.toolUseId,_that.input,_that.output,_that.isError);case ClaudeMessageSystem():
return system(_that.id,_that.text,_that.createdAt);case ClaudeMessageAskUserQuestion():
return askUserQuestion(_that.id,_that.toolUseId,_that.questions,_that.createdAt,_that.answers,_that.answered);case ClaudeMessagePermissionRequest():
return permissionRequest(_that.id,_that.requestId,_that.toolName,_that.toolInput,_that.createdAt,_that.decision,_that.answered);case ClaudeMessageCompactSummary():
return compactSummary(_that.id,_that.summary,_that.hiddenMessageCount,_that.createdAt,_that.expanded);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id,  String text,  DateTime createdAt,  List<String> slashTriggers,  List<ChatAttachment> attachments)?  user,TResult? Function( String id,  String text,  bool isStreaming,  DateTime createdAt)?  assistant,TResult? Function( String id,  String toolName,  ClaudeToolStatus status,  DateTime createdAt,  String? toolUseId,  Map<String, dynamic>? input,  String? output,  bool isError)?  tool,TResult? Function( String id,  String text,  DateTime createdAt)?  system,TResult? Function( String id,  String toolUseId,  List<AskUserQuestionItem> questions,  DateTime createdAt,  Map<String, String> answers,  bool answered)?  askUserQuestion,TResult? Function( String id,  String requestId,  String toolName,  Map<String, dynamic> toolInput,  DateTime createdAt,  ClaudePermissionDecision? decision,  bool answered)?  permissionRequest,TResult? Function( String id,  String summary,  int hiddenMessageCount,  DateTime createdAt,  bool expanded)?  compactSummary,}) {final _that = this;
switch (_that) {
case ClaudeMessageUser() when user != null:
return user(_that.id,_that.text,_that.createdAt,_that.slashTriggers,_that.attachments);case ClaudeMessageAssistant() when assistant != null:
return assistant(_that.id,_that.text,_that.isStreaming,_that.createdAt);case ClaudeMessageTool() when tool != null:
return tool(_that.id,_that.toolName,_that.status,_that.createdAt,_that.toolUseId,_that.input,_that.output,_that.isError);case ClaudeMessageSystem() when system != null:
return system(_that.id,_that.text,_that.createdAt);case ClaudeMessageAskUserQuestion() when askUserQuestion != null:
return askUserQuestion(_that.id,_that.toolUseId,_that.questions,_that.createdAt,_that.answers,_that.answered);case ClaudeMessagePermissionRequest() when permissionRequest != null:
return permissionRequest(_that.id,_that.requestId,_that.toolName,_that.toolInput,_that.createdAt,_that.decision,_that.answered);case ClaudeMessageCompactSummary() when compactSummary != null:
return compactSummary(_that.id,_that.summary,_that.hiddenMessageCount,_that.createdAt,_that.expanded);case _:
  return null;

}
}

}

/// @nodoc


class ClaudeMessageUser extends ClaudeMessage {
  const ClaudeMessageUser({required this.id, required this.text, required this.createdAt, final  List<String> slashTriggers = const <String>[], final  List<ChatAttachment> attachments = const <ChatAttachment>[]}): _slashTriggers = slashTriggers,_attachments = attachments,super._();
  

@override final  String id;
 final  String text;
@override final  DateTime createdAt;
 final  List<String> _slashTriggers;
@JsonKey() List<String> get slashTriggers {
  if (_slashTriggers is EqualUnmodifiableListView) return _slashTriggers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_slashTriggers);
}

 final  List<ChatAttachment> _attachments;
@JsonKey() List<ChatAttachment> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}


/// Create a copy of ClaudeMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeMessageUserCopyWith<ClaudeMessageUser> get copyWith => _$ClaudeMessageUserCopyWithImpl<ClaudeMessageUser>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeMessageUser&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._slashTriggers, _slashTriggers)&&const DeepCollectionEquality().equals(other._attachments, _attachments));
}


@override
int get hashCode => Object.hash(runtimeType,id,text,createdAt,const DeepCollectionEquality().hash(_slashTriggers),const DeepCollectionEquality().hash(_attachments));

@override
String toString() {
  return 'ClaudeMessage.user(id: $id, text: $text, createdAt: $createdAt, slashTriggers: $slashTriggers, attachments: $attachments)';
}


}

/// @nodoc
abstract mixin class $ClaudeMessageUserCopyWith<$Res> implements $ClaudeMessageCopyWith<$Res> {
  factory $ClaudeMessageUserCopyWith(ClaudeMessageUser value, $Res Function(ClaudeMessageUser) _then) = _$ClaudeMessageUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String text, DateTime createdAt, List<String> slashTriggers, List<ChatAttachment> attachments
});




}
/// @nodoc
class _$ClaudeMessageUserCopyWithImpl<$Res>
    implements $ClaudeMessageUserCopyWith<$Res> {
  _$ClaudeMessageUserCopyWithImpl(this._self, this._then);

  final ClaudeMessageUser _self;
  final $Res Function(ClaudeMessageUser) _then;

/// Create a copy of ClaudeMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? createdAt = null,Object? slashTriggers = null,Object? attachments = null,}) {
  return _then(ClaudeMessageUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,slashTriggers: null == slashTriggers ? _self._slashTriggers : slashTriggers // ignore: cast_nullable_to_non_nullable
as List<String>,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<ChatAttachment>,
  ));
}


}

/// @nodoc


class ClaudeMessageAssistant extends ClaudeMessage {
  const ClaudeMessageAssistant({required this.id, required this.text, this.isStreaming = false, required this.createdAt}): super._();
  

@override final  String id;
 final  String text;
@JsonKey() final  bool isStreaming;
@override final  DateTime createdAt;

/// Create a copy of ClaudeMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeMessageAssistantCopyWith<ClaudeMessageAssistant> get copyWith => _$ClaudeMessageAssistantCopyWithImpl<ClaudeMessageAssistant>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeMessageAssistant&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.isStreaming, isStreaming) || other.isStreaming == isStreaming)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,text,isStreaming,createdAt);

@override
String toString() {
  return 'ClaudeMessage.assistant(id: $id, text: $text, isStreaming: $isStreaming, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ClaudeMessageAssistantCopyWith<$Res> implements $ClaudeMessageCopyWith<$Res> {
  factory $ClaudeMessageAssistantCopyWith(ClaudeMessageAssistant value, $Res Function(ClaudeMessageAssistant) _then) = _$ClaudeMessageAssistantCopyWithImpl;
@override @useResult
$Res call({
 String id, String text, bool isStreaming, DateTime createdAt
});




}
/// @nodoc
class _$ClaudeMessageAssistantCopyWithImpl<$Res>
    implements $ClaudeMessageAssistantCopyWith<$Res> {
  _$ClaudeMessageAssistantCopyWithImpl(this._self, this._then);

  final ClaudeMessageAssistant _self;
  final $Res Function(ClaudeMessageAssistant) _then;

/// Create a copy of ClaudeMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? isStreaming = null,Object? createdAt = null,}) {
  return _then(ClaudeMessageAssistant(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,isStreaming: null == isStreaming ? _self.isStreaming : isStreaming // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class ClaudeMessageTool extends ClaudeMessage {
  const ClaudeMessageTool({required this.id, required this.toolName, required this.status, required this.createdAt, this.toolUseId, final  Map<String, dynamic>? input, this.output, this.isError = false}): _input = input,super._();
  

@override final  String id;
 final  String toolName;
 final  ClaudeToolStatus status;
@override final  DateTime createdAt;
 final  String? toolUseId;
 final  Map<String, dynamic>? _input;
 Map<String, dynamic>? get input {
  final value = _input;
  if (value == null) return null;
  if (_input is EqualUnmodifiableMapView) return _input;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  String? output;
@JsonKey() final  bool isError;

/// Create a copy of ClaudeMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeMessageToolCopyWith<ClaudeMessageTool> get copyWith => _$ClaudeMessageToolCopyWithImpl<ClaudeMessageTool>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeMessageTool&&(identical(other.id, id) || other.id == id)&&(identical(other.toolName, toolName) || other.toolName == toolName)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.toolUseId, toolUseId) || other.toolUseId == toolUseId)&&const DeepCollectionEquality().equals(other._input, _input)&&(identical(other.output, output) || other.output == output)&&(identical(other.isError, isError) || other.isError == isError));
}


@override
int get hashCode => Object.hash(runtimeType,id,toolName,status,createdAt,toolUseId,const DeepCollectionEquality().hash(_input),output,isError);

@override
String toString() {
  return 'ClaudeMessage.tool(id: $id, toolName: $toolName, status: $status, createdAt: $createdAt, toolUseId: $toolUseId, input: $input, output: $output, isError: $isError)';
}


}

/// @nodoc
abstract mixin class $ClaudeMessageToolCopyWith<$Res> implements $ClaudeMessageCopyWith<$Res> {
  factory $ClaudeMessageToolCopyWith(ClaudeMessageTool value, $Res Function(ClaudeMessageTool) _then) = _$ClaudeMessageToolCopyWithImpl;
@override @useResult
$Res call({
 String id, String toolName, ClaudeToolStatus status, DateTime createdAt, String? toolUseId, Map<String, dynamic>? input, String? output, bool isError
});




}
/// @nodoc
class _$ClaudeMessageToolCopyWithImpl<$Res>
    implements $ClaudeMessageToolCopyWith<$Res> {
  _$ClaudeMessageToolCopyWithImpl(this._self, this._then);

  final ClaudeMessageTool _self;
  final $Res Function(ClaudeMessageTool) _then;

/// Create a copy of ClaudeMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? toolName = null,Object? status = null,Object? createdAt = null,Object? toolUseId = freezed,Object? input = freezed,Object? output = freezed,Object? isError = null,}) {
  return _then(ClaudeMessageTool(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,toolName: null == toolName ? _self.toolName : toolName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ClaudeToolStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,toolUseId: freezed == toolUseId ? _self.toolUseId : toolUseId // ignore: cast_nullable_to_non_nullable
as String?,input: freezed == input ? _self._input : input // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,output: freezed == output ? _self.output : output // ignore: cast_nullable_to_non_nullable
as String?,isError: null == isError ? _self.isError : isError // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class ClaudeMessageSystem extends ClaudeMessage {
  const ClaudeMessageSystem({required this.id, required this.text, required this.createdAt}): super._();
  

@override final  String id;
 final  String text;
@override final  DateTime createdAt;

/// Create a copy of ClaudeMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeMessageSystemCopyWith<ClaudeMessageSystem> get copyWith => _$ClaudeMessageSystemCopyWithImpl<ClaudeMessageSystem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeMessageSystem&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,text,createdAt);

@override
String toString() {
  return 'ClaudeMessage.system(id: $id, text: $text, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ClaudeMessageSystemCopyWith<$Res> implements $ClaudeMessageCopyWith<$Res> {
  factory $ClaudeMessageSystemCopyWith(ClaudeMessageSystem value, $Res Function(ClaudeMessageSystem) _then) = _$ClaudeMessageSystemCopyWithImpl;
@override @useResult
$Res call({
 String id, String text, DateTime createdAt
});




}
/// @nodoc
class _$ClaudeMessageSystemCopyWithImpl<$Res>
    implements $ClaudeMessageSystemCopyWith<$Res> {
  _$ClaudeMessageSystemCopyWithImpl(this._self, this._then);

  final ClaudeMessageSystem _self;
  final $Res Function(ClaudeMessageSystem) _then;

/// Create a copy of ClaudeMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? createdAt = null,}) {
  return _then(ClaudeMessageSystem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class ClaudeMessageAskUserQuestion extends ClaudeMessage {
  const ClaudeMessageAskUserQuestion({required this.id, required this.toolUseId, required final  List<AskUserQuestionItem> questions, required this.createdAt, final  Map<String, String> answers = const <String, String>{}, this.answered = false}): _questions = questions,_answers = answers,super._();
  

@override final  String id;
 final  String toolUseId;
 final  List<AskUserQuestionItem> _questions;
 List<AskUserQuestionItem> get questions {
  if (_questions is EqualUnmodifiableListView) return _questions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_questions);
}

@override final  DateTime createdAt;
 final  Map<String, String> _answers;
@JsonKey() Map<String, String> get answers {
  if (_answers is EqualUnmodifiableMapView) return _answers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_answers);
}

@JsonKey() final  bool answered;

/// Create a copy of ClaudeMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeMessageAskUserQuestionCopyWith<ClaudeMessageAskUserQuestion> get copyWith => _$ClaudeMessageAskUserQuestionCopyWithImpl<ClaudeMessageAskUserQuestion>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeMessageAskUserQuestion&&(identical(other.id, id) || other.id == id)&&(identical(other.toolUseId, toolUseId) || other.toolUseId == toolUseId)&&const DeepCollectionEquality().equals(other._questions, _questions)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._answers, _answers)&&(identical(other.answered, answered) || other.answered == answered));
}


@override
int get hashCode => Object.hash(runtimeType,id,toolUseId,const DeepCollectionEquality().hash(_questions),createdAt,const DeepCollectionEquality().hash(_answers),answered);

@override
String toString() {
  return 'ClaudeMessage.askUserQuestion(id: $id, toolUseId: $toolUseId, questions: $questions, createdAt: $createdAt, answers: $answers, answered: $answered)';
}


}

/// @nodoc
abstract mixin class $ClaudeMessageAskUserQuestionCopyWith<$Res> implements $ClaudeMessageCopyWith<$Res> {
  factory $ClaudeMessageAskUserQuestionCopyWith(ClaudeMessageAskUserQuestion value, $Res Function(ClaudeMessageAskUserQuestion) _then) = _$ClaudeMessageAskUserQuestionCopyWithImpl;
@override @useResult
$Res call({
 String id, String toolUseId, List<AskUserQuestionItem> questions, DateTime createdAt, Map<String, String> answers, bool answered
});




}
/// @nodoc
class _$ClaudeMessageAskUserQuestionCopyWithImpl<$Res>
    implements $ClaudeMessageAskUserQuestionCopyWith<$Res> {
  _$ClaudeMessageAskUserQuestionCopyWithImpl(this._self, this._then);

  final ClaudeMessageAskUserQuestion _self;
  final $Res Function(ClaudeMessageAskUserQuestion) _then;

/// Create a copy of ClaudeMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? toolUseId = null,Object? questions = null,Object? createdAt = null,Object? answers = null,Object? answered = null,}) {
  return _then(ClaudeMessageAskUserQuestion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,toolUseId: null == toolUseId ? _self.toolUseId : toolUseId // ignore: cast_nullable_to_non_nullable
as String,questions: null == questions ? _self._questions : questions // ignore: cast_nullable_to_non_nullable
as List<AskUserQuestionItem>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,answers: null == answers ? _self._answers : answers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,answered: null == answered ? _self.answered : answered // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class ClaudeMessagePermissionRequest extends ClaudeMessage {
  const ClaudeMessagePermissionRequest({required this.id, required this.requestId, required this.toolName, required final  Map<String, dynamic> toolInput, required this.createdAt, this.decision, this.answered = false}): _toolInput = toolInput,super._();
  

@override final  String id;
 final  String requestId;
 final  String toolName;
 final  Map<String, dynamic> _toolInput;
 Map<String, dynamic> get toolInput {
  if (_toolInput is EqualUnmodifiableMapView) return _toolInput;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_toolInput);
}

@override final  DateTime createdAt;
 final  ClaudePermissionDecision? decision;
@JsonKey() final  bool answered;

/// Create a copy of ClaudeMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeMessagePermissionRequestCopyWith<ClaudeMessagePermissionRequest> get copyWith => _$ClaudeMessagePermissionRequestCopyWithImpl<ClaudeMessagePermissionRequest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeMessagePermissionRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.toolName, toolName) || other.toolName == toolName)&&const DeepCollectionEquality().equals(other._toolInput, _toolInput)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.decision, decision) || other.decision == decision)&&(identical(other.answered, answered) || other.answered == answered));
}


@override
int get hashCode => Object.hash(runtimeType,id,requestId,toolName,const DeepCollectionEquality().hash(_toolInput),createdAt,decision,answered);

@override
String toString() {
  return 'ClaudeMessage.permissionRequest(id: $id, requestId: $requestId, toolName: $toolName, toolInput: $toolInput, createdAt: $createdAt, decision: $decision, answered: $answered)';
}


}

/// @nodoc
abstract mixin class $ClaudeMessagePermissionRequestCopyWith<$Res> implements $ClaudeMessageCopyWith<$Res> {
  factory $ClaudeMessagePermissionRequestCopyWith(ClaudeMessagePermissionRequest value, $Res Function(ClaudeMessagePermissionRequest) _then) = _$ClaudeMessagePermissionRequestCopyWithImpl;
@override @useResult
$Res call({
 String id, String requestId, String toolName, Map<String, dynamic> toolInput, DateTime createdAt, ClaudePermissionDecision? decision, bool answered
});




}
/// @nodoc
class _$ClaudeMessagePermissionRequestCopyWithImpl<$Res>
    implements $ClaudeMessagePermissionRequestCopyWith<$Res> {
  _$ClaudeMessagePermissionRequestCopyWithImpl(this._self, this._then);

  final ClaudeMessagePermissionRequest _self;
  final $Res Function(ClaudeMessagePermissionRequest) _then;

/// Create a copy of ClaudeMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? requestId = null,Object? toolName = null,Object? toolInput = null,Object? createdAt = null,Object? decision = freezed,Object? answered = null,}) {
  return _then(ClaudeMessagePermissionRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,toolName: null == toolName ? _self.toolName : toolName // ignore: cast_nullable_to_non_nullable
as String,toolInput: null == toolInput ? _self._toolInput : toolInput // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,decision: freezed == decision ? _self.decision : decision // ignore: cast_nullable_to_non_nullable
as ClaudePermissionDecision?,answered: null == answered ? _self.answered : answered // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class ClaudeMessageCompactSummary extends ClaudeMessage {
  const ClaudeMessageCompactSummary({required this.id, required this.summary, required this.hiddenMessageCount, required this.createdAt, this.expanded = false}): super._();


@override final  String id;
 final  String summary;
 final  int hiddenMessageCount;
@override final  DateTime createdAt;
@JsonKey() final  bool expanded;

/// Create a copy of ClaudeMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeMessageCompactSummaryCopyWith<ClaudeMessageCompactSummary> get copyWith => _$ClaudeMessageCompactSummaryCopyWithImpl<ClaudeMessageCompactSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeMessageCompactSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.hiddenMessageCount, hiddenMessageCount) || other.hiddenMessageCount == hiddenMessageCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expanded, expanded) || other.expanded == expanded));
}


@override
int get hashCode => Object.hash(runtimeType,id,summary,hiddenMessageCount,createdAt,expanded);

@override
String toString() {
  return 'ClaudeMessage.compactSummary(id: $id, summary: $summary, hiddenMessageCount: $hiddenMessageCount, createdAt: $createdAt, expanded: $expanded)';
}


}

/// @nodoc
abstract mixin class $ClaudeMessageCompactSummaryCopyWith<$Res> implements $ClaudeMessageCopyWith<$Res> {
  factory $ClaudeMessageCompactSummaryCopyWith(ClaudeMessageCompactSummary value, $Res Function(ClaudeMessageCompactSummary) _then) = _$ClaudeMessageCompactSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String summary, int hiddenMessageCount, DateTime createdAt, bool expanded
});




}
/// @nodoc
class _$ClaudeMessageCompactSummaryCopyWithImpl<$Res>
    implements $ClaudeMessageCompactSummaryCopyWith<$Res> {
  _$ClaudeMessageCompactSummaryCopyWithImpl(this._self, this._then);

  final ClaudeMessageCompactSummary _self;
  final $Res Function(ClaudeMessageCompactSummary) _then;

/// Create a copy of ClaudeMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? summary = null,Object? hiddenMessageCount = null,Object? createdAt = null,Object? expanded = null,}) {
  return _then(ClaudeMessageCompactSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,hiddenMessageCount: null == hiddenMessageCount ? _self.hiddenMessageCount : hiddenMessageCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expanded: null == expanded ? _self.expanded : expanded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
