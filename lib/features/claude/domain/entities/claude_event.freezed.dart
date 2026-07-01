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
mixin _$ClaudePluginInfo {

 String get name; String get path; String? get source;
/// Create a copy of ClaudePluginInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudePluginInfoCopyWith<ClaudePluginInfo> get copyWith => _$ClaudePluginInfoCopyWithImpl<ClaudePluginInfo>(this as ClaudePluginInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudePluginInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.path, path) || other.path == path)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode => Object.hash(runtimeType,name,path,source);

@override
String toString() {
  return 'ClaudePluginInfo(name: $name, path: $path, source: $source)';
}


}

/// @nodoc
abstract mixin class $ClaudePluginInfoCopyWith<$Res>  {
  factory $ClaudePluginInfoCopyWith(ClaudePluginInfo value, $Res Function(ClaudePluginInfo) _then) = _$ClaudePluginInfoCopyWithImpl;
@useResult
$Res call({
 String name, String path, String? source
});




}
/// @nodoc
class _$ClaudePluginInfoCopyWithImpl<$Res>
    implements $ClaudePluginInfoCopyWith<$Res> {
  _$ClaudePluginInfoCopyWithImpl(this._self, this._then);

  final ClaudePluginInfo _self;
  final $Res Function(ClaudePluginInfo) _then;

/// Create a copy of ClaudePluginInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? path = null,Object? source = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClaudePluginInfo].
extension ClaudePluginInfoPatterns on ClaudePluginInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClaudePluginInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClaudePluginInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClaudePluginInfo value)  $default,){
final _that = this;
switch (_that) {
case _ClaudePluginInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClaudePluginInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ClaudePluginInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String path,  String? source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClaudePluginInfo() when $default != null:
return $default(_that.name,_that.path,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String path,  String? source)  $default,) {final _that = this;
switch (_that) {
case _ClaudePluginInfo():
return $default(_that.name,_that.path,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String path,  String? source)?  $default,) {final _that = this;
switch (_that) {
case _ClaudePluginInfo() when $default != null:
return $default(_that.name,_that.path,_that.source);case _:
  return null;

}
}

}

/// @nodoc


class _ClaudePluginInfo implements ClaudePluginInfo {
  const _ClaudePluginInfo({required this.name, required this.path, this.source});
  

@override final  String name;
@override final  String path;
@override final  String? source;

/// Create a copy of ClaudePluginInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClaudePluginInfoCopyWith<_ClaudePluginInfo> get copyWith => __$ClaudePluginInfoCopyWithImpl<_ClaudePluginInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClaudePluginInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.path, path) || other.path == path)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode => Object.hash(runtimeType,name,path,source);

@override
String toString() {
  return 'ClaudePluginInfo(name: $name, path: $path, source: $source)';
}


}

/// @nodoc
abstract mixin class _$ClaudePluginInfoCopyWith<$Res> implements $ClaudePluginInfoCopyWith<$Res> {
  factory _$ClaudePluginInfoCopyWith(_ClaudePluginInfo value, $Res Function(_ClaudePluginInfo) _then) = __$ClaudePluginInfoCopyWithImpl;
@override @useResult
$Res call({
 String name, String path, String? source
});




}
/// @nodoc
class __$ClaudePluginInfoCopyWithImpl<$Res>
    implements _$ClaudePluginInfoCopyWith<$Res> {
  __$ClaudePluginInfoCopyWithImpl(this._self, this._then);

  final _ClaudePluginInfo _self;
  final $Res Function(_ClaudePluginInfo) _then;

/// Create a copy of ClaudePluginInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? path = null,Object? source = freezed,}) {
  return _then(_ClaudePluginInfo(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$AskUserQuestionOption {

 String get label; String get description;
/// Create a copy of AskUserQuestionOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AskUserQuestionOptionCopyWith<AskUserQuestionOption> get copyWith => _$AskUserQuestionOptionCopyWithImpl<AskUserQuestionOption>(this as AskUserQuestionOption, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AskUserQuestionOption&&(identical(other.label, label) || other.label == label)&&(identical(other.description, description) || other.description == description));
}


@override
int get hashCode => Object.hash(runtimeType,label,description);

@override
String toString() {
  return 'AskUserQuestionOption(label: $label, description: $description)';
}


}

/// @nodoc
abstract mixin class $AskUserQuestionOptionCopyWith<$Res>  {
  factory $AskUserQuestionOptionCopyWith(AskUserQuestionOption value, $Res Function(AskUserQuestionOption) _then) = _$AskUserQuestionOptionCopyWithImpl;
@useResult
$Res call({
 String label, String description
});




}
/// @nodoc
class _$AskUserQuestionOptionCopyWithImpl<$Res>
    implements $AskUserQuestionOptionCopyWith<$Res> {
  _$AskUserQuestionOptionCopyWithImpl(this._self, this._then);

  final AskUserQuestionOption _self;
  final $Res Function(AskUserQuestionOption) _then;

/// Create a copy of AskUserQuestionOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? description = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AskUserQuestionOption].
extension AskUserQuestionOptionPatterns on AskUserQuestionOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AskUserQuestionOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AskUserQuestionOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AskUserQuestionOption value)  $default,){
final _that = this;
switch (_that) {
case _AskUserQuestionOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AskUserQuestionOption value)?  $default,){
final _that = this;
switch (_that) {
case _AskUserQuestionOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AskUserQuestionOption() when $default != null:
return $default(_that.label,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  String description)  $default,) {final _that = this;
switch (_that) {
case _AskUserQuestionOption():
return $default(_that.label,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  String description)?  $default,) {final _that = this;
switch (_that) {
case _AskUserQuestionOption() when $default != null:
return $default(_that.label,_that.description);case _:
  return null;

}
}

}

/// @nodoc


class _AskUserQuestionOption implements AskUserQuestionOption {
  const _AskUserQuestionOption({required this.label, this.description = ''});
  

@override final  String label;
@override@JsonKey() final  String description;

/// Create a copy of AskUserQuestionOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AskUserQuestionOptionCopyWith<_AskUserQuestionOption> get copyWith => __$AskUserQuestionOptionCopyWithImpl<_AskUserQuestionOption>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AskUserQuestionOption&&(identical(other.label, label) || other.label == label)&&(identical(other.description, description) || other.description == description));
}


@override
int get hashCode => Object.hash(runtimeType,label,description);

@override
String toString() {
  return 'AskUserQuestionOption(label: $label, description: $description)';
}


}

/// @nodoc
abstract mixin class _$AskUserQuestionOptionCopyWith<$Res> implements $AskUserQuestionOptionCopyWith<$Res> {
  factory _$AskUserQuestionOptionCopyWith(_AskUserQuestionOption value, $Res Function(_AskUserQuestionOption) _then) = __$AskUserQuestionOptionCopyWithImpl;
@override @useResult
$Res call({
 String label, String description
});




}
/// @nodoc
class __$AskUserQuestionOptionCopyWithImpl<$Res>
    implements _$AskUserQuestionOptionCopyWith<$Res> {
  __$AskUserQuestionOptionCopyWithImpl(this._self, this._then);

  final _AskUserQuestionOption _self;
  final $Res Function(_AskUserQuestionOption) _then;

/// Create a copy of AskUserQuestionOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? description = null,}) {
  return _then(_AskUserQuestionOption(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$AskUserQuestionItem {

 String get question; String get header; bool get multiSelect; List<AskUserQuestionOption> get options;
/// Create a copy of AskUserQuestionItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AskUserQuestionItemCopyWith<AskUserQuestionItem> get copyWith => _$AskUserQuestionItemCopyWithImpl<AskUserQuestionItem>(this as AskUserQuestionItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AskUserQuestionItem&&(identical(other.question, question) || other.question == question)&&(identical(other.header, header) || other.header == header)&&(identical(other.multiSelect, multiSelect) || other.multiSelect == multiSelect)&&const DeepCollectionEquality().equals(other.options, options));
}


@override
int get hashCode => Object.hash(runtimeType,question,header,multiSelect,const DeepCollectionEquality().hash(options));

@override
String toString() {
  return 'AskUserQuestionItem(question: $question, header: $header, multiSelect: $multiSelect, options: $options)';
}


}

/// @nodoc
abstract mixin class $AskUserQuestionItemCopyWith<$Res>  {
  factory $AskUserQuestionItemCopyWith(AskUserQuestionItem value, $Res Function(AskUserQuestionItem) _then) = _$AskUserQuestionItemCopyWithImpl;
@useResult
$Res call({
 String question, String header, bool multiSelect, List<AskUserQuestionOption> options
});




}
/// @nodoc
class _$AskUserQuestionItemCopyWithImpl<$Res>
    implements $AskUserQuestionItemCopyWith<$Res> {
  _$AskUserQuestionItemCopyWithImpl(this._self, this._then);

  final AskUserQuestionItem _self;
  final $Res Function(AskUserQuestionItem) _then;

/// Create a copy of AskUserQuestionItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? question = null,Object? header = null,Object? multiSelect = null,Object? options = null,}) {
  return _then(_self.copyWith(
question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,header: null == header ? _self.header : header // ignore: cast_nullable_to_non_nullable
as String,multiSelect: null == multiSelect ? _self.multiSelect : multiSelect // ignore: cast_nullable_to_non_nullable
as bool,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<AskUserQuestionOption>,
  ));
}

}


/// Adds pattern-matching-related methods to [AskUserQuestionItem].
extension AskUserQuestionItemPatterns on AskUserQuestionItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AskUserQuestionItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AskUserQuestionItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AskUserQuestionItem value)  $default,){
final _that = this;
switch (_that) {
case _AskUserQuestionItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AskUserQuestionItem value)?  $default,){
final _that = this;
switch (_that) {
case _AskUserQuestionItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String question,  String header,  bool multiSelect,  List<AskUserQuestionOption> options)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AskUserQuestionItem() when $default != null:
return $default(_that.question,_that.header,_that.multiSelect,_that.options);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String question,  String header,  bool multiSelect,  List<AskUserQuestionOption> options)  $default,) {final _that = this;
switch (_that) {
case _AskUserQuestionItem():
return $default(_that.question,_that.header,_that.multiSelect,_that.options);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String question,  String header,  bool multiSelect,  List<AskUserQuestionOption> options)?  $default,) {final _that = this;
switch (_that) {
case _AskUserQuestionItem() when $default != null:
return $default(_that.question,_that.header,_that.multiSelect,_that.options);case _:
  return null;

}
}

}

