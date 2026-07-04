// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'git_diff_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WorkspaceDiff {

 List<GitDiffFile> get files; DiffViewMode get viewMode; bool get loading;// Collapsed directories in tree view. Default (absent) = expanded.
 Set<String> get collapsedDirs; Failure? get failure;
/// Create a copy of WorkspaceDiff
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspaceDiffCopyWith<WorkspaceDiff> get copyWith => _$WorkspaceDiffCopyWithImpl<WorkspaceDiff>(this as WorkspaceDiff, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceDiff&&const DeepCollectionEquality().equals(other.files, files)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode)&&(identical(other.loading, loading) || other.loading == loading)&&const DeepCollectionEquality().equals(other.collapsedDirs, collapsedDirs)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(files),viewMode,loading,const DeepCollectionEquality().hash(collapsedDirs),failure);

@override
String toString() {
  return 'WorkspaceDiff(files: $files, viewMode: $viewMode, loading: $loading, collapsedDirs: $collapsedDirs, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $WorkspaceDiffCopyWith<$Res>  {
  factory $WorkspaceDiffCopyWith(WorkspaceDiff value, $Res Function(WorkspaceDiff) _then) = _$WorkspaceDiffCopyWithImpl;
@useResult
$Res call({
 List<GitDiffFile> files, DiffViewMode viewMode, bool loading, Set<String> collapsedDirs, Failure? failure
});




}
/// @nodoc
class _$WorkspaceDiffCopyWithImpl<$Res>
    implements $WorkspaceDiffCopyWith<$Res> {
  _$WorkspaceDiffCopyWithImpl(this._self, this._then);

  final WorkspaceDiff _self;
  final $Res Function(WorkspaceDiff) _then;

/// Create a copy of WorkspaceDiff
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? files = null,Object? viewMode = null,Object? loading = null,Object? collapsedDirs = null,Object? failure = freezed,}) {
  return _then(_self.copyWith(
files: null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as List<GitDiffFile>,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as DiffViewMode,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,collapsedDirs: null == collapsedDirs ? _self.collapsedDirs : collapsedDirs // ignore: cast_nullable_to_non_nullable
as Set<String>,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkspaceDiff].
extension WorkspaceDiffPatterns on WorkspaceDiff {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkspaceDiff value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkspaceDiff() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkspaceDiff value)  $default,){
final _that = this;
switch (_that) {
case _WorkspaceDiff():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkspaceDiff value)?  $default,){
final _that = this;
switch (_that) {
case _WorkspaceDiff() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<GitDiffFile> files,  DiffViewMode viewMode,  bool loading,  Set<String> collapsedDirs,  Failure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkspaceDiff() when $default != null:
return $default(_that.files,_that.viewMode,_that.loading,_that.collapsedDirs,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<GitDiffFile> files,  DiffViewMode viewMode,  bool loading,  Set<String> collapsedDirs,  Failure? failure)  $default,) {final _that = this;
switch (_that) {
case _WorkspaceDiff():
return $default(_that.files,_that.viewMode,_that.loading,_that.collapsedDirs,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<GitDiffFile> files,  DiffViewMode viewMode,  bool loading,  Set<String> collapsedDirs,  Failure? failure)?  $default,) {final _that = this;
switch (_that) {
case _WorkspaceDiff() when $default != null:
return $default(_that.files,_that.viewMode,_that.loading,_that.collapsedDirs,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _WorkspaceDiff implements WorkspaceDiff {
  const _WorkspaceDiff({final  List<GitDiffFile> files = const <GitDiffFile>[], this.viewMode = DiffViewMode.flat, this.loading = false, final  Set<String> collapsedDirs = const <String>{}, this.failure}): _files = files,_collapsedDirs = collapsedDirs;
  

 final  List<GitDiffFile> _files;
@override@JsonKey() List<GitDiffFile> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}

@override@JsonKey() final  DiffViewMode viewMode;
@override@JsonKey() final  bool loading;
// Collapsed directories in tree view. Default (absent) = expanded.
 final  Set<String> _collapsedDirs;
// Collapsed directories in tree view. Default (absent) = expanded.
@override@JsonKey() Set<String> get collapsedDirs {
  if (_collapsedDirs is EqualUnmodifiableSetView) return _collapsedDirs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_collapsedDirs);
}

@override final  Failure? failure;

/// Create a copy of WorkspaceDiff
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkspaceDiffCopyWith<_WorkspaceDiff> get copyWith => __$WorkspaceDiffCopyWithImpl<_WorkspaceDiff>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceDiff&&const DeepCollectionEquality().equals(other._files, _files)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode)&&(identical(other.loading, loading) || other.loading == loading)&&const DeepCollectionEquality().equals(other._collapsedDirs, _collapsedDirs)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_files),viewMode,loading,const DeepCollectionEquality().hash(_collapsedDirs),failure);

@override
String toString() {
  return 'WorkspaceDiff(files: $files, viewMode: $viewMode, loading: $loading, collapsedDirs: $collapsedDirs, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$WorkspaceDiffCopyWith<$Res> implements $WorkspaceDiffCopyWith<$Res> {
  factory _$WorkspaceDiffCopyWith(_WorkspaceDiff value, $Res Function(_WorkspaceDiff) _then) = __$WorkspaceDiffCopyWithImpl;
@override @useResult
$Res call({
 List<GitDiffFile> files, DiffViewMode viewMode, bool loading, Set<String> collapsedDirs, Failure? failure
});




}
/// @nodoc
class __$WorkspaceDiffCopyWithImpl<$Res>
    implements _$WorkspaceDiffCopyWith<$Res> {
  __$WorkspaceDiffCopyWithImpl(this._self, this._then);

  final _WorkspaceDiff _self;
  final $Res Function(_WorkspaceDiff) _then;

/// Create a copy of WorkspaceDiff
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? files = null,Object? viewMode = null,Object? loading = null,Object? collapsedDirs = null,Object? failure = freezed,}) {
  return _then(_WorkspaceDiff(
files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<GitDiffFile>,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as DiffViewMode,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,collapsedDirs: null == collapsedDirs ? _self._collapsedDirs : collapsedDirs // ignore: cast_nullable_to_non_nullable
as Set<String>,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

/// @nodoc
mixin _$GitDiffState {

 Map<WorkspaceId, WorkspaceDiff> get perWorkspace;
/// Create a copy of GitDiffState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitDiffStateCopyWith<GitDiffState> get copyWith => _$GitDiffStateCopyWithImpl<GitDiffState>(this as GitDiffState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitDiffState&&const DeepCollectionEquality().equals(other.perWorkspace, perWorkspace));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(perWorkspace));

@override
String toString() {
  return 'GitDiffState(perWorkspace: $perWorkspace)';
}


}

/// @nodoc
abstract mixin class $GitDiffStateCopyWith<$Res>  {
  factory $GitDiffStateCopyWith(GitDiffState value, $Res Function(GitDiffState) _then) = _$GitDiffStateCopyWithImpl;
@useResult
$Res call({
 Map<WorkspaceId, WorkspaceDiff> perWorkspace
});




}
/// @nodoc
class _$GitDiffStateCopyWithImpl<$Res>
    implements $GitDiffStateCopyWith<$Res> {
  _$GitDiffStateCopyWithImpl(this._self, this._then);

  final GitDiffState _self;
  final $Res Function(GitDiffState) _then;

/// Create a copy of GitDiffState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? perWorkspace = null,}) {
  return _then(_self.copyWith(
perWorkspace: null == perWorkspace ? _self.perWorkspace : perWorkspace // ignore: cast_nullable_to_non_nullable
as Map<WorkspaceId, WorkspaceDiff>,
  ));
}

}


/// Adds pattern-matching-related methods to [GitDiffState].
extension GitDiffStatePatterns on GitDiffState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitDiffState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitDiffState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitDiffState value)  $default,){
final _that = this;
switch (_that) {
case _GitDiffState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitDiffState value)?  $default,){
final _that = this;
switch (_that) {
case _GitDiffState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<WorkspaceId, WorkspaceDiff> perWorkspace)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitDiffState() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<WorkspaceId, WorkspaceDiff> perWorkspace)  $default,) {final _that = this;
switch (_that) {
case _GitDiffState():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<WorkspaceId, WorkspaceDiff> perWorkspace)?  $default,) {final _that = this;
switch (_that) {
case _GitDiffState() when $default != null:
return $default(_that.perWorkspace);case _:
  return null;

}
}

}

