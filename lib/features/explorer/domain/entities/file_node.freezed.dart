// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_node.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FileNode {

 String get name; String get path; bool get isDir;
/// Create a copy of FileNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileNodeCopyWith<FileNode> get copyWith => _$FileNodeCopyWithImpl<FileNode>(this as FileNode, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileNode&&(identical(other.name, name) || other.name == name)&&(identical(other.path, path) || other.path == path)&&(identical(other.isDir, isDir) || other.isDir == isDir));
}


@override
int get hashCode => Object.hash(runtimeType,name,path,isDir);

@override
String toString() {
  return 'FileNode(name: $name, path: $path, isDir: $isDir)';
}


}

/// @nodoc
abstract mixin class $FileNodeCopyWith<$Res>  {
  factory $FileNodeCopyWith(FileNode value, $Res Function(FileNode) _then) = _$FileNodeCopyWithImpl;
@useResult
$Res call({
 String name, String path, bool isDir
});




}
/// @nodoc
class _$FileNodeCopyWithImpl<$Res>
    implements $FileNodeCopyWith<$Res> {
  _$FileNodeCopyWithImpl(this._self, this._then);

  final FileNode _self;
  final $Res Function(FileNode) _then;

/// Create a copy of FileNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? path = null,Object? isDir = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,isDir: null == isDir ? _self.isDir : isDir // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FileNode].
extension FileNodePatterns on FileNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FileNode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FileNode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FileNode value)  $default,){
final _that = this;
switch (_that) {
case _FileNode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FileNode value)?  $default,){
final _that = this;
switch (_that) {
case _FileNode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String path,  bool isDir)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FileNode() when $default != null:
return $default(_that.name,_that.path,_that.isDir);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String path,  bool isDir)  $default,) {final _that = this;
switch (_that) {
case _FileNode():
return $default(_that.name,_that.path,_that.isDir);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String path,  bool isDir)?  $default,) {final _that = this;
switch (_that) {
case _FileNode() when $default != null:
return $default(_that.name,_that.path,_that.isDir);case _:
  return null;

}
}

}

/// @nodoc


class _FileNode implements FileNode {
  const _FileNode({required this.name, required this.path, required this.isDir});
  

@override final  String name;
@override final  String path;
@override final  bool isDir;

/// Create a copy of FileNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FileNodeCopyWith<_FileNode> get copyWith => __$FileNodeCopyWithImpl<_FileNode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FileNode&&(identical(other.name, name) || other.name == name)&&(identical(other.path, path) || other.path == path)&&(identical(other.isDir, isDir) || other.isDir == isDir));
}


@override
int get hashCode => Object.hash(runtimeType,name,path,isDir);

@override
String toString() {
  return 'FileNode(name: $name, path: $path, isDir: $isDir)';
}


}

/// @nodoc
abstract mixin class _$FileNodeCopyWith<$Res> implements $FileNodeCopyWith<$Res> {
  factory _$FileNodeCopyWith(_FileNode value, $Res Function(_FileNode) _then) = __$FileNodeCopyWithImpl;
@override @useResult
$Res call({
 String name, String path, bool isDir
});




}
/// @nodoc
class __$FileNodeCopyWithImpl<$Res>
    implements _$FileNodeCopyWith<$Res> {
  __$FileNodeCopyWithImpl(this._self, this._then);

  final _FileNode _self;
  final $Res Function(_FileNode) _then;

/// Create a copy of FileNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? path = null,Object? isDir = null,}) {
  return _then(_FileNode(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,isDir: null == isDir ? _self.isDir : isDir // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
