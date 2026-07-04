// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_tabs_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FileTabsState {

 Map<WorkspaceId, WorkspaceFiles> get perWorkspace;
/// Create a copy of FileTabsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileTabsStateCopyWith<FileTabsState> get copyWith => _$FileTabsStateCopyWithImpl<FileTabsState>(this as FileTabsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileTabsState&&const DeepCollectionEquality().equals(other.perWorkspace, perWorkspace));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(perWorkspace));

@override
String toString() {
  return 'FileTabsState(perWorkspace: $perWorkspace)';
}


}

/// @nodoc
abstract mixin class $FileTabsStateCopyWith<$Res>  {
  factory $FileTabsStateCopyWith(FileTabsState value, $Res Function(FileTabsState) _then) = _$FileTabsStateCopyWithImpl;
@useResult
$Res call({
 Map<WorkspaceId, WorkspaceFiles> perWorkspace
});




}
/// @nodoc
class _$FileTabsStateCopyWithImpl<$Res>
    implements $FileTabsStateCopyWith<$Res> {
  _$FileTabsStateCopyWithImpl(this._self, this._then);

  final FileTabsState _self;
  final $Res Function(FileTabsState) _then;

/// Create a copy of FileTabsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? perWorkspace = null,}) {
  return _then(_self.copyWith(
perWorkspace: null == perWorkspace ? _self.perWorkspace : perWorkspace // ignore: cast_nullable_to_non_nullable
as Map<WorkspaceId, WorkspaceFiles>,
  ));
}

}


/// Adds pattern-matching-related methods to [FileTabsState].
extension FileTabsStatePatterns on FileTabsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FileTabsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FileTabsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FileTabsState value)  $default,){
final _that = this;
switch (_that) {
case _FileTabsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FileTabsState value)?  $default,){
final _that = this;
switch (_that) {
case _FileTabsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<WorkspaceId, WorkspaceFiles> perWorkspace)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FileTabsState() when $default != null:
return $default(_that.perWorkspace);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<WorkspaceId, WorkspaceFiles> perWorkspace)  $default,) {final _that = this;
switch (_that) {
case _FileTabsState():
return $default(_that.perWorkspace);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<WorkspaceId, WorkspaceFiles> perWorkspace)?  $default,) {final _that = this;
switch (_that) {
case _FileTabsState() when $default != null:
return $default(_that.perWorkspace);case _:
  return null;

}
}

}

/// @nodoc


class _FileTabsState extends FileTabsState {
  const _FileTabsState({final  Map<WorkspaceId, WorkspaceFiles> perWorkspace = const <WorkspaceId, WorkspaceFiles>{}}): _perWorkspace = perWorkspace,super._();
  

 final  Map<WorkspaceId, WorkspaceFiles> _perWorkspace;
@override@JsonKey() Map<WorkspaceId, WorkspaceFiles> get perWorkspace {
  if (_perWorkspace is EqualUnmodifiableMapView) return _perWorkspace;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_perWorkspace);
}


/// Create a copy of FileTabsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FileTabsStateCopyWith<_FileTabsState> get copyWith => __$FileTabsStateCopyWithImpl<_FileTabsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FileTabsState&&const DeepCollectionEquality().equals(other._perWorkspace, _perWorkspace));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_perWorkspace));

@override
String toString() {
  return 'FileTabsState(perWorkspace: $perWorkspace)';
}


}

/// @nodoc
abstract mixin class _$FileTabsStateCopyWith<$Res> implements $FileTabsStateCopyWith<$Res> {
  factory _$FileTabsStateCopyWith(_FileTabsState value, $Res Function(_FileTabsState) _then) = __$FileTabsStateCopyWithImpl;
@override @useResult
$Res call({
 Map<WorkspaceId, WorkspaceFiles> perWorkspace
});




}
/// @nodoc
class __$FileTabsStateCopyWithImpl<$Res>
    implements _$FileTabsStateCopyWith<$Res> {
  __$FileTabsStateCopyWithImpl(this._self, this._then);

  final _FileTabsState _self;
  final $Res Function(_FileTabsState) _then;

/// Create a copy of FileTabsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? perWorkspace = null,}) {
  return _then(_FileTabsState(
perWorkspace: null == perWorkspace ? _self._perWorkspace : perWorkspace // ignore: cast_nullable_to_non_nullable
as Map<WorkspaceId, WorkspaceFiles>,
  ));
}


}

