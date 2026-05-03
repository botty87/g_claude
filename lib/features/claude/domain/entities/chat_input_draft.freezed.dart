// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_input_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatInputDraft {

 String get text; List<SlashCommand> get selectedCommands; List<ChatAttachment> get attachments;
/// Create a copy of ChatInputDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatInputDraftCopyWith<ChatInputDraft> get copyWith => _$ChatInputDraftCopyWithImpl<ChatInputDraft>(this as ChatInputDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatInputDraft&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.selectedCommands, selectedCommands)&&const DeepCollectionEquality().equals(other.attachments, attachments));
}


@override
int get hashCode => Object.hash(runtimeType,text,const DeepCollectionEquality().hash(selectedCommands),const DeepCollectionEquality().hash(attachments));

@override
String toString() {
  return 'ChatInputDraft(text: $text, selectedCommands: $selectedCommands, attachments: $attachments)';
}


}

/// @nodoc
abstract mixin class $ChatInputDraftCopyWith<$Res>  {
  factory $ChatInputDraftCopyWith(ChatInputDraft value, $Res Function(ChatInputDraft) _then) = _$ChatInputDraftCopyWithImpl;
@useResult
$Res call({
 String text, List<SlashCommand> selectedCommands, List<ChatAttachment> attachments
});




}
/// @nodoc
class _$ChatInputDraftCopyWithImpl<$Res>
    implements $ChatInputDraftCopyWith<$Res> {
  _$ChatInputDraftCopyWithImpl(this._self, this._then);

  final ChatInputDraft _self;
  final $Res Function(ChatInputDraft) _then;

/// Create a copy of ChatInputDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? selectedCommands = null,Object? attachments = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,selectedCommands: null == selectedCommands ? _self.selectedCommands : selectedCommands // ignore: cast_nullable_to_non_nullable
as List<SlashCommand>,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<ChatAttachment>,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatInputDraft].
extension ChatInputDraftPatterns on ChatInputDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatInputDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatInputDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatInputDraft value)  $default,){
final _that = this;
switch (_that) {
case _ChatInputDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatInputDraft value)?  $default,){
final _that = this;
switch (_that) {
case _ChatInputDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  List<SlashCommand> selectedCommands,  List<ChatAttachment> attachments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatInputDraft() when $default != null:
return $default(_that.text,_that.selectedCommands,_that.attachments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  List<SlashCommand> selectedCommands,  List<ChatAttachment> attachments)  $default,) {final _that = this;
switch (_that) {
case _ChatInputDraft():
return $default(_that.text,_that.selectedCommands,_that.attachments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  List<SlashCommand> selectedCommands,  List<ChatAttachment> attachments)?  $default,) {final _that = this;
switch (_that) {
case _ChatInputDraft() when $default != null:
return $default(_that.text,_that.selectedCommands,_that.attachments);case _:
  return null;

}
}

}

/// @nodoc


class _ChatInputDraft implements ChatInputDraft {
  const _ChatInputDraft({this.text = '', final  List<SlashCommand> selectedCommands = const <SlashCommand>[], final  List<ChatAttachment> attachments = const <ChatAttachment>[]}): _selectedCommands = selectedCommands,_attachments = attachments;
  

@override@JsonKey() final  String text;
 final  List<SlashCommand> _selectedCommands;
@override@JsonKey() List<SlashCommand> get selectedCommands {
  if (_selectedCommands is EqualUnmodifiableListView) return _selectedCommands;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedCommands);
}

 final  List<ChatAttachment> _attachments;
@override@JsonKey() List<ChatAttachment> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}


/// Create a copy of ChatInputDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatInputDraftCopyWith<_ChatInputDraft> get copyWith => __$ChatInputDraftCopyWithImpl<_ChatInputDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatInputDraft&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other._selectedCommands, _selectedCommands)&&const DeepCollectionEquality().equals(other._attachments, _attachments));
}


@override
int get hashCode => Object.hash(runtimeType,text,const DeepCollectionEquality().hash(_selectedCommands),const DeepCollectionEquality().hash(_attachments));

@override
String toString() {
  return 'ChatInputDraft(text: $text, selectedCommands: $selectedCommands, attachments: $attachments)';
}


}

/// @nodoc
abstract mixin class _$ChatInputDraftCopyWith<$Res> implements $ChatInputDraftCopyWith<$Res> {
  factory _$ChatInputDraftCopyWith(_ChatInputDraft value, $Res Function(_ChatInputDraft) _then) = __$ChatInputDraftCopyWithImpl;
@override @useResult
$Res call({
 String text, List<SlashCommand> selectedCommands, List<ChatAttachment> attachments
});




}
/// @nodoc
class __$ChatInputDraftCopyWithImpl<$Res>
    implements _$ChatInputDraftCopyWith<$Res> {
  __$ChatInputDraftCopyWithImpl(this._self, this._then);

  final _ChatInputDraft _self;
  final $Res Function(_ChatInputDraft) _then;

/// Create a copy of ChatInputDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? selectedCommands = null,Object? attachments = null,}) {
  return _then(_ChatInputDraft(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,selectedCommands: null == selectedCommands ? _self._selectedCommands : selectedCommands // ignore: cast_nullable_to_non_nullable
as List<SlashCommand>,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<ChatAttachment>,
  ));
}


}

// dart format on