/// @nodoc


class _AskUserQuestionItem implements AskUserQuestionItem {
  const _AskUserQuestionItem({required this.question, this.header = '', this.multiSelect = false, final  List<AskUserQuestionOption> options = const <AskUserQuestionOption>[]}): _options = options;
  

@override final  String question;
@override@JsonKey() final  String header;
@override@JsonKey() final  bool multiSelect;
 final  List<AskUserQuestionOption> _options;
@override@JsonKey() List<AskUserQuestionOption> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}


/// Create a copy of AskUserQuestionItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AskUserQuestionItemCopyWith<_AskUserQuestionItem> get copyWith => __$AskUserQuestionItemCopyWithImpl<_AskUserQuestionItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AskUserQuestionItem&&(identical(other.question, question) || other.question == question)&&(identical(other.header, header) || other.header == header)&&(identical(other.multiSelect, multiSelect) || other.multiSelect == multiSelect)&&const DeepCollectionEquality().equals(other._options, _options));
}


@override
int get hashCode => Object.hash(runtimeType,question,header,multiSelect,const DeepCollectionEquality().hash(_options));

@override
String toString() {
  return 'AskUserQuestionItem(question: $question, header: $header, multiSelect: $multiSelect, options: $options)';
}


}

/// @nodoc
abstract mixin class _$AskUserQuestionItemCopyWith<$Res> implements $AskUserQuestionItemCopyWith<$Res> {
  factory _$AskUserQuestionItemCopyWith(_AskUserQuestionItem value, $Res Function(_AskUserQuestionItem) _then) = __$AskUserQuestionItemCopyWithImpl;
@override @useResult
$Res call({
 String question, String header, bool multiSelect, List<AskUserQuestionOption> options
});




}
/// @nodoc
class __$AskUserQuestionItemCopyWithImpl<$Res>
    implements _$AskUserQuestionItemCopyWith<$Res> {
  __$AskUserQuestionItemCopyWithImpl(this._self, this._then);

  final _AskUserQuestionItem _self;
  final $Res Function(_AskUserQuestionItem) _then;

/// Create a copy of AskUserQuestionItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? question = null,Object? header = null,Object? multiSelect = null,Object? options = null,}) {
  return _then(_AskUserQuestionItem(
question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,header: null == header ? _self.header : header // ignore: cast_nullable_to_non_nullable
as String,multiSelect: null == multiSelect ? _self.multiSelect : multiSelect // ignore: cast_nullable_to_non_nullable
as bool,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<AskUserQuestionOption>,
  ));
}


}

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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ClaudeEventSessionInit value)?  sessionInit,TResult Function( ClaudeEventTextChunk value)?  textChunk,TResult Function( ClaudeEventToolCall value)?  toolCall,TResult Function( ClaudeEventToolCallUpdate value)?  toolCallUpdate,TResult Function( ClaudeEventToolCallComplete value)?  toolCallComplete,TResult Function( ClaudeEventToolResult value)?  toolResult,TResult Function( ClaudeEventAssistantMessage value)?  assistantMessage,TResult Function( ClaudeEventTaskComplete value)?  taskComplete,TResult Function( ClaudeEventErrorEvent value)?  errorEvent,TResult Function( ClaudeEventRateLimit value)?  rateLimit,TResult Function( ClaudeEventSessionDead value)?  sessionDead,TResult Function( ClaudeEventAskUserQuestion value)?  askUserQuestion,TResult Function( ClaudeEventPermissionRequest value)?  permissionRequest,TResult Function( ClaudeEventUsageUpdate value)?  usageUpdate,TResult Function( ClaudeEventPlanProposed value)?  planProposed,required TResult orElse(),}){
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
return sessionDead(_that);case ClaudeEventAskUserQuestion() when askUserQuestion != null:
return askUserQuestion(_that);case ClaudeEventPermissionRequest() when permissionRequest != null:
return permissionRequest(_that);case ClaudeEventUsageUpdate() when usageUpdate != null:
return usageUpdate(_that);case ClaudeEventPlanProposed() when planProposed != null:
return planProposed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ClaudeEventSessionInit value)  sessionInit,required TResult Function( ClaudeEventTextChunk value)  textChunk,required TResult Function( ClaudeEventToolCall value)  toolCall,required TResult Function( ClaudeEventToolCallUpdate value)  toolCallUpdate,required TResult Function( ClaudeEventToolCallComplete value)  toolCallComplete,required TResult Function( ClaudeEventToolResult value)  toolResult,required TResult Function( ClaudeEventAssistantMessage value)  assistantMessage,required TResult Function( ClaudeEventTaskComplete value)  taskComplete,required TResult Function( ClaudeEventErrorEvent value)  errorEvent,required TResult Function( ClaudeEventRateLimit value)  rateLimit,required TResult Function( ClaudeEventSessionDead value)  sessionDead,required TResult Function( ClaudeEventAskUserQuestion value)  askUserQuestion,required TResult Function( ClaudeEventPermissionRequest value)  permissionRequest,required TResult Function( ClaudeEventUsageUpdate value)  usageUpdate,required TResult Function( ClaudeEventPlanProposed value)  planProposed,}){
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
return sessionDead(_that);case ClaudeEventAskUserQuestion():
return askUserQuestion(_that);case ClaudeEventPermissionRequest():
return permissionRequest(_that);case ClaudeEventUsageUpdate():
return usageUpdate(_that);case ClaudeEventPlanProposed():
return planProposed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ClaudeEventSessionInit value)?  sessionInit,TResult? Function( ClaudeEventTextChunk value)?  textChunk,TResult? Function( ClaudeEventToolCall value)?  toolCall,TResult? Function( ClaudeEventToolCallUpdate value)?  toolCallUpdate,TResult? Function( ClaudeEventToolCallComplete value)?  toolCallComplete,TResult? Function( ClaudeEventToolResult value)?  toolResult,TResult? Function( ClaudeEventAssistantMessage value)?  assistantMessage,TResult? Function( ClaudeEventTaskComplete value)?  taskComplete,TResult? Function( ClaudeEventErrorEvent value)?  errorEvent,TResult? Function( ClaudeEventRateLimit value)?  rateLimit,TResult? Function( ClaudeEventSessionDead value)?  sessionDead,TResult? Function( ClaudeEventAskUserQuestion value)?  askUserQuestion,TResult? Function( ClaudeEventPermissionRequest value)?  permissionRequest,TResult? Function( ClaudeEventUsageUpdate value)?  usageUpdate,TResult? Function( ClaudeEventPlanProposed value)?  planProposed,}){
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
return sessionDead(_that);case ClaudeEventAskUserQuestion() when askUserQuestion != null:
return askUserQuestion(_that);case ClaudeEventPermissionRequest() when permissionRequest != null:
return permissionRequest(_that);case ClaudeEventUsageUpdate() when usageUpdate != null:
return usageUpdate(_that);case ClaudeEventPlanProposed() when planProposed != null:
return planProposed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String sessionId,  String model,  List<String> tools,  List<String> skills,  List<String> slashCommands,  List<ClaudePluginInfo> plugins)?  sessionInit,TResult Function( String text)?  textChunk,TResult Function( String toolName,  String toolId,  int index)?  toolCall,TResult Function( String toolId,  String partialInput)?  toolCallUpdate,TResult Function( int index,  String? toolId,  Map<String, dynamic>? input)?  toolCallComplete,TResult Function( String toolUseId,  String content,  bool isError)?  toolResult,TResult Function( String text)?  assistantMessage,TResult Function( String? result,  double? costUsd,  int? durationMs,  int? numTurns)?  taskComplete,TResult Function( String message)?  errorEvent,TResult Function( String status,  int? resetsAt)?  rateLimit,TResult Function( int? exitCode,  List<String> stderrTail)?  sessionDead,TResult Function( String toolUseId,  List<AskUserQuestionItem> questions)?  askUserQuestion,TResult Function( String requestId,  String toolName,  Map<String, dynamic> toolInput)?  permissionRequest,TResult Function( int? inputTokens,  int? cacheReadTokens,  int? cacheCreationTokens,  int? outputTokens)?  usageUpdate,TResult Function( String toolUseId,  String plan,  String? planFilePath)?  planProposed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ClaudeEventSessionInit() when sessionInit != null:
return sessionInit(_that.sessionId,_that.model,_that.tools,_that.skills,_that.slashCommands,_that.plugins);case ClaudeEventTextChunk() when textChunk != null:
return textChunk(_that.text);case ClaudeEventToolCall() when toolCall != null:
return toolCall(_that.toolName,_that.toolId,_that.index);case ClaudeEventToolCallUpdate() when toolCallUpdate != null:
return toolCallUpdate(_that.toolId,_that.partialInput);case ClaudeEventToolCallComplete() when toolCallComplete != null:
return toolCallComplete(_that.index,_that.toolId,_that.input);case ClaudeEventToolResult() when toolResult != null:
return toolResult(_that.toolUseId,_that.content,_that.isError);case ClaudeEventAssistantMessage() when assistantMessage != null:
return assistantMessage(_that.text);case ClaudeEventTaskComplete() when taskComplete != null:
return taskComplete(_that.result,_that.costUsd,_that.durationMs,_that.numTurns);case ClaudeEventErrorEvent() when errorEvent != null:
return errorEvent(_that.message);case ClaudeEventRateLimit() when rateLimit != null:
return rateLimit(_that.status,_that.resetsAt);case ClaudeEventSessionDead() when sessionDead != null:
return sessionDead(_that.exitCode,_that.stderrTail);case ClaudeEventAskUserQuestion() when askUserQuestion != null:
return askUserQuestion(_that.toolUseId,_that.questions);case ClaudeEventPermissionRequest() when permissionRequest != null:
return permissionRequest(_that.requestId,_that.toolName,_that.toolInput);case ClaudeEventUsageUpdate() when usageUpdate != null:
return usageUpdate(_that.inputTokens,_that.cacheReadTokens,_that.cacheCreationTokens,_that.outputTokens);case ClaudeEventPlanProposed() when planProposed != null:
return planProposed(_that.toolUseId,_that.plan,_that.planFilePath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String sessionId,  String model,  List<String> tools,  List<String> skills,  List<String> slashCommands,  List<ClaudePluginInfo> plugins)  sessionInit,required TResult Function( String text)  textChunk,required TResult Function( String toolName,  String toolId,  int index)  toolCall,required TResult Function( String toolId,  String partialInput)  toolCallUpdate,required TResult Function( int index,  String? toolId,  Map<String, dynamic>? input)  toolCallComplete,required TResult Function( String toolUseId,  String content,  bool isError)  toolResult,required TResult Function( String text)  assistantMessage,required TResult Function( String? result,  double? costUsd,  int? durationMs,  int? numTurns)  taskComplete,required TResult Function( String message)  errorEvent,required TResult Function( String status,  int? resetsAt)  rateLimit,required TResult Function( int? exitCode,  List<String> stderrTail)  sessionDead,required TResult Function( String toolUseId,  List<AskUserQuestionItem> questions)  askUserQuestion,required TResult Function( String requestId,  String toolName,  Map<String, dynamic> toolInput)  permissionRequest,required TResult Function( int? inputTokens,  int? cacheReadTokens,  int? cacheCreationTokens,  int? outputTokens)  usageUpdate,required TResult Function( String toolUseId,  String plan,  String? planFilePath)  planProposed,}) {final _that = this;
switch (_that) {
case ClaudeEventSessionInit():
return sessionInit(_that.sessionId,_that.model,_that.tools,_that.skills,_that.slashCommands,_that.plugins);case ClaudeEventTextChunk():
return textChunk(_that.text);case ClaudeEventToolCall():
return toolCall(_that.toolName,_that.toolId,_that.index);case ClaudeEventToolCallUpdate():
return toolCallUpdate(_that.toolId,_that.partialInput);case ClaudeEventToolCallComplete():
return toolCallComplete(_that.index,_that.toolId,_that.input);case ClaudeEventToolResult():
return toolResult(_that.toolUseId,_that.content,_that.isError);case ClaudeEventAssistantMessage():
return assistantMessage(_that.text);case ClaudeEventTaskComplete():
return taskComplete(_that.result,_that.costUsd,_that.durationMs,_that.numTurns);case ClaudeEventErrorEvent():
return errorEvent(_that.message);case ClaudeEventRateLimit():
return rateLimit(_that.status,_that.resetsAt);case ClaudeEventSessionDead():
return sessionDead(_that.exitCode,_that.stderrTail);case ClaudeEventAskUserQuestion():
return askUserQuestion(_that.toolUseId,_that.questions);case ClaudeEventPermissionRequest():
return permissionRequest(_that.requestId,_that.toolName,_that.toolInput);case ClaudeEventUsageUpdate():
return usageUpdate(_that.inputTokens,_that.cacheReadTokens,_that.cacheCreationTokens,_that.outputTokens);case ClaudeEventPlanProposed():
return planProposed(_that.toolUseId,_that.plan,_that.planFilePath);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String sessionId,  String model,  List<String> tools,  List<String> skills,  List<String> slashCommands,  List<ClaudePluginInfo> plugins)?  sessionInit,TResult? Function( String text)?  textChunk,TResult? Function( String toolName,  String toolId,  int index)?  toolCall,TResult? Function( String toolId,  String partialInput)?  toolCallUpdate,TResult? Function( int index,  String? toolId,  Map<String, dynamic>? input)?  toolCallComplete,TResult? Function( String toolUseId,  String content,  bool isError)?  toolResult,TResult? Function( String text)?  assistantMessage,TResult? Function( String? result,  double? costUsd,  int? durationMs,  int? numTurns)?  taskComplete,TResult? Function( String message)?  errorEvent,TResult? Function( String status,  int? resetsAt)?  rateLimit,TResult? Function( int? exitCode,  List<String> stderrTail)?  sessionDead,TResult? Function( String toolUseId,  List<AskUserQuestionItem> questions)?  askUserQuestion,TResult? Function( String requestId,  String toolName,  Map<String, dynamic> toolInput)?  permissionRequest,TResult? Function( int? inputTokens,  int? cacheReadTokens,  int? cacheCreationTokens,  int? outputTokens)?  usageUpdate,TResult? Function( String toolUseId,  String plan,  String? planFilePath)?  planProposed,}) {final _that = this;
switch (_that) {
case ClaudeEventSessionInit() when sessionInit != null:
return sessionInit(_that.sessionId,_that.model,_that.tools,_that.skills,_that.slashCommands,_that.plugins);case ClaudeEventTextChunk() when textChunk != null:
return textChunk(_that.text);case ClaudeEventToolCall() when toolCall != null:
return toolCall(_that.toolName,_that.toolId,_that.index);case ClaudeEventToolCallUpdate() when toolCallUpdate != null:
return toolCallUpdate(_that.toolId,_that.partialInput);case ClaudeEventToolCallComplete() when toolCallComplete != null:
return toolCallComplete(_that.index,_that.toolId,_that.input);case ClaudeEventToolResult() when toolResult != null:
return toolResult(_that.toolUseId,_that.content,_that.isError);case ClaudeEventAssistantMessage() when assistantMessage != null:
return assistantMessage(_that.text);case ClaudeEventTaskComplete() when taskComplete != null:
return taskComplete(_that.result,_that.costUsd,_that.durationMs,_that.numTurns);case ClaudeEventErrorEvent() when errorEvent != null:
return errorEvent(_that.message);case ClaudeEventRateLimit() when rateLimit != null:
return rateLimit(_that.status,_that.resetsAt);case ClaudeEventSessionDead() when sessionDead != null:
return sessionDead(_that.exitCode,_that.stderrTail);case ClaudeEventAskUserQuestion() when askUserQuestion != null:
return askUserQuestion(_that.toolUseId,_that.questions);case ClaudeEventPermissionRequest() when permissionRequest != null:
return permissionRequest(_that.requestId,_that.toolName,_that.toolInput);case ClaudeEventUsageUpdate() when usageUpdate != null:
return usageUpdate(_that.inputTokens,_that.cacheReadTokens,_that.cacheCreationTokens,_that.outputTokens);case ClaudeEventPlanProposed() when planProposed != null:
return planProposed(_that.toolUseId,_that.plan,_that.planFilePath);case _:
  return null;

}
}

}

