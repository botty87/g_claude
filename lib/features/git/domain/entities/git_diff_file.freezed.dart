// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'git_diff_file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GitDiffFile {

 String get path; GitFileStatus get status; int get added; int get deleted; bool get isBinary; String? get oldPath;
/// Create a copy of GitDiffFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitDiffFileCopyWith<GitDiffFile> get copyWith => _$GitDiffFileCopyWithImpl<GitDiffFile>(this as GitDiffFile, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitDiffFile&&(identical(other.path, path) || other.path == path)&&(identical(other.status, status) || other.status == status)&&(identical(other.added, added) || other.added == added)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.isBinary, isBinary) || other.isBinary == isBinary)&&(identical(other.oldPath, oldPath) || other.oldPath == oldPath));
}


@override
int get hashCode => Object.hash(runtimeType,path,status,added,deleted,isBinary,oldPath);

@override
String toString() {
  return 'GitDiffFile(path: $path, status: $status, added: $added, deleted: $deleted, isBinary: $isBinary, oldPath: $oldPath)';
}


}

/// @nodoc
abstract mixin class $GitDiffFileCopyWith<$Res>  {
  factory $GitDiffFileCopyWith(GitDiffFile value, $Res Function(GitDiffFile) _then) = _$GitDiffFileCopyWithImpl;
@useResult
$Res call({
 String path, GitFileStatus status, int added, int deleted, bool isBinary, String? oldPath
});




}
/// @nodoc
class _$GitDiffFileCopyWithImpl<$Res>
    implements $GitDiffFileCopyWith<$Res> {
  _$GitDiffFileCopyWithImpl(this._self, this._then);

  final GitDiffFile _self;
  final $Res Function(GitDiffFile) _then;

/// Create a copy of GitDiffFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? status = null,Object? added = null,Object? deleted = null,Object? isBinary = null,Object? oldPath = freezed,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GitFileStatus,added: null == added ? _self.added : added // ignore: cast_nullable_to_non_nullable
as int,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as int,isBinary: null == isBinary ? _self.isBinary : isBinary // ignore: cast_nullable_to_non_nullable
as bool,oldPath: freezed == oldPath ? _self.oldPath : oldPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GitDiffFile].
extension GitDiffFilePatterns on GitDiffFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitDiffFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitDiffFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitDiffFile value)  $default,){
final _that = this;
switch (_that) {
case _GitDiffFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitDiffFile value)?  $default,){
final _that = this;
switch (_that) {
case _GitDiffFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  GitFileStatus status,  int added,  int deleted,  bool isBinary,  String? oldPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitDiffFile() when $default != null:
return $default(_that.path,_that.status,_that.added,_that.deleted,_that.isBinary,_that.oldPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  GitFileStatus status,  int added,  int deleted,  bool isBinary,  String? oldPath)  $default,) {final _that = this;
switch (_that) {
case _GitDiffFile():
return $default(_that.path,_that.status,_that.added,_that.deleted,_that.isBinary,_that.oldPath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  GitFileStatus status,  int added,  int deleted,  bool isBinary,  String? oldPath)?  $default,) {final _that = this;
switch (_that) {
case _GitDiffFile() when $default != null:
return $default(_that.path,_that.status,_that.added,_that.deleted,_that.isBinary,_that.oldPath);case _:
  return null;

}
}

}

/// @nodoc


class _GitDiffFile implements GitDiffFile {
  const _GitDiffFile({required this.path, required this.status, this.added = 0, this.deleted = 0, this.isBinary = false, this.oldPath});
  

@override final  String path;
@override final  GitFileStatus status;
@override@JsonKey() final  int added;
@override@JsonKey() final  int deleted;
@override@JsonKey() final  bool isBinary;
@override final  String? oldPath;

/// Create a copy of GitDiffFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitDiffFileCopyWith<_GitDiffFile> get copyWith => __$GitDiffFileCopyWithImpl<_GitDiffFile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitDiffFile&&(identical(other.path, path) || other.path == path)&&(identical(other.status, status) || other.status == status)&&(identical(other.added, added) || other.added == added)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.isBinary, isBinary) || other.isBinary == isBinary)&&(identical(other.oldPath, oldPath) || other.oldPath == oldPath));
}


@override
int get hashCode => Object.hash(runtimeType,path,status,added,deleted,isBinary,oldPath);

@override
String toString() {
  return 'GitDiffFile(path: $path, status: $status, added: $added, deleted: $deleted, isBinary: $isBinary, oldPath: $oldPath)';
}


}

/// @nodoc
abstract mixin class _$GitDiffFileCopyWith<$Res> implements $GitDiffFileCopyWith<$Res> {
  factory _$GitDiffFileCopyWith(_GitDiffFile value, $Res Function(_GitDiffFile) _then) = __$GitDiffFileCopyWithImpl;
@override @useResult
$Res call({
 String path, GitFileStatus status, int added, int deleted, bool isBinary, String? oldPath
});




}
/// @nodoc
class __$GitDiffFileCopyWithImpl<$Res>
    implements _$GitDiffFileCopyWith<$Res> {
  __$GitDiffFileCopyWithImpl(this._self, this._then);

  final _GitDiffFile _self;
  final $Res Function(_GitDiffFile) _then;

/// Create a copy of GitDiffFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? status = null,Object? added = null,Object? deleted = null,Object? isBinary = null,Object? oldPath = freezed,}) {
  return _then(_GitDiffFile(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GitFileStatus,added: null == added ? _self.added : added // ignore: cast_nullable_to_non_nullable
as int,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as int,isBinary: null == isBinary ? _self.isBinary : isBinary // ignore: cast_nullable_to_non_nullable
as bool,oldPath: freezed == oldPath ? _self.oldPath : oldPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
