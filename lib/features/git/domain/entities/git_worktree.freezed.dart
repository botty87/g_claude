// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'git_worktree.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GitWorktree {

 String get path; String get head; String? get branch; bool get isBare; bool get isDetached;
/// Create a copy of GitWorktree
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitWorktreeCopyWith<GitWorktree> get copyWith => _$GitWorktreeCopyWithImpl<GitWorktree>(this as GitWorktree, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitWorktree&&(identical(other.path, path) || other.path == path)&&(identical(other.head, head) || other.head == head)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.isBare, isBare) || other.isBare == isBare)&&(identical(other.isDetached, isDetached) || other.isDetached == isDetached));
}


@override
int get hashCode => Object.hash(runtimeType,path,head,branch,isBare,isDetached);

@override
String toString() {
  return 'GitWorktree(path: $path, head: $head, branch: $branch, isBare: $isBare, isDetached: $isDetached)';
}


}

/// @nodoc
abstract mixin class $GitWorktreeCopyWith<$Res>  {
  factory $GitWorktreeCopyWith(GitWorktree value, $Res Function(GitWorktree) _then) = _$GitWorktreeCopyWithImpl;
@useResult
$Res call({
 String path, String head, String? branch, bool isBare, bool isDetached
});




}
/// @nodoc
class _$GitWorktreeCopyWithImpl<$Res>
    implements $GitWorktreeCopyWith<$Res> {
  _$GitWorktreeCopyWithImpl(this._self, this._then);

  final GitWorktree _self;
  final $Res Function(GitWorktree) _then;

/// Create a copy of GitWorktree
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? head = null,Object? branch = freezed,Object? isBare = null,Object? isDetached = null,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,head: null == head ? _self.head : head // ignore: cast_nullable_to_non_nullable
as String,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,isBare: null == isBare ? _self.isBare : isBare // ignore: cast_nullable_to_non_nullable
as bool,isDetached: null == isDetached ? _self.isDetached : isDetached // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GitWorktree].
extension GitWorktreePatterns on GitWorktree {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitWorktree value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitWorktree() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitWorktree value)  $default,){
final _that = this;
switch (_that) {
case _GitWorktree():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitWorktree value)?  $default,){
final _that = this;
switch (_that) {
case _GitWorktree() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  String head,  String? branch,  bool isBare,  bool isDetached)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitWorktree() when $default != null:
return $default(_that.path,_that.head,_that.branch,_that.isBare,_that.isDetached);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  String head,  String? branch,  bool isBare,  bool isDetached)  $default,) {final _that = this;
switch (_that) {
case _GitWorktree():
return $default(_that.path,_that.head,_that.branch,_that.isBare,_that.isDetached);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  String head,  String? branch,  bool isBare,  bool isDetached)?  $default,) {final _that = this;
switch (_that) {
case _GitWorktree() when $default != null:
return $default(_that.path,_that.head,_that.branch,_that.isBare,_that.isDetached);case _:
  return null;

}
}

}

/// @nodoc


class _GitWorktree implements GitWorktree {
  const _GitWorktree({required this.path, required this.head, this.branch, this.isBare = false, this.isDetached = false});
  

@override final  String path;
@override final  String head;
@override final  String? branch;
@override@JsonKey() final  bool isBare;
@override@JsonKey() final  bool isDetached;

/// Create a copy of GitWorktree
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitWorktreeCopyWith<_GitWorktree> get copyWith => __$GitWorktreeCopyWithImpl<_GitWorktree>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitWorktree&&(identical(other.path, path) || other.path == path)&&(identical(other.head, head) || other.head == head)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.isBare, isBare) || other.isBare == isBare)&&(identical(other.isDetached, isDetached) || other.isDetached == isDetached));
}


@override
int get hashCode => Object.hash(runtimeType,path,head,branch,isBare,isDetached);

@override
String toString() {
  return 'GitWorktree(path: $path, head: $head, branch: $branch, isBare: $isBare, isDetached: $isDetached)';
}


}