/// @nodoc


class _GitDiffState extends GitDiffState {
  const _GitDiffState({final  Map<WorkspaceId, WorkspaceDiff> perWorkspace = const <WorkspaceId, WorkspaceDiff>{}}): _perWorkspace = perWorkspace,super._();
  

 final  Map<WorkspaceId, WorkspaceDiff> _perWorkspace;
@override@JsonKey() Map<WorkspaceId, WorkspaceDiff> get perWorkspace {
  if (_perWorkspace is EqualUnmodifiableMapView) return _perWorkspace;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_perWorkspace);
}


/// Create a copy of GitDiffState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitDiffStateCopyWith<_GitDiffState> get copyWith => __$GitDiffStateCopyWithImpl<_GitDiffState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitDiffState&&const DeepCollectionEquality().equals(other._perWorkspace, _perWorkspace));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_perWorkspace));

@override
String toString() {
  return 'GitDiffState(perWorkspace: $perWorkspace)';
}


}

/// @nodoc
abstract mixin class _$GitDiffStateCopyWith<$Res> implements $GitDiffStateCopyWith<$Res> {
  factory _$GitDiffStateCopyWith(_GitDiffState value, $Res Function(_GitDiffState) _then) = __$GitDiffStateCopyWithImpl;
@override @useResult
$Res call({
 Map<WorkspaceId, WorkspaceDiff> perWorkspace
});




}
/// @nodoc
class __$GitDiffStateCopyWithImpl<$Res>
    implements _$GitDiffStateCopyWith<$Res> {
  __$GitDiffStateCopyWithImpl(this._self, this._then);

  final _GitDiffState _self;
  final $Res Function(_GitDiffState) _then;

/// Create a copy of GitDiffState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? perWorkspace = null,}) {
  return _then(_GitDiffState(
perWorkspace: null == perWorkspace ? _self._perWorkspace : perWorkspace // ignore: cast_nullable_to_non_nullable
as Map<WorkspaceId, WorkspaceDiff>,
  ));
}


}

// dart format on