/// @nodoc


class ClaudeEventSessionInit implements ClaudeEvent {
  const ClaudeEventSessionInit({required this.sessionId, required this.model, final  List<String> tools = const <String>[], final  List<String> skills = const <String>[], final  List<String> slashCommands = const <String>[], final  List<ClaudePluginInfo> plugins = const <ClaudePluginInfo>[]}): _tools = tools,_skills = skills,_slashCommands = slashCommands,_plugins = plugins;
  

 final  String sessionId;
 final  String model;
 final  List<String> _tools;
@JsonKey() List<String> get tools {
  if (_tools is EqualUnmodifiableListView) return _tools;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tools);
}

 final  List<String> _skills;
@JsonKey() List<String> get skills {
  if (_skills is EqualUnmodifiableListView) return _skills;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skills);
}

 final  List<String> _slashCommands;
@JsonKey() List<String> get slashCommands {
  if (_slashCommands is EqualUnmodifiableListView) return _slashCommands;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_slashCommands);
}

 final  List<ClaudePluginInfo> _plugins;
@JsonKey() List<ClaudePluginInfo> get plugins {
  if (_plugins is EqualUnmodifiableListView) return _plugins;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_plugins);
}


/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeEventSessionInitCopyWith<ClaudeEventSessionInit> get copyWith => _$ClaudeEventSessionInitCopyWithImpl<ClaudeEventSessionInit>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeEventSessionInit&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.model, model) || other.model == model)&&const DeepCollectionEquality().equals(other._tools, _tools)&&const DeepCollectionEquality().equals(other._skills, _skills)&&const DeepCollectionEquality().equals(other._slashCommands, _slashCommands)&&const DeepCollectionEquality().equals(other._plugins, _plugins));
}


