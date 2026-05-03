// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_session_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatSessionSummary {

 String get id; WorkspaceId get workspaceId; String get encodedPath; String get title; DateTime get firstMessageAt; DateTime get lastMessageAt; int get messageCount;
/// Create a copy of ChatSessionSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatSessionSummaryCopyWith<ChatSessionSummary> get copyWith => _$ChatSessionSummaryCopyWithImpl<ChatSessionSummary>(this as ChatSessionSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatSessionSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.workspaceId, workspaceId) || other.workspaceId == workspaceId)&&(identical(other.encodedPath, encodedPath) || other.encodedPath == encodedPath)&&(identical(other.title, title) || other.title == title)&&(identical(other.firstMessageAt, firstMessageAt) || other.firstMessageAt == firstMessageAt)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.messageCount, messageCount) || other.messageCount == messageCount));
}


@override
int get hashCode => Object.hash(runtimeType,id,workspaceId,encodedPath,title,firstMessageAt,lastMessageAt,messageCount);

@override
String toString() {
  return 'ChatSessionSummary(id: $id, workspaceId: $workspaceId, encodedPath: $encodedPath, title: $title, firstMessageAt: $firstMessageAt, lastMessageAt: $lastMessageAt, messageCount: $messageCount)';
}


}

/// @nodoc
abstract mixin class $ChatSessionSummaryCopyWith<$Res>  {
  factory $ChatSessionSummaryCopyWith(ChatSessionSummary value, $Res Function(ChatSessionSummary) _then) = _$ChatSessionSummaryCopyWithImpl;
@useResult
$Res call({
 String id, WorkspaceId workspaceId, String encodedPath, String title, DateTime firstMessageAt, DateTime lastMessageAt, int messageCount
});




}
/// @nodoc
class _$ChatSessionSummaryCopyWithImpl<$Res>
    implements $ChatSessionSummaryCopyWith<$Res> {
  _$ChatSessionSummaryCopyWithImpl(this._self, this._then);

  final ChatSessionSummary _self;
  final $Res Function(ChatSessionSummary) _then;

/// Create a copy of ChatSessionSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? workspaceId = null,Object? encodedPath = null,Object? title = null,Object? firstMessageAt = null,Object? lastMessageAt = null,Object? messageCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workspaceId: null == workspaceId ? _self.workspaceId : workspaceId // ignore: cast_nullable_to_non_nullable
as WorkspaceId,encodedPath: null == encodedPath ? _self.encodedPath : encodedPath // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,firstMessageAt: null == firstMessageAt ? _self.firstMessageAt : firstMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastMessageAt: null == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime,messageCount: null == messageCount ? _self.messageCount : messageCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatSessionSummary].
extension ChatSessionSummaryPatterns on ChatSessionSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatSessionSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatSessionSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatSessionSummary value)  $default,){
final _that = this;
switch (_that) {
case _ChatSessionSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatSessionSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ChatSessionSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  WorkspaceId workspaceId,  String encodedPath,  String title,  DateTime firstMessageAt,  DateTime lastMessageAt,  int messageCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatSessionSummary() when $default != null:
return $default(_that.id,_that.workspaceId,_that.encodedPath,_that.title,_that.firstMessageAt,_that.lastMessageAt,_that.messageCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  WorkspaceId workspaceId,  String encodedPath,  String title,  DateTime firstMessageAt,  DateTime lastMessageAt,  int messageCount)  $default,) {final _that = this;
switch (_that) {
case _ChatSessionSummary():
return $default(_that.id,_that.workspaceId,_that.encodedPath,_that.title,_that.firstMessageAt,_that.lastMessageAt,_that.messageCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  WorkspaceId workspaceId,  String encodedPath,  String title,  DateTime firstMessageAt,  DateTime lastMessageAt,  int messageCount)?  $default,) {final _that = this;
switch (_that) {
case _ChatSessionSummary() when $default != null:
return $default(_that.id,_that.workspaceId,_that.encodedPath,_that.title,_that.firstMessageAt,_that.lastMessageAt,_that.messageCount);case _:
  return null;

}
}

}

/// @nodoc


class _ChatSessionSummary implements ChatSessionSummary {
  const _ChatSessionSummary({required this.id, required this.workspaceId, required this.encodedPath, required this.title, required this.firstMessageAt, required this.lastMessageAt, required this.messageCount});
  

@override final  String id;
@override final  WorkspaceId workspaceId;
@override final  String encodedPath;
@override final  String title;
@override final  DateTime firstMessageAt;
@override final  DateTime lastMessageAt;
@override final  int messageCount;

/// Create a copy of ChatSessionSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatSessionSummaryCopyWith<_ChatSessionSummary> get copyWith => __$ChatSessionSummaryCopyWithImpl<_ChatSessionSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatSessionSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.workspaceId, workspaceId) || other.workspaceId == workspaceId)&&(identical(other.encodedPath, encodedPath) || other.encodedPath == encodedPath)&&(identical(other.title, title) || other.title == title)&&(identical(other.firstMessageAt, firstMessageAt) || other.firstMessageAt == firstMessageAt)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.messageCount, messageCount) || other.messageCount == messageCount));
}


@override
int get hashCode => Object.hash(runtimeType,id,workspaceId,encodedPath,title,firstMessageAt,lastMessageAt,messageCount);

@override
String toString() {
  return 'ChatSessionSummary(id: $id, workspaceId: $workspaceId, encodedPath: $encodedPath, title: $title, firstMessageAt: $firstMessageAt, lastMessageAt: $lastMessageAt, messageCount: $messageCount)';
}


}

/// @nodoc
abstract mixin class _$ChatSessionSummaryCopyWith<$Res> implements $ChatSessionSummaryCopyWith<$Res> {
  factory _$ChatSessionSummaryCopyWith(_ChatSessionSummary value, $Res Function(_ChatSessionSummary) _then) = __$ChatSessionSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, WorkspaceId workspaceId, String encodedPath, String title, DateTime firstMessageAt, DateTime lastMessageAt, int messageCount
});




}
/// @nodoc
class __$ChatSessionSummaryCopyWithImpl<$Res>
    implements _$ChatSessionSummaryCopyWith<$Res> {
  __$ChatSessionSummaryCopyWithImpl(this._self, this._then);

  final _ChatSessionSummary _self;
  final $Res Function(_ChatSessionSummary) _then;

/// Create a copy of ChatSessionSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? workspaceId = null,Object? encodedPath = null,Object? title = null,Object? firstMessageAt = null,Object? lastMessageAt = null,Object? messageCount = null,}) {
  return _then(_ChatSessionSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workspaceId: null == workspaceId ? _self.workspaceId : workspaceId // ignore: cast_nullable_to_non_nullable
as WorkspaceId,encodedPath: null == encodedPath ? _self.encodedPath : encodedPath // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,firstMessageAt: null == firstMessageAt ? _self.firstMessageAt : firstMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastMessageAt: null == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime,messageCount: null == messageCount ? _self.messageCount : messageCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
