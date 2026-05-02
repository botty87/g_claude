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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ClaudeMessageUser value)?  user,TResult Function( ClaudeMessageAssistant value)?  assistant,TResult Function( ClaudeMessageTool value)?  tool,TResult Function( ClaudeMessageSystem value)?  system,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ClaudeMessageUser() when user != null:
return user(_that);case ClaudeMessageAssistant() when assistant != null:
return assistant(_that);case ClaudeMessageTool() when tool != null:
return tool(_that);case ClaudeMessageSystem() when system != null:
return system(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ClaudeMessageUser value)  user,required TResult Function( ClaudeMessageAssistant value)  assistant,required TResult Function( ClaudeMessageTool value)  tool,required TResult Function( ClaudeMessageSystem value)  system,}){
final _that = this;
switch (_that) {
case ClaudeMessageUser():
return user(_that);case ClaudeMessageAssistant():
return assistant(_that);case ClaudeMessageTool():
return tool(_that);case ClaudeMessageSystem():
return system(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ClaudeMessageUser value)?  user,TResult? Function( ClaudeMessageAssistant value)?  assistant,TResult? Function( ClaudeMessageTool value)?  tool,TResult? Function( ClaudeMessageSystem value)?  system,}){
final _that = this;
switch (_that) {
case ClaudeMessageUser() when user != null:
return user(_that);case ClaudeMessageAssistant() when assistant != null:
return assistant(_that);case ClaudeMessageTool() when tool != null:
return tool(_that);case ClaudeMessageSystem() when system != null:
return system(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id,  String text,  DateTime createdAt)?  user,TResult Function( String id,  String text,  bool isStreaming,  DateTime createdAt)?  assistant,TResult Function( String id,  String toolName,  ClaudeToolStatus status,  DateTime createdAt,  String? toolUseId,  Map<String, dynamic>? input,  String? output,  bool isError)?  tool,TResult Function( String id,  String text,  DateTime createdAt)?  system,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ClaudeMessageUser() when user != null:
return user(_that.id,_that.text,_that.createdAt);case ClaudeMessageAssistant() when assistant != null:
return assistant(_that.id,_that.text,_that.isStreaming,_that.createdAt);case ClaudeMessageTool() when tool != null:
return tool(_that.id,_that.toolName,_that.status,_that.createdAt,_that.toolUseId,_that.input,_that.output,_that.isError);case ClaudeMessageSystem() when system != null:
return system(_that.id,_that.text,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id,  String text,  DateTime createdAt)  user,required TResult Function( String id,  String text,  bool isStreaming,  DateTime createdAt)  assistant,required TResult Function( String id,  String toolName,  ClaudeToolStatus status,  DateTime createdAt,  String? toolUseId,  Map<String, dynamic>? input,  String? output,  bool isError)  tool,required TResult Function( String id,  String text,  DateTime createdAt)  system,}) {final _that = this;
switch (_that) {
case ClaudeMessageUser():
return user(_that.id,_that.text,_that.createdAt);case ClaudeMessageAssistant():
return assistant(_that.id,_that.text,_that.isStreaming,_that.createdAt);case ClaudeMessageTool():
return tool(_that.id,_that.toolName,_that.status,_that.createdAt,_that.toolUseId,_that.input,_that.output,_that.isError);case ClaudeMessageSystem():
return system(_that.id,_that.text,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id,  String text,  DateTime createdAt)?  user,TResult? Function( String id,  String text,  bool isStreaming,  DateTime createdAt)?  assistant,TResult? Function( String id,  String toolName,  ClaudeToolStatus status,  DateTime createdAt,  String? toolUseId,  Map<String, dynamic>? input,  String? output,  bool isError)?  tool,TResult? Function( String id,  String text,  DateTime createdAt)?  system,}) {final _that = this;
switch (_that) {
case ClaudeMessageUser() when user != null:
return user(_that.id,_that.text,_that.createdAt);case ClaudeMessageAssistant() when assistant != null:
return assistant(_that.id,_that.text,_that.isStreaming,_that.createdAt);case ClaudeMessageTool() when tool != null:
return tool(_that.id,_that.toolName,_that.status,_that.createdAt,_that.toolUseId,_that.input,_that.output,_that.isError);case ClaudeMessageSystem() when system != null:
return system(_that.id,_that.text,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class ClaudeMessageUser extends ClaudeMessage {
  const ClaudeMessageUser({required this.id, required this.text, required this.createdAt}): super._();
  

@override final  String id;
 final  String text;
@override final  DateTime createdAt;

/// Create a copy of ClaudeMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeMessageUserCopyWith<ClaudeMessageUser> get copyWith => _$ClaudeMessageUserCopyWithImpl<ClaudeMessageUser>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeMessageUser&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,text,createdAt);

@override
String toString() {
  return 'ClaudeMessage.user(id: $id, text: $text, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ClaudeMessageUserCopyWith<$Res> implements $ClaudeMessageCopyWith<$Res> {
  factory $ClaudeMessageUserCopyWith(ClaudeMessageUser value, $Res Function(ClaudeMessageUser) _then) = _$ClaudeMessageUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String text, DateTime createdAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? createdAt = null,}) {
  return _then(ClaudeMessageUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
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

// dart format on
