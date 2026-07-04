// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_diff.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DiffLine {

 DiffLineType get type; String get content; int? get oldLineNo; int? get newLineNo;
/// Create a copy of DiffLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiffLineCopyWith<DiffLine> get copyWith => _$DiffLineCopyWithImpl<DiffLine>(this as DiffLine, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiffLine&&(identical(other.type, type) || other.type == type)&&(identical(other.content, content) || other.content == content)&&(identical(other.oldLineNo, oldLineNo) || other.oldLineNo == oldLineNo)&&(identical(other.newLineNo, newLineNo) || other.newLineNo == newLineNo));
}


@override
int get hashCode => Object.hash(runtimeType,type,content,oldLineNo,newLineNo);

@override
String toString() {
  return 'DiffLine(type: $type, content: $content, oldLineNo: $oldLineNo, newLineNo: $newLineNo)';
}


}

/// @nodoc
abstract mixin class $DiffLineCopyWith<$Res>  {
  factory $DiffLineCopyWith(DiffLine value, $Res Function(DiffLine) _then) = _$DiffLineCopyWithImpl;
@useResult
$Res call({
 DiffLineType type, String content, int? oldLineNo, int? newLineNo
});




}
/// @nodoc
class _$DiffLineCopyWithImpl<$Res>
    implements $DiffLineCopyWith<$Res> {
  _$DiffLineCopyWithImpl(this._self, this._then);

  final DiffLine _self;
  final $Res Function(DiffLine) _then;

/// Create a copy of DiffLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? content = null,Object? oldLineNo = freezed,Object? newLineNo = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DiffLineType,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,oldLineNo: freezed == oldLineNo ? _self.oldLineNo : oldLineNo // ignore: cast_nullable_to_non_nullable
as int?,newLineNo: freezed == newLineNo ? _self.newLineNo : newLineNo // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [DiffLine].
extension DiffLinePatterns on DiffLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiffLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiffLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiffLine value)  $default,){
final _that = this;
switch (_that) {
case _DiffLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiffLine value)?  $default,){
final _that = this;
switch (_that) {
case _DiffLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DiffLineType type,  String content,  int? oldLineNo,  int? newLineNo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiffLine() when $default != null:
return $default(_that.type,_that.content,_that.oldLineNo,_that.newLineNo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DiffLineType type,  String content,  int? oldLineNo,  int? newLineNo)  $default,) {final _that = this;
switch (_that) {
case _DiffLine():
return $default(_that.type,_that.content,_that.oldLineNo,_that.newLineNo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DiffLineType type,  String content,  int? oldLineNo,  int? newLineNo)?  $default,) {final _that = this;
switch (_that) {
case _DiffLine() when $default != null:
return $default(_that.type,_that.content,_that.oldLineNo,_that.newLineNo);case _:
  return null;

}
}

}

/// @nodoc


class _DiffLine implements DiffLine {
  const _DiffLine({required this.type, required this.content, this.oldLineNo, this.newLineNo});
  

@override final  DiffLineType type;
@override final  String content;
@override final  int? oldLineNo;
@override final  int? newLineNo;

/// Create a copy of DiffLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiffLineCopyWith<_DiffLine> get copyWith => __$DiffLineCopyWithImpl<_DiffLine>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiffLine&&(identical(other.type, type) || other.type == type)&&(identical(other.content, content) || other.content == content)&&(identical(other.oldLineNo, oldLineNo) || other.oldLineNo == oldLineNo)&&(identical(other.newLineNo, newLineNo) || other.newLineNo == newLineNo));
}


@override
int get hashCode => Object.hash(runtimeType,type,content,oldLineNo,newLineNo);

@override
String toString() {
  return 'DiffLine(type: $type, content: $content, oldLineNo: $oldLineNo, newLineNo: $newLineNo)';
}


}

