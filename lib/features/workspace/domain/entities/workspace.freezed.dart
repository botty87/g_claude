// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workspace.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Workspace {

 WorkspaceId get id; String get path; String get name; String? get claudeMd; List<SessionId> get sessionIds; SessionId? get activeSessionId; DateTime get openedAt;
/// Create a copy of Workspace
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspaceCopyWith<Workspace> get copyWith => _$WorkspaceCopyWithImpl<Workspace>(this as Workspace, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Workspace&&(identical(other.id, id) || other.id == id)&&(identical(other.path, path) || other.path == path)&&(identical(other.name, name) || other.name == name)&&(identical(other.claudeMd, claudeMd) || other.claudeMd == claudeMd)&&const DeepCollectionEquality().equals(other.sessionIds, sessionIds)&&(identical(other.activeSessionId, activeSessionId) || other.activeSessionId == activeSessionId)&&(identical(other.openedAt, openedAt) || other.openedAt == openedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,path,name,claudeMd,const DeepCollectionEquality().hash(sessionIds),activeSessionId,openedAt);

@override
String toString() {
  return 'Workspace(id: $id, path: $path, name: $name, claudeMd: $claudeMd, sessionIds: $sessionIds, activeSessionId: $activeSessionId, openedAt: $openedAt)';
}


}

/// @nodoc
abstract mixin class $WorkspaceCopyWith<$Res>  {
  factory $WorkspaceCopyWith(Workspace value, $Res Function(Workspace) _then) = _$WorkspaceCopyWithImpl;
@useResult
$Res call({
 WorkspaceId id, String path, String name, String? claudeMd, List<SessionId> sessionIds, SessionId? activeSessionId, DateTime openedAt
});




}
/// @nodoc
class _$WorkspaceCopyWithImpl<$Res>
    implements $WorkspaceCopyWith<$Res> {
  _$WorkspaceCopyWithImpl(this._self, this._then);

  final Workspace _self;
  final $Res Function(Workspace) _then;

/// Create a copy of Workspace
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? path = null,Object? name = null,Object? claudeMd = freezed,Object? sessionIds = null,Object? activeSessionId = freezed,Object? openedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as WorkspaceId,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,claudeMd: freezed == claudeMd ? _self.claudeMd : claudeMd // ignore: cast_nullable_to_non_nullable
as String?,sessionIds: null == sessionIds ? _self.sessionIds : sessionIds // ignore: cast_nullable_to_non_nullable
as List<SessionId>,activeSessionId: freezed == activeSessionId ? _self.activeSessionId : activeSessionId // ignore: cast_nullable_to_non_nullable
as SessionId?,openedAt: null == openedAt ? _self.openedAt : openedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Workspace].
extension WorkspacePatterns on Workspace {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Workspace value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Workspace() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Workspace value)  $default,){
final _that = this;
switch (_that) {
case _Workspace():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Workspace value)?  $default,){
final _that = this;
switch (_that) {
case _Workspace() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WorkspaceId id,  String path,  String name,  String? claudeMd,  List<SessionId> sessionIds,  SessionId? activeSessionId,  DateTime openedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Workspace() when $default != null:
return $default(_that.id,_that.path,_that.name,_that.claudeMd,_that.sessionIds,_that.activeSessionId,_that.openedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WorkspaceId id,  String path,  String name,  String? claudeMd,  List<SessionId> sessionIds,  SessionId? activeSessionId,  DateTime openedAt)  $default,) {final _that = this;
switch (_that) {
case _Workspace():
return $default(_that.id,_that.path,_that.name,_that.claudeMd,_that.sessionIds,_that.activeSessionId,_that.openedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WorkspaceId id,  String path,  String name,  String? claudeMd,  List<SessionId> sessionIds,  SessionId? activeSessionId,  DateTime openedAt)?  $default,) {final _that = this;
switch (_that) {
case _Workspace() when $default != null:
return $default(_that.id,_that.path,_that.name,_that.claudeMd,_that.sessionIds,_that.activeSessionId,_that.openedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Workspace implements Workspace {
  const _Workspace({required this.id, required this.path, required this.name, this.claudeMd, final  List<SessionId> sessionIds = const <SessionId>[], this.activeSessionId, required this.openedAt}): _sessionIds = sessionIds;
  

@override final  WorkspaceId id;
@override final  String path;
@override final  String name;
@override final  String? claudeMd;
 final  List<SessionId> _sessionIds;
@override@JsonKey() List<SessionId> get sessionIds {
  if (_sessionIds is EqualUnmodifiableListView) return _sessionIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sessionIds);
}

@override final  SessionId? activeSessionId;
@override final  DateTime openedAt;

/// Create a copy of Workspace
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkspaceCopyWith<_Workspace> get copyWith => __$WorkspaceCopyWithImpl<_Workspace>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Workspace&&(identical(other.id, id) || other.id == id)&&(identical(other.path, path) || other.path == path)&&(identical(other.name, name) || other.name == name)&&(identical(other.claudeMd, claudeMd) || other.claudeMd == claudeMd)&&const DeepCollectionEquality().equals(other._sessionIds, _sessionIds)&&(identical(other.activeSessionId, activeSessionId) || other.activeSessionId == activeSessionId)&&(identical(other.openedAt, openedAt) || other.openedAt == openedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,path,name,claudeMd,const DeepCollectionEquality().hash(_sessionIds),activeSessionId,openedAt);

@override
String toString() {
  return 'Workspace(id: $id, path: $path, name: $name, claudeMd: $claudeMd, sessionIds: $sessionIds, activeSessionId: $activeSessionId, openedAt: $openedAt)';
}


}

/// @nodoc
abstract mixin class _$WorkspaceCopyWith<$Res> implements $WorkspaceCopyWith<$Res> {
  factory _$WorkspaceCopyWith(_Workspace value, $Res Function(_Workspace) _then) = __$WorkspaceCopyWithImpl;
@override @useResult
$Res call({
 WorkspaceId id, String path, String name, String? claudeMd, List<SessionId> sessionIds, SessionId? activeSessionId, DateTime openedAt
});




}
/// @nodoc
class __$WorkspaceCopyWithImpl<$Res>
    implements _$WorkspaceCopyWith<$Res> {
  __$WorkspaceCopyWithImpl(this._self, this._then);

  final _Workspace _self;
  final $Res Function(_Workspace) _then;

/// Create a copy of Workspace
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? path = null,Object? name = null,Object? claudeMd = freezed,Object? sessionIds = null,Object? activeSessionId = freezed,Object? openedAt = null,}) {
  return _then(_Workspace(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as WorkspaceId,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,claudeMd: freezed == claudeMd ? _self.claudeMd : claudeMd // ignore: cast_nullable_to_non_nullable
as String?,sessionIds: null == sessionIds ? _self._sessionIds : sessionIds // ignore: cast_nullable_to_non_nullable
as List<SessionId>,activeSessionId: freezed == activeSessionId ? _self.activeSessionId : activeSessionId // ignore: cast_nullable_to_non_nullable
as SessionId?,openedAt: null == openedAt ? _self.openedAt : openedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
