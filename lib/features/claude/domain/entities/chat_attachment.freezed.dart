// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_attachment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatAttachment {

 String get path; String get displayName; ChatAttachmentKind get kind; int? get startLine; int? get endLine; String? get snippet;
/// Create a copy of ChatAttachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatAttachmentCopyWith<ChatAttachment> get copyWith => _$ChatAttachmentCopyWithImpl<ChatAttachment>(this as ChatAttachment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatAttachment&&(identical(other.path, path) || other.path == path)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.startLine, startLine) || other.startLine == startLine)&&(identical(other.endLine, endLine) || other.endLine == endLine)&&(identical(other.snippet, snippet) || other.snippet == snippet));
}


@override
int get hashCode => Object.hash(runtimeType,path,displayName,kind,startLine,endLine,snippet);

@override
String toString() {
  return 'ChatAttachment(path: $path, displayName: $displayName, kind: $kind, startLine: $startLine, endLine: $endLine, snippet: $snippet)';
}


}

/// @nodoc
abstract mixin class $ChatAttachmentCopyWith<$Res>  {
  factory $ChatAttachmentCopyWith(ChatAttachment value, $Res Function(ChatAttachment) _then) = _$ChatAttachmentCopyWithImpl;
@useResult
$Res call({
 String path, String displayName, ChatAttachmentKind kind, int? startLine, int? endLine, String? snippet
});




}
/// @nodoc
class _$ChatAttachmentCopyWithImpl<$Res>
    implements $ChatAttachmentCopyWith<$Res> {
  _$ChatAttachmentCopyWithImpl(this._self, this._then);

  final ChatAttachment _self;
  final $Res Function(ChatAttachment) _then;

/// Create a copy of ChatAttachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? displayName = null,Object? kind = null,Object? startLine = freezed,Object? endLine = freezed,Object? snippet = freezed,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ChatAttachmentKind,startLine: freezed == startLine ? _self.startLine : startLine // ignore: cast_nullable_to_non_nullable
as int?,endLine: freezed == endLine ? _self.endLine : endLine // ignore: cast_nullable_to_non_nullable
as int?,snippet: freezed == snippet ? _self.snippet : snippet // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatAttachment].
extension ChatAttachmentPatterns on ChatAttachment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatAttachment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatAttachment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatAttachment value)  $default,){
final _that = this;
switch (_that) {
case _ChatAttachment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatAttachment value)?  $default,){
final _that = this;
switch (_that) {
case _ChatAttachment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  String displayName,  ChatAttachmentKind kind,  int? startLine,  int? endLine,  String? snippet)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatAttachment() when $default != null:
return $default(_that.path,_that.displayName,_that.kind,_that.startLine,_that.endLine,_that.snippet);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  String displayName,  ChatAttachmentKind kind,  int? startLine,  int? endLine,  String? snippet)  $default,) {final _that = this;
switch (_that) {
case _ChatAttachment():
return $default(_that.path,_that.displayName,_that.kind,_that.startLine,_that.endLine,_that.snippet);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  String displayName,  ChatAttachmentKind kind,  int? startLine,  int? endLine,  String? snippet)?  $default,) {final _that = this;
switch (_that) {
case _ChatAttachment() when $default != null:
return $default(_that.path,_that.displayName,_that.kind,_that.startLine,_that.endLine,_that.snippet);case _:
  return null;

}
}

}

/// @nodoc


class _ChatAttachment implements ChatAttachment {
  const _ChatAttachment({required this.path, required this.displayName, required this.kind, this.startLine, this.endLine, this.snippet});
  

@override final  String path;
@override final  String displayName;
@override final  ChatAttachmentKind kind;
@override final  int? startLine;
@override final  int? endLine;
@override final  String? snippet;

/// Create a copy of ChatAttachment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatAttachmentCopyWith<_ChatAttachment> get copyWith => __$ChatAttachmentCopyWithImpl<_ChatAttachment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatAttachment&&(identical(other.path, path) || other.path == path)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.startLine, startLine) || other.startLine == startLine)&&(identical(other.endLine, endLine) || other.endLine == endLine)&&(identical(other.snippet, snippet) || other.snippet == snippet));
}


@override
int get hashCode => Object.hash(runtimeType,path,displayName,kind,startLine,endLine,snippet);

@override
String toString() {
  return 'ChatAttachment(path: $path, displayName: $displayName, kind: $kind, startLine: $startLine, endLine: $endLine, snippet: $snippet)';
}


}

/// @nodoc
abstract mixin class _$ChatAttachmentCopyWith<$Res> implements $ChatAttachmentCopyWith<$Res> {
  factory _$ChatAttachmentCopyWith(_ChatAttachment value, $Res Function(_ChatAttachment) _then) = __$ChatAttachmentCopyWithImpl;
@override @useResult
$Res call({
 String path, String displayName, ChatAttachmentKind kind, int? startLine, int? endLine, String? snippet
});




}
/// @nodoc
class __$ChatAttachmentCopyWithImpl<$Res>
    implements _$ChatAttachmentCopyWith<$Res> {
  __$ChatAttachmentCopyWithImpl(this._self, this._then);

  final _ChatAttachment _self;
  final $Res Function(_ChatAttachment) _then;

/// Create a copy of ChatAttachment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? displayName = null,Object? kind = null,Object? startLine = freezed,Object? endLine = freezed,Object? snippet = freezed,}) {
  return _then(_ChatAttachment(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ChatAttachmentKind,startLine: freezed == startLine ? _self.startLine : startLine // ignore: cast_nullable_to_non_nullable
as int?,endLine: freezed == endLine ? _self.endLine : endLine // ignore: cast_nullable_to_non_nullable
as int?,snippet: freezed == snippet ? _self.snippet : snippet // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