@override
int get hashCode => Object.hash(runtimeType,sessionId,model,const DeepCollectionEquality().hash(_tools),const DeepCollectionEquality().hash(_skills),const DeepCollectionEquality().hash(_slashCommands),const DeepCollectionEquality().hash(_plugins));

@override
String toString() {
  return 'ClaudeEvent.sessionInit(sessionId: $sessionId, model: $model, tools: $tools, skills: $skills, slashCommands: $slashCommands, plugins: $plugins)';
}


}

/// @nodoc
abstract mixin class $ClaudeEventSessionInitCopyWith<$Res> implements $ClaudeEventCopyWith<$Res> {
  factory $ClaudeEventSessionInitCopyWith(ClaudeEventSessionInit value, $Res Function(ClaudeEventSessionInit) _then) = _$ClaudeEventSessionInitCopyWithImpl;
@useResult
$Res call({
 String sessionId, String model, List<String> tools, List<String> skills, List<String> slashCommands, List<ClaudePluginInfo> plugins
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
@pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? model = null,Object? tools = null,Object? skills = null,Object? slashCommands = null,Object? plugins = null,}) {
  return _then(ClaudeEventSessionInit(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,tools: null == tools ? _self._tools : tools // ignore: cast_nullable_to_non_nullable
as List<String>,skills: null == skills ? _self._skills : skills // ignore: cast_nullable_to_non_nullable
as List<String>,slashCommands: null == slashCommands ? _self._slashCommands : slashCommands // ignore: cast_nullable_to_non_nullable
as List<String>,plugins: null == plugins ? _self._plugins : plugins // ignore: cast_nullable_to_non_nullable
as List<ClaudePluginInfo>,
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

/// @nodoc


class ClaudeEventAskUserQuestion implements ClaudeEvent {
  const ClaudeEventAskUserQuestion({required this.toolUseId, required final  List<AskUserQuestionItem> questions}): _questions = questions;
  

 final  String toolUseId;
 final  List<AskUserQuestionItem> _questions;
 List<AskUserQuestionItem> get questions {
  if (_questions is EqualUnmodifiableListView) return _questions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_questions);
}


/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeEventAskUserQuestionCopyWith<ClaudeEventAskUserQuestion> get copyWith => _$ClaudeEventAskUserQuestionCopyWithImpl<ClaudeEventAskUserQuestion>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeEventAskUserQuestion&&(identical(other.toolUseId, toolUseId) || other.toolUseId == toolUseId)&&const DeepCollectionEquality().equals(other._questions, _questions));
}


@override
int get hashCode => Object.hash(runtimeType,toolUseId,const DeepCollectionEquality().hash(_questions));

@override
String toString() {
  return 'ClaudeEvent.askUserQuestion(toolUseId: $toolUseId, questions: $questions)';
}


}

/// @nodoc
abstract mixin class $ClaudeEventAskUserQuestionCopyWith<$Res> implements $ClaudeEventCopyWith<$Res> {
  factory $ClaudeEventAskUserQuestionCopyWith(ClaudeEventAskUserQuestion value, $Res Function(ClaudeEventAskUserQuestion) _then) = _$ClaudeEventAskUserQuestionCopyWithImpl;
@useResult
$Res call({
 String toolUseId, List<AskUserQuestionItem> questions
});




}
/// @nodoc
class _$ClaudeEventAskUserQuestionCopyWithImpl<$Res>
    implements $ClaudeEventAskUserQuestionCopyWith<$Res> {
  _$ClaudeEventAskUserQuestionCopyWithImpl(this._self, this._then);

  final ClaudeEventAskUserQuestion _self;
  final $Res Function(ClaudeEventAskUserQuestion) _then;

/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? toolUseId = null,Object? questions = null,}) {
  return _then(ClaudeEventAskUserQuestion(
toolUseId: null == toolUseId ? _self.toolUseId : toolUseId // ignore: cast_nullable_to_non_nullable
as String,questions: null == questions ? _self._questions : questions // ignore: cast_nullable_to_non_nullable
as List<AskUserQuestionItem>,
  ));
}


}