/// @nodoc
abstract mixin class _$DiffLineCopyWith<$Res> implements $DiffLineCopyWith<$Res> {
  factory _$DiffLineCopyWith(_DiffLine value, $Res Function(_DiffLine) _then) = __$DiffLineCopyWithImpl;
@override @useResult
$Res call({
 DiffLineType type, String content, int? oldLineNo, int? newLineNo
});




}
/// @nodoc
class __$DiffLineCopyWithImpl<$Res>
    implements _$DiffLineCopyWith<$Res> {
  __$DiffLineCopyWithImpl(this._self, this._then);

  final _DiffLine _self;
  final $Res Function(_DiffLine) _then;

/// Create a copy of DiffLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? content = null,Object? oldLineNo = freezed,Object? newLineNo = freezed,}) {
  return _then(_DiffLine(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DiffLineType,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,oldLineNo: freezed == oldLineNo ? _self.oldLineNo : oldLineNo // ignore: cast_nullable_to_non_nullable
as int?,newLineNo: freezed == newLineNo ? _self.newLineNo : newLineNo // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$DiffHunk {

 String get header; List<DiffLine> get lines;
/// Create a copy of DiffHunk
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiffHunkCopyWith<DiffHunk> get copyWith => _$DiffHunkCopyWithImpl<DiffHunk>(this as DiffHunk, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiffHunk&&(identical(other.header, header) || other.header == header)&&const DeepCollectionEquality().equals(other.lines, lines));
}


@override
int get hashCode => Object.hash(runtimeType,header,const DeepCollectionEquality().hash(lines));

@override
String toString() {
  return 'DiffHunk(header: $header, lines: $lines)';
}


}

/// @nodoc
abstract mixin class $DiffHunkCopyWith<$Res>  {
  factory $DiffHunkCopyWith(DiffHunk value, $Res Function(DiffHunk) _then) = _$DiffHunkCopyWithImpl;
@useResult
$Res call({
 String header, List<DiffLine> lines
});




}
/// @nodoc
class _$DiffHunkCopyWithImpl<$Res>
    implements $DiffHunkCopyWith<$Res> {
  _$DiffHunkCopyWithImpl(this._self, this._then);

  final DiffHunk _self;
  final $Res Function(DiffHunk) _then;

/// Create a copy of DiffHunk
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? header = null,Object? lines = null,}) {
  return _then(_self.copyWith(
header: null == header ? _self.header : header // ignore: cast_nullable_to_non_nullable
as String,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<DiffLine>,
  ));
}

}


/// Adds pattern-matching-related methods to [DiffHunk].
extension DiffHunkPatterns on DiffHunk {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiffHunk value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiffHunk() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiffHunk value)  $default,){
final _that = this;
switch (_that) {
case _DiffHunk():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiffHunk value)?  $default,){
final _that = this;
switch (_that) {
case _DiffHunk() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String header,  List<DiffLine> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiffHunk() when $default != null:
return $default(_that.header,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String header,  List<DiffLine> lines)  $default,) {final _that = this;
switch (_that) {
case _DiffHunk():
return $default(_that.header,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String header,  List<DiffLine> lines)?  $default,) {final _that = this;
switch (_that) {
case _DiffHunk() when $default != null:
return $default(_that.header,_that.lines);case _:
  return null;

}
}

}

/// @nodoc


class _DiffHunk implements DiffHunk {
  const _DiffHunk({required this.header, required final  List<DiffLine> lines}): _lines = lines;
  

@override final  String header;
 final  List<DiffLine> _lines;
@override List<DiffLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


/// Create a copy of DiffHunk
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiffHunkCopyWith<_DiffHunk> get copyWith => __$DiffHunkCopyWithImpl<_DiffHunk>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiffHunk&&(identical(other.header, header) || other.header == header)&&const DeepCollectionEquality().equals(other._lines, _lines));
}


@override
int get hashCode => Object.hash(runtimeType,header,const DeepCollectionEquality().hash(_lines));

@override
String toString() {
  return 'DiffHunk(header: $header, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$DiffHunkCopyWith<$Res> implements $DiffHunkCopyWith<$Res> {
  factory _$DiffHunkCopyWith(_DiffHunk value, $Res Function(_DiffHunk) _then) = __$DiffHunkCopyWithImpl;
@override @useResult
$Res call({
 String header, List<DiffLine> lines
});




}
/// @nodoc
class __$DiffHunkCopyWithImpl<$Res>
    implements _$DiffHunkCopyWith<$Res> {
  __$DiffHunkCopyWithImpl(this._self, this._then);

  final _DiffHunk _self;
  final $Res Function(_DiffHunk) _then;

/// Create a copy of DiffHunk
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? header = null,Object? lines = null,}) {
  return _then(_DiffHunk(
header: null == header ? _self.header : header // ignore: cast_nullable_to_non_nullable
as String,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<DiffLine>,
  ));
}


}

/// @nodoc
mixin _$FileDiff {

 String get path; List<DiffHunk> get hunks; bool get isBinary; int get added; int get deleted;
/// Create a copy of FileDiff
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileDiffCopyWith<FileDiff> get copyWith => _$FileDiffCopyWithImpl<FileDiff>(this as FileDiff, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileDiff&&(identical(other.path, path) || other.path == path)&&const DeepCollectionEquality().equals(other.hunks, hunks)&&(identical(other.isBinary, isBinary) || other.isBinary == isBinary)&&(identical(other.added, added) || other.added == added)&&(identical(other.deleted, deleted) || other.deleted == deleted));
}


@override
int get hashCode => Object.hash(runtimeType,path,const DeepCollectionEquality().hash(hunks),isBinary,added,deleted);