/// @nodoc
mixin _$WorkspaceFiles {

 List<String> get openPaths; String? get activePath; String? get previewPath;// Diff tabs live beside the file tabs in the same "Code" tab strip but are
// ephemeral (derived from git state) — deliberately NOT persisted in
// tabs.v1. [activeDiffId] discriminates the shown surface: when non-null a
// diff tab is active (it wins over [activePath]); opening/activating a file
// tab resets it to null. Identity of a diff tab is its [DiffTabRef.path].
 List<DiffTabRef> get openDiffs; String? get activeDiffId;// Mirrors [previewPath] for diff tabs: a single "preview" diff (shown
// italic) that the next single-click diff replaces in place, until pinned
// (double-click) which clears this to null.
 String? get previewDiffId;
/// Create a copy of WorkspaceFiles
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspaceFilesCopyWith<WorkspaceFiles> get copyWith => _$WorkspaceFilesCopyWithImpl<WorkspaceFiles>(this as WorkspaceFiles, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceFiles&&const DeepCollectionEquality().equals(other.openPaths, openPaths)&&(identical(other.activePath, activePath) || other.activePath == activePath)&&(identical(other.previewPath, previewPath) || other.previewPath == previewPath)&&const DeepCollectionEquality().equals(other.openDiffs, openDiffs)&&(identical(other.activeDiffId, activeDiffId) || other.activeDiffId == activeDiffId)&&(identical(other.previewDiffId, previewDiffId) || other.previewDiffId == previewDiffId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(openPaths),activePath,previewPath,const DeepCollectionEquality().hash(openDiffs),activeDiffId,previewDiffId);

@override
String toString() {
  return 'WorkspaceFiles(openPaths: $openPaths, activePath: $activePath, previewPath: $previewPath, openDiffs: $openDiffs, activeDiffId: $activeDiffId, previewDiffId: $previewDiffId)';
}


}

/// @nodoc
abstract mixin class $WorkspaceFilesCopyWith<$Res>  {
  factory $WorkspaceFilesCopyWith(WorkspaceFiles value, $Res Function(WorkspaceFiles) _then) = _$WorkspaceFilesCopyWithImpl;
@useResult
$Res call({
 List<String> openPaths, String? activePath, String? previewPath, List<DiffTabRef> openDiffs, String? activeDiffId, String? previewDiffId
});




}
/// @nodoc
class _$WorkspaceFilesCopyWithImpl<$Res>
    implements $WorkspaceFilesCopyWith<$Res> {
  _$WorkspaceFilesCopyWithImpl(this._self, this._then);

  final WorkspaceFiles _self;
  final $Res Function(WorkspaceFiles) _then;

/// Create a copy of WorkspaceFiles
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? openPaths = null,Object? activePath = freezed,Object? previewPath = freezed,Object? openDiffs = null,Object? activeDiffId = freezed,Object? previewDiffId = freezed,}) {
  return _then(_self.copyWith(
openPaths: null == openPaths ? _self.openPaths : openPaths // ignore: cast_nullable_to_non_nullable
as List<String>,activePath: freezed == activePath ? _self.activePath : activePath // ignore: cast_nullable_to_non_nullable
as String?,previewPath: freezed == previewPath ? _self.previewPath : previewPath // ignore: cast_nullable_to_non_nullable
as String?,openDiffs: null == openDiffs ? _self.openDiffs : openDiffs // ignore: cast_nullable_to_non_nullable
as List<DiffTabRef>,activeDiffId: freezed == activeDiffId ? _self.activeDiffId : activeDiffId // ignore: cast_nullable_to_non_nullable
as String?,previewDiffId: freezed == previewDiffId ? _self.previewDiffId : previewDiffId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkspaceFiles].
extension WorkspaceFilesPatterns on WorkspaceFiles {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkspaceFiles value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkspaceFiles() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkspaceFiles value)  $default,){
final _that = this;
switch (_that) {
case _WorkspaceFiles():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkspaceFiles value)?  $default,){
final _that = this;
switch (_that) {
case _WorkspaceFiles() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> openPaths,  String? activePath,  String? previewPath,  List<DiffTabRef> openDiffs,  String? activeDiffId,  String? previewDiffId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkspaceFiles() when $default != null:
return $default(_that.openPaths,_that.activePath,_that.previewPath,_that.openDiffs,_that.activeDiffId,_that.previewDiffId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> openPaths,  String? activePath,  String? previewPath,  List<DiffTabRef> openDiffs,  String? activeDiffId,  String? previewDiffId)  $default,) {final _that = this;
switch (_that) {
case _WorkspaceFiles():
return $default(_that.openPaths,_that.activePath,_that.previewPath,_that.openDiffs,_that.activeDiffId,_that.previewDiffId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> openPaths,  String? activePath,  String? previewPath,  List<DiffTabRef> openDiffs,  String? activeDiffId,  String? previewDiffId)?  $default,) {final _that = this;
switch (_that) {
case _WorkspaceFiles() when $default != null:
return $default(_that.openPaths,_that.activePath,_that.previewPath,_that.openDiffs,_that.activeDiffId,_that.previewDiffId);case _:
  return null;

}
}

}

/// @nodoc


class _WorkspaceFiles implements WorkspaceFiles {
  const _WorkspaceFiles({final  List<String> openPaths = const <String>[], this.activePath, this.previewPath, final  List<DiffTabRef> openDiffs = const <DiffTabRef>[], this.activeDiffId, this.previewDiffId}): _openPaths = openPaths,_openDiffs = openDiffs;
  

 final  List<String> _openPaths;
@override@JsonKey() List<String> get openPaths {
  if (_openPaths is EqualUnmodifiableListView) return _openPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_openPaths);
}

@override final  String? activePath;
@override final  String? previewPath;
// Diff tabs live beside the file tabs in the same "Code" tab strip but are
// ephemeral (derived from git state) — deliberately NOT persisted in
// tabs.v1. [activeDiffId] discriminates the shown surface: when non-null a
// diff tab is active (it wins over [activePath]); opening/activating a file
// tab resets it to null. Identity of a diff tab is its [DiffTabRef.path].
 final  List<DiffTabRef> _openDiffs;
// Diff tabs live beside the file tabs in the same "Code" tab strip but are
// ephemeral (derived from git state) — deliberately NOT persisted in
// tabs.v1. [activeDiffId] discriminates the shown surface: when non-null a
// diff tab is active (it wins over [activePath]); opening/activating a file
// tab resets it to null. Identity of a diff tab is its [DiffTabRef.path].
@override@JsonKey() List<DiffTabRef> get openDiffs {
  if (_openDiffs is EqualUnmodifiableListView) return _openDiffs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_openDiffs);
}

@override final  String? activeDiffId;
// Mirrors [previewPath] for diff tabs: a single "preview" diff (shown
// italic) that the next single-click diff replaces in place, until pinned
// (double-click) which clears this to null.
@override final  String? previewDiffId;

/// Create a copy of WorkspaceFiles
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkspaceFilesCopyWith<_WorkspaceFiles> get copyWith => __$WorkspaceFilesCopyWithImpl<_WorkspaceFiles>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceFiles&&const DeepCollectionEquality().equals(other._openPaths, _openPaths)&&(identical(other.activePath, activePath) || other.activePath == activePath)&&(identical(other.previewPath, previewPath) || other.previewPath == previewPath)&&const DeepCollectionEquality().equals(other._openDiffs, _openDiffs)&&(identical(other.activeDiffId, activeDiffId) || other.activeDiffId == activeDiffId)&&(identical(other.previewDiffId, previewDiffId) || other.previewDiffId == previewDiffId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_openPaths),activePath,previewPath,const DeepCollectionEquality().hash(_openDiffs),activeDiffId,previewDiffId);

