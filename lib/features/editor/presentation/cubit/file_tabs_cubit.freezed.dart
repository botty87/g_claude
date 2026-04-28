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

 List<String> get openPaths; String? get activePath; String? get previewPath;
/// Create a copy of WorkspaceFiles
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspaceFilesCopyWith<WorkspaceFiles> get copyWith => _$WorkspaceFilesCopyWithImpl<WorkspaceFiles>(this as WorkspaceFiles, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceFiles&&const DeepCollectionEquality().equals(other.openPaths, openPaths)&&(identical(other.activePath, activePath) || other.activePath == activePath)&&(identical(other.previewPath, previewPath) || other.previewPath == previewPath));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(openPaths),activePath,previewPath);

@override
String toString() {
  return 'WorkspaceFiles(openPaths: $openPaths, activePath: $activePath, previewPath: $previewPath)';
}


}

/// @nodoc
abstract mixin class $WorkspaceFilesCopyWith<$Res>  {
  factory $WorkspaceFilesCopyWith(WorkspaceFiles value, $Res Function(WorkspaceFiles) _then) = _$WorkspaceFilesCopyWithImpl;
@useResult
$Res call({
 List<String> openPaths, String? activePath, String? previewPath
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
@pragma('vm:prefer-inline') @override $Res call({Object? openPaths = null,Object? activePath = freezed,Object? previewPath = freezed,}) {
  return _then(_self.copyWith(
openPaths: null == openPaths ? _self.openPaths : openPaths // ignore: cast_nullable_to_non_nullable
as List<String>,activePath: freezed == activePath ? _self.activePath : activePath // ignore: cast_nullable_to_non_nullable
as String?,previewPath: freezed == previewPath ? _self.previewPath : previewPath // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> openPaths,  String? activePath,  String? previewPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkspaceFiles() when $default != null:
return $default(_that.openPaths,_that.activePath,_that.previewPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> openPaths,  String? activePath,  String? previewPath)  $default,) {final _that = this;
switch (_that) {
case _WorkspaceFiles():
return $default(_that.openPaths,_that.activePath,_that.previewPath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> openPaths,  String? activePath,  String? previewPath)?  $default,) {final _that = this;
switch (_that) {
case _WorkspaceFiles() when $default != null:
return $default(_that.openPaths,_that.activePath,_that.previewPath);case _:
  return null;

}
}

}

/// @nodoc


class _WorkspaceFiles implements WorkspaceFiles {
  const _WorkspaceFiles({final  List<String> openPaths = const <String>[], this.activePath, this.previewPath}): _openPaths = openPaths;
  

 final  List<String> _openPaths;
@override@JsonKey() List<String> get openPaths {
  if (_openPaths is EqualUnmodifiableListView) return _openPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_openPaths);
}

@override final  String? activePath;
@override final  String? previewPath;

/// Create a copy of WorkspaceFiles
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkspaceFilesCopyWith<_WorkspaceFiles> get copyWith => __$WorkspaceFilesCopyWithImpl<_WorkspaceFiles>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceFiles&&const DeepCollectionEquality().equals(other._openPaths, _openPaths)&&(identical(other.activePath, activePath) || other.activePath == activePath)&&(identical(other.previewPath, previewPath) || other.previewPath == previewPath));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_openPaths),activePath,previewPath);

@override
String toString() {
  return 'WorkspaceFiles(openPaths: $openPaths, activePath: $activePath, previewPath: $previewPath)';
}


}

/// @nodoc
abstract mixin class _$WorkspaceFilesCopyWith<$Res> implements $WorkspaceFilesCopyWith<$Res> {
  factory _$WorkspaceFilesCopyWith(_WorkspaceFiles value, $Res Function(_WorkspaceFiles) _then) = __$WorkspaceFilesCopyWithImpl;
@override @useResult
$Res call({
 List<String> openPaths, String? activePath, String? previewPath
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
@override @pragma('vm:prefer-inline') $Res call({Object? openPaths = null,Object? activePath = freezed,Object? previewPath = freezed,}) {
  return _then(_WorkspaceFiles(
openPaths: null == openPaths ? _self._openPaths : openPaths // ignore: cast_nullable_to_non_nullable
as List<String>,activePath: freezed == activePath ? _self.activePath : activePath // ignore: cast_nullable_to_non_nullable
as String?,previewPath: freezed == previewPath ? _self.previewPath : previewPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