/// @nodoc


class ClaudeEventPermissionRequest implements ClaudeEvent {
  const ClaudeEventPermissionRequest({required this.requestId, required this.toolName, required final  Map<String, dynamic> toolInput}): _toolInput = toolInput;
  

 final  String requestId;
 final  String toolName;
 final  Map<String, dynamic> _toolInput;
 Map<String, dynamic> get toolInput {
  if (_toolInput is EqualUnmodifiableMapView) return _toolInput;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_toolInput);
}


/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeEventPermissionRequestCopyWith<ClaudeEventPermissionRequest> get copyWith => _$ClaudeEventPermissionRequestCopyWithImpl<ClaudeEventPermissionRequest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeEventPermissionRequest&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.toolName, toolName) || other.toolName == toolName)&&const DeepCollectionEquality().equals(other._toolInput, _toolInput));
}


@override
int get hashCode => Object.hash(runtimeType,requestId,toolName,const DeepCollectionEquality().hash(_toolInput));

@override
String toString() {
  return 'ClaudeEvent.permissionRequest(requestId: $requestId, toolName: $toolName, toolInput: $toolInput)';
}


}

/// @nodoc
abstract mixin class $ClaudeEventPermissionRequestCopyWith<$Res> implements $ClaudeEventCopyWith<$Res> {
  factory $ClaudeEventPermissionRequestCopyWith(ClaudeEventPermissionRequest value, $Res Function(ClaudeEventPermissionRequest) _then) = _$ClaudeEventPermissionRequestCopyWithImpl;
@useResult
$Res call({
 String requestId, String toolName, Map<String, dynamic> toolInput
});




}
/// @nodoc
class _$ClaudeEventPermissionRequestCopyWithImpl<$Res>
    implements $ClaudeEventPermissionRequestCopyWith<$Res> {
  _$ClaudeEventPermissionRequestCopyWithImpl(this._self, this._then);

  final ClaudeEventPermissionRequest _self;
  final $Res Function(ClaudeEventPermissionRequest) _then;

/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? requestId = null,Object? toolName = null,Object? toolInput = null,}) {
  return _then(ClaudeEventPermissionRequest(
requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,toolName: null == toolName ? _self.toolName : toolName // ignore: cast_nullable_to_non_nullable
as String,toolInput: null == toolInput ? _self._toolInput : toolInput // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

/// @nodoc


class ClaudeEventUsageUpdate implements ClaudeEvent {
  const ClaudeEventUsageUpdate({this.inputTokens, this.cacheReadTokens, this.cacheCreationTokens, this.outputTokens});
  

 final  int? inputTokens;
 final  int? cacheReadTokens;
 final  int? cacheCreationTokens;
 final  int? outputTokens;

/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeEventUsageUpdateCopyWith<ClaudeEventUsageUpdate> get copyWith => _$ClaudeEventUsageUpdateCopyWithImpl<ClaudeEventUsageUpdate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeEventUsageUpdate&&(identical(other.inputTokens, inputTokens) || other.inputTokens == inputTokens)&&(identical(other.cacheReadTokens, cacheReadTokens) || other.cacheReadTokens == cacheReadTokens)&&(identical(other.cacheCreationTokens, cacheCreationTokens) || other.cacheCreationTokens == cacheCreationTokens)&&(identical(other.outputTokens, outputTokens) || other.outputTokens == outputTokens));
}


@override
int get hashCode => Object.hash(runtimeType,inputTokens,cacheReadTokens,cacheCreationTokens,outputTokens);

@override
String toString() {
  return 'ClaudeEvent.usageUpdate(inputTokens: $inputTokens, cacheReadTokens: $cacheReadTokens, cacheCreationTokens: $cacheCreationTokens, outputTokens: $outputTokens)';
}


}

/// @nodoc
abstract mixin class $ClaudeEventUsageUpdateCopyWith<$Res> implements $ClaudeEventCopyWith<$Res> {
  factory $ClaudeEventUsageUpdateCopyWith(ClaudeEventUsageUpdate value, $Res Function(ClaudeEventUsageUpdate) _then) = _$ClaudeEventUsageUpdateCopyWithImpl;
@useResult
$Res call({
 int? inputTokens, int? cacheReadTokens, int? cacheCreationTokens, int? outputTokens
});




}
/// @nodoc
class _$ClaudeEventUsageUpdateCopyWithImpl<$Res>
    implements $ClaudeEventUsageUpdateCopyWith<$Res> {
  _$ClaudeEventUsageUpdateCopyWithImpl(this._self, this._then);

  final ClaudeEventUsageUpdate _self;
  final $Res Function(ClaudeEventUsageUpdate) _then;

/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? inputTokens = freezed,Object? cacheReadTokens = freezed,Object? cacheCreationTokens = freezed,Object? outputTokens = freezed,}) {
  return _then(ClaudeEventUsageUpdate(
inputTokens: freezed == inputTokens ? _self.inputTokens : inputTokens // ignore: cast_nullable_to_non_nullable
as int?,cacheReadTokens: freezed == cacheReadTokens ? _self.cacheReadTokens : cacheReadTokens // ignore: cast_nullable_to_non_nullable
as int?,cacheCreationTokens: freezed == cacheCreationTokens ? _self.cacheCreationTokens : cacheCreationTokens // ignore: cast_nullable_to_non_nullable
as int?,outputTokens: freezed == outputTokens ? _self.outputTokens : outputTokens // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class ClaudeEventPlanProposed implements ClaudeEvent {
  const ClaudeEventPlanProposed({required this.toolUseId, required this.plan, this.planFilePath});
  

 final  String toolUseId;
 final  String plan;
 final  String? planFilePath;

/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaudeEventPlanProposedCopyWith<ClaudeEventPlanProposed> get copyWith => _$ClaudeEventPlanProposedCopyWithImpl<ClaudeEventPlanProposed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaudeEventPlanProposed&&(identical(other.toolUseId, toolUseId) || other.toolUseId == toolUseId)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.planFilePath, planFilePath) || other.planFilePath == planFilePath));
}