@override
String toString() {
  return 'WorkspaceFiles(openPaths: $openPaths, activePath: $activePath, previewPath: $previewPath, openDiffs: $openDiffs, activeDiffId: $activeDiffId, previewDiffId: $previewDiffId)';
}


}

/// @nodoc
abstract mixin class _$WorkspaceFilesCopyWith<$Res> implements $WorkspaceFilesCopyWith<$Res> {
  factory _$WorkspaceFilesCopyWith(_WorkspaceFiles value, $Res Function(_WorkspaceFiles) _then) = __$WorkspaceFilesCopyWithImpl;
@override @useResult
$Res call({
 List<String> openPaths, String? activePath, String? previewPath, List<DiffTabRef> openDiffs, String? activeDiffId, String? previewDiffId
});




}
/// @nodoc
class __$WorkspaceFilesCopyWithImpl<$Res>
    implements _$WorkspaceFilesCopyWith<$Res> {
  __$WorkspaceFilesCopyWithImpl(this._self, this._then);

  final _WorkspaceFiles _self;
  final $Res Function(_WorkspaceFiles) _then;

/// Create a copy of WorkspaceFiles
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? openPaths = null,Object? activePath = freezed,Object? previewPath = freezed,Object? openDiffs = null,Object? activeDiffId = freezed,Object? previewDiffId = freezed,}) {
  return _then(_WorkspaceFiles(
openPaths: null == openPaths ? _self._openPaths : openPaths // ignore: cast_nullable_to_non_nullable
as List<String>,activePath: freezed == activePath ? _self.activePath : activePath // ignore: cast_nullable_to_non_nullable
as String?,previewPath: freezed == previewPath ? _self.previewPath : previewPath // ignore: cast_nullable_to_non_nullable
as String?,openDiffs: null == openDiffs ? _self._openDiffs : openDiffs // ignore: cast_nullable_to_non_nullable
as List<DiffTabRef>,activeDiffId: freezed == activeDiffId ? _self.activeDiffId : activeDiffId // ignore: cast_nullable_to_non_nullable
as String?,previewDiffId: freezed == previewDiffId ? _self.previewDiffId : previewDiffId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$DiffTabRef {

 String get path; GitFileStatus get status; int get added; int get deleted;
/// Create a copy of DiffTabRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiffTabRefCopyWith<DiffTabRef> get copyWith => _$DiffTabRefCopyWithImpl<DiffTabRef>(this as DiffTabRef, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiffTabRef&&(identical(other.path, path) || other.path == path)&&(identical(other.status, status) || other.status == status)&&(identical(other.added, added) || other.added == added)&&(identical(other.deleted, deleted) || other.deleted == deleted));
}


@override
int get hashCode => Object.hash(runtimeType,path,status,added,deleted);

@override
String toString() {
  return 'DiffTabRef(path: $path, status: $status, added: $added, deleted: $deleted)';
}


}

/// @nodoc
abstract mixin class $DiffTabRefCopyWith<$Res>  {
  factory $DiffTabRefCopyWith(DiffTabRef value, $Res Function(DiffTabRef) _then) = _$DiffTabRefCopyWithImpl;
@useResult
$Res call({
 String path, GitFileStatus status, int added, int deleted
});




}
/// @nodoc
class _$DiffTabRefCopyWithImpl<$Res>
    implements $DiffTabRefCopyWith<$Res> {
  _$DiffTabRefCopyWithImpl(this._self, this._then);

  final DiffTabRef _self;
  final $Res Function(DiffTabRef) _then;

/// Create a copy of DiffTabRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? status = null,Object? added = null,Object? deleted = null,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GitFileStatus,added: null == added ? _self.added : added // ignore: cast_nullable_to_non_nullable
as int,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DiffTabRef].
extension DiffTabRefPatterns on DiffTabRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiffTabRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiffTabRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiffTabRef value)  $default,){
final _that = this;
switch (_that) {
case _DiffTabRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiffTabRef value)?  $default,){
final _that = this;
switch (_that) {
case _DiffTabRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  GitFileStatus status,  int added,  int deleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiffTabRef() when $default != null:
return $default(_that.path,_that.status,_that.added,_that.deleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  GitFileStatus status,  int added,  int deleted)  $default,) {final _that = this;
switch (_that) {
case _DiffTabRef():
return $default(_that.path,_that.status,_that.added,_that.deleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  GitFileStatus status,  int added,  int deleted)?  $default,) {final _that = this;
switch (_that) {
case _DiffTabRef() when $default != null:
return $default(_that.path,_that.status,_that.added,_that.deleted);case _:
  return null;

}
}

}

/// @nodoc


class _DiffTabRef implements DiffTabRef {
  const _DiffTabRef({required this.path, required this.status, this.added = 0, this.deleted = 0});
  

@override final  String path;
@override final  GitFileStatus status;
@override@JsonKey() final  int added;
@override@JsonKey() final  int deleted;

/// Create a copy of DiffTabRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiffTabRefCopyWith<_DiffTabRef> get copyWith => __$DiffTabRefCopyWithImpl<_DiffTabRef>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiffTabRef&&(identical(other.path, path) || other.path == path)&&(identical(other.status, status) || other.status == status)&&(identical(other.added, added) || other.added == added)&&(identical(other.deleted, deleted) || other.deleted == deleted));
}


@override
int get hashCode => Object.hash(runtimeType,path,status,added,deleted);

@override
String toString() {
  return 'DiffTabRef(path: $path, status: $status, added: $added, deleted: $deleted)';
}


}

/// @nodoc
abstract mixin class _$DiffTabRefCopyWith<$Res> implements $DiffTabRefCopyWith<$Res> {
  factory _$DiffTabRefCopyWith(_DiffTabRef value, $Res Function(_DiffTabRef) _then) = __$DiffTabRefCopyWithImpl;
@override @useResult
$Res call({
 String path, GitFileStatus status, int added, int deleted
});




}
/// @nodoc
class __$DiffTabRefCopyWithImpl<$Res>
    implements _$DiffTabRefCopyWith<$Res> {
  __$DiffTabRefCopyWithImpl(this._self, this._then);

  final _DiffTabRef _self;
  final $Res Function(_DiffTabRef) _then;

/// Create a copy of DiffTabRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? status = null,Object? added = null,Object? deleted = null,}) {
  return _then(_DiffTabRef(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GitFileStatus,added: null == added ? _self.added : added // ignore: cast_nullable_to_non_nullable
as int,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