@override
String toString() {
  return 'FileDiff(path: $path, hunks: $hunks, isBinary: $isBinary, added: $added, deleted: $deleted)';
}


}

/// @nodoc
abstract mixin class $FileDiffCopyWith<$Res>  {
  factory $FileDiffCopyWith(FileDiff value, $Res Function(FileDiff) _then) = _$FileDiffCopyWithImpl;
@useResult
$Res call({
 String path, List<DiffHunk> hunks, bool isBinary, int added, int deleted
});




}
/// @nodoc
class _$FileDiffCopyWithImpl<$Res>
    implements $FileDiffCopyWith<$Res> {
  _$FileDiffCopyWithImpl(this._self, this._then);

  final FileDiff _self;
  final $Res Function(FileDiff) _then;

/// Create a copy of FileDiff
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? hunks = null,Object? isBinary = null,Object? added = null,Object? deleted = null,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,hunks: null == hunks ? _self.hunks : hunks // ignore: cast_nullable_to_non_nullable
as List<DiffHunk>,isBinary: null == isBinary ? _self.isBinary : isBinary // ignore: cast_nullable_to_non_nullable
as bool,added: null == added ? _self.added : added // ignore: cast_nullable_to_non_nullable
as int,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FileDiff].
extension FileDiffPatterns on FileDiff {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FileDiff value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FileDiff() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FileDiff value)  $default,){
final _that = this;
switch (_that) {
case _FileDiff():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FileDiff value)?  $default,){
final _that = this;
switch (_that) {
case _FileDiff() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  List<DiffHunk> hunks,  bool isBinary,  int added,  int deleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FileDiff() when $default != null:
return $default(_that.path,_that.hunks,_that.isBinary,_that.added,_that.deleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  List<DiffHunk> hunks,  bool isBinary,  int added,  int deleted)  $default,) {final _that = this;
switch (_that) {
case _FileDiff():
return $default(_that.path,_that.hunks,_that.isBinary,_that.added,_that.deleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  List<DiffHunk> hunks,  bool isBinary,  int added,  int deleted)?  $default,) {final _that = this;
switch (_that) {
case _FileDiff() when $default != null:
return $default(_that.path,_that.hunks,_that.isBinary,_that.added,_that.deleted);case _:
  return null;

}
}

}

/// @nodoc


class _FileDiff implements FileDiff {
  const _FileDiff({required this.path, final  List<DiffHunk> hunks = const <DiffHunk>[], this.isBinary = false, this.added = 0, this.deleted = 0}): _hunks = hunks;
  

@override final  String path;
 final  List<DiffHunk> _hunks;
@override@JsonKey() List<DiffHunk> get hunks {
  if (_hunks is EqualUnmodifiableListView) return _hunks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hunks);
}

@override@JsonKey() final  bool isBinary;
@override@JsonKey() final  int added;
@override@JsonKey() final  int deleted;

/// Create a copy of FileDiff
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FileDiffCopyWith<_FileDiff> get copyWith => __$FileDiffCopyWithImpl<_FileDiff>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FileDiff&&(identical(other.path, path) || other.path == path)&&const DeepCollectionEquality().equals(other._hunks, _hunks)&&(identical(other.isBinary, isBinary) || other.isBinary == isBinary)&&(identical(other.added, added) || other.added == added)&&(identical(other.deleted, deleted) || other.deleted == deleted));
}


@override
int get hashCode => Object.hash(runtimeType,path,const DeepCollectionEquality().hash(_hunks),isBinary,added,deleted);

@override
String toString() {
  return 'FileDiff(path: $path, hunks: $hunks, isBinary: $isBinary, added: $added, deleted: $deleted)';
}


}

/// @nodoc
abstract mixin class _$FileDiffCopyWith<$Res> implements $FileDiffCopyWith<$Res> {
  factory _$FileDiffCopyWith(_FileDiff value, $Res Function(_FileDiff) _then) = __$FileDiffCopyWithImpl;
@override @useResult
$Res call({
 String path, List<DiffHunk> hunks, bool isBinary, int added, int deleted
});




}
/// @nodoc
class __$FileDiffCopyWithImpl<$Res>
    implements _$FileDiffCopyWith<$Res> {
  __$FileDiffCopyWithImpl(this._self, this._then);

  final _FileDiff _self;
  final $Res Function(_FileDiff) _then;

/// Create a copy of FileDiff
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? hunks = null,Object? isBinary = null,Object? added = null,Object? deleted = null,}) {
  return _then(_FileDiff(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,hunks: null == hunks ? _self._hunks : hunks // ignore: cast_nullable_to_non_nullable
as List<DiffHunk>,isBinary: null == isBinary ? _self.isBinary : isBinary // ignore: cast_nullable_to_non_nullable
as bool,added: null == added ? _self.added : added // ignore: cast_nullable_to_non_nullable
as int,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
