// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_content.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FileContent {

 String get path; String get content; String? get language; int get sizeBytes;
/// Create a copy of FileContent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileContentCopyWith<FileContent> get copyWith => _$FileContentCopyWithImpl<FileContent>(this as FileContent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileContent&&(identical(other.path, path) || other.path == path)&&(identical(other.content, content) || other.content == content)&&(identical(other.language, language) || other.language == language)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes));
}


@override
int get hashCode => Object.hash(runtimeType,path,content,language,sizeBytes);

@override
String toString() {
  return 'FileContent(path: $path, content: $content, language: $language, sizeBytes: $sizeBytes)';
}


}

/// @nodoc
abstract mixin class $FileContentCopyWith<$Res>  {
  factory $FileContentCopyWith(FileContent value, $Res Function(FileContent) _then) = _$FileContentCopyWithImpl;
@useResult
$Res call({
 String path, String content, String? language, int sizeBytes
});




}
/// @nodoc
class _$FileContentCopyWithImpl<$Res>
    implements $FileContentCopyWith<$Res> {
  _$FileContentCopyWithImpl(this._self, this._then);

  final FileContent _self;
  final $Res Function(FileContent) _then;

/// Create a copy of FileContent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? content = null,Object? language = freezed,Object? sizeBytes = null,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FileContent].
extension FileContentPatterns on FileContent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FileContent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FileContent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FileContent value)  $default,){
final _that = this;
switch (_that) {
case _FileContent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FileContent value)?  $default,){
final _that = this;
switch (_that) {
case _FileContent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  String content,  String? language,  int sizeBytes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FileContent() when $default != null:
return $default(_that.path,_that.content,_that.language,_that.sizeBytes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  String content,  String? language,  int sizeBytes)  $default,) {final _that = this;
switch (_that) {
case _FileContent():
return $default(_that.path,_that.content,_that.language,_that.sizeBytes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  String content,  String? language,  int sizeBytes)?  $default,) {final _that = this;
switch (_that) {
case _FileContent() when $default != null:
return $default(_that.path,_that.content,_that.language,_that.sizeBytes);case _:
  return null;

}
}

}

/// @nodoc


class _FileContent implements FileContent {
  const _FileContent({required this.path, required this.content, this.language, required this.sizeBytes});
  

@override final  String path;
@override final  String content;
@override final  String? language;
@override final  int sizeBytes;

/// Create a copy of FileContent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FileContentCopyWith<_FileContent> get copyWith => __$FileContentCopyWithImpl<_FileContent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FileContent&&(identical(other.path, path) || other.path == path)&&(identical(other.content, content) || other.content == content)&&(identical(other.language, language) || other.language == language)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes));
}


@override
int get hashCode => Object.hash(runtimeType,path,content,language,sizeBytes);

@override
String toString() {
  return 'FileContent(path: $path, content: $content, language: $language, sizeBytes: $sizeBytes)';
}


}

/// @nodoc
abstract mixin class _$FileContentCopyWith<$Res> implements $FileContentCopyWith<$Res> {
  factory _$FileContentCopyWith(_FileContent value, $Res Function(_FileContent) _then) = __$FileContentCopyWithImpl;
@override @useResult
$Res call({
 String path, String content, String? language, int sizeBytes
});




}
/// @nodoc
class __$FileContentCopyWithImpl<$Res>
    implements _$FileContentCopyWith<$Res> {
  __$FileContentCopyWithImpl(this._self, this._then);

  final _FileContent _self;
  final $Res Function(_FileContent) _then;

/// Create a copy of FileContent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? content = null,Object? language = freezed,Object? sizeBytes = null,}) {
  return _then(_FileContent(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