/// @nodoc
abstract mixin class _$GitWorktreeCopyWith<$Res> implements $GitWorktreeCopyWith<$Res> {
  factory _$GitWorktreeCopyWith(_GitWorktree value, $Res Function(_GitWorktree) _then) = __$GitWorktreeCopyWithImpl;
@override @useResult
$Res call({
 String path, String head, String? branch, bool isBare, bool isDetached
});




}
/// @nodoc
class __$GitWorktreeCopyWithImpl<$Res>
    implements _$GitWorktreeCopyWith<$Res> {
  __$GitWorktreeCopyWithImpl(this._self, this._then);

  final _GitWorktree _self;
  final $Res Function(_GitWorktree) _then;

/// Create a copy of GitWorktree
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? head = null,Object? branch = freezed,Object? isBare = null,Object? isDetached = null,}) {
  return _then(_GitWorktree(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,head: null == head ? _self.head : head // ignore: cast_nullable_to_non_nullable
as String,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,isBare: null == isBare ? _self.isBare : isBare // ignore: cast_nullable_to_non_nullable
as bool,isDetached: null == isDetached ? _self.isDetached : isDetached // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$GitRepoInfo {

 String get repoRoot; String? get branch;
/// Create a copy of GitRepoInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitRepoInfoCopyWith<GitRepoInfo> get copyWith => _$GitRepoInfoCopyWithImpl<GitRepoInfo>(this as GitRepoInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitRepoInfo&&(identical(other.repoRoot, repoRoot) || other.repoRoot == repoRoot)&&(identical(other.branch, branch) || other.branch == branch));
}


@override
int get hashCode => Object.hash(runtimeType,repoRoot,branch);

@override
String toString() {
  return 'GitRepoInfo(repoRoot: $repoRoot, branch: $branch)';
}


}

/// @nodoc
abstract mixin class $GitRepoInfoCopyWith<$Res>  {
  factory $GitRepoInfoCopyWith(GitRepoInfo value, $Res Function(GitRepoInfo) _then) = _$GitRepoInfoCopyWithImpl;
@useResult
$Res call({
 String repoRoot, String? branch
});




}
/// @nodoc
class _$GitRepoInfoCopyWithImpl<$Res>
    implements $GitRepoInfoCopyWith<$Res> {
  _$GitRepoInfoCopyWithImpl(this._self, this._then);

  final GitRepoInfo _self;
  final $Res Function(GitRepoInfo) _then;

/// Create a copy of GitRepoInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? repoRoot = null,Object? branch = freezed,}) {
  return _then(_self.copyWith(
repoRoot: null == repoRoot ? _self.repoRoot : repoRoot // ignore: cast_nullable_to_non_nullable
as String,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GitRepoInfo].
extension GitRepoInfoPatterns on GitRepoInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitRepoInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitRepoInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitRepoInfo value)  $default,){
final _that = this;
switch (_that) {
case _GitRepoInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitRepoInfo value)?  $default,){
final _that = this;
switch (_that) {
case _GitRepoInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String repoRoot,  String? branch)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitRepoInfo() when $default != null:
return $default(_that.repoRoot,_that.branch);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String repoRoot,  String? branch)  $default,) {final _that = this;
switch (_that) {
case _GitRepoInfo():
return $default(_that.repoRoot,_that.branch);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String repoRoot,  String? branch)?  $default,) {final _that = this;
switch (_that) {
case _GitRepoInfo() when $default != null:
return $default(_that.repoRoot,_that.branch);case _:
  return null;

}
}

}

/// @nodoc


class _GitRepoInfo implements GitRepoInfo {
  const _GitRepoInfo({required this.repoRoot, this.branch});
  

@override final  String repoRoot;
@override final  String? branch;

/// Create a copy of GitRepoInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitRepoInfoCopyWith<_GitRepoInfo> get copyWith => __$GitRepoInfoCopyWithImpl<_GitRepoInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitRepoInfo&&(identical(other.repoRoot, repoRoot) || other.repoRoot == repoRoot)&&(identical(other.branch, branch) || other.branch == branch));
}


@override
int get hashCode => Object.hash(runtimeType,repoRoot,branch);

@override
String toString() {
  return 'GitRepoInfo(repoRoot: $repoRoot, branch: $branch)';
}


}

/// @nodoc
abstract mixin class _$GitRepoInfoCopyWith<$Res> implements $GitRepoInfoCopyWith<$Res> {
  factory _$GitRepoInfoCopyWith(_GitRepoInfo value, $Res Function(_GitRepoInfo) _then) = __$GitRepoInfoCopyWithImpl;
@override @useResult
$Res call({
 String repoRoot, String? branch
});




}
/// @nodoc
class __$GitRepoInfoCopyWithImpl<$Res>
    implements _$GitRepoInfoCopyWith<$Res> {
  __$GitRepoInfoCopyWithImpl(this._self, this._then);

  final _GitRepoInfo _self;
  final $Res Function(_GitRepoInfo) _then;

/// Create a copy of GitRepoInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? repoRoot = null,Object? branch = freezed,}) {
  return _then(_GitRepoInfo(
repoRoot: null == repoRoot ? _self.repoRoot : repoRoot // ignore: cast_nullable_to_non_nullable
as String,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