@override
int get hashCode => Object.hash(runtimeType,toolUseId,plan,planFilePath);

@override
String toString() {
  return 'ClaudeEvent.planProposed(toolUseId: $toolUseId, plan: $plan, planFilePath: $planFilePath)';
}


}

/// @nodoc
abstract mixin class $ClaudeEventPlanProposedCopyWith<$Res> implements $ClaudeEventCopyWith<$Res> {
  factory $ClaudeEventPlanProposedCopyWith(ClaudeEventPlanProposed value, $Res Function(ClaudeEventPlanProposed) _then) = _$ClaudeEventPlanProposedCopyWithImpl;
@useResult
$Res call({
 String toolUseId, String plan, String? planFilePath
});




}
/// @nodoc
class _$ClaudeEventPlanProposedCopyWithImpl<$Res>
    implements $ClaudeEventPlanProposedCopyWith<$Res> {
  _$ClaudeEventPlanProposedCopyWithImpl(this._self, this._then);

  final ClaudeEventPlanProposed _self;
  final $Res Function(ClaudeEventPlanProposed) _then;

/// Create a copy of ClaudeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? toolUseId = null,Object? plan = null,Object? planFilePath = freezed,}) {
  return _then(ClaudeEventPlanProposed(
toolUseId: null == toolUseId ? _self.toolUseId : toolUseId // ignore: cast_nullable_to_non_nullable
as String,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as String,planFilePath: freezed == planFilePath ? _self.planFilePath : planFilePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
