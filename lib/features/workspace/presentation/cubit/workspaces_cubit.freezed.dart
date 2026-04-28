// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workspaces_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WorkspacesState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspacesState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WorkspacesState()';
}


}

/// @nodoc
class $WorkspacesStateCopyWith<$Res>  {
$WorkspacesStateCopyWith(WorkspacesState _, $Res Function(WorkspacesState) __);
}


/// Adds pattern-matching-related methods to [WorkspacesState].
extension WorkspacesStatePatterns on WorkspacesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( WorkspacesStateInitial value)?  initial,TResult Function( WorkspacesStateLoaded value)?  loaded,required TResult orElse(),}){
final _that = this;
switch (_that) {
case WorkspacesStateInitial() when initial != null:
return initial(_that);case WorkspacesStateLoaded() when loaded != null:
return loaded(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( WorkspacesStateInitial value)  initial,required TResult Function( WorkspacesStateLoaded value)  loaded,}){
final _that = this;
switch (_that) {
case WorkspacesStateInitial():
return initial(_that);case WorkspacesStateLoaded():
return loaded(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( WorkspacesStateInitial value)?  initial,TResult? Function( WorkspacesStateLoaded value)?  loaded,}){
final _that = this;
switch (_that) {
case WorkspacesStateInitial() when initial != null:
return initial(_that);case WorkspacesStateLoaded() when loaded != null:
return loaded(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( List<Workspace> workspaces,  WorkspaceId? activeId,  Failure? lastFailure)?  loaded,required TResult orElse(),}) {final _that = this;
switch (_that) {
case WorkspacesStateInitial() when initial != null:
return initial();case WorkspacesStateLoaded() when loaded != null:
return loaded(_that.workspaces,_that.activeId,_that.lastFailure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( List<Workspace> workspaces,  WorkspaceId? activeId,  Failure? lastFailure)  loaded,}) {final _that = this;
switch (_that) {
case WorkspacesStateInitial():
return initial();case WorkspacesStateLoaded():
return loaded(_that.workspaces,_that.activeId,_that.lastFailure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( List<Workspace> workspaces,  WorkspaceId? activeId,  Failure? lastFailure)?  loaded,}) {final _that = this;
switch (_that) {
case WorkspacesStateInitial() when initial != null:
return initial();case WorkspacesStateLoaded() when loaded != null:
return loaded(_that.workspaces,_that.activeId,_that.lastFailure);case _:
  return null;

}
}

}

/// @nodoc


class WorkspacesStateInitial extends WorkspacesState {
  const WorkspacesStateInitial(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspacesStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WorkspacesState.initial()';
}


}




/// @nodoc


class WorkspacesStateLoaded extends WorkspacesState {
  const WorkspacesStateLoaded({final  List<Workspace> workspaces = const <Workspace>[], this.activeId, this.lastFailure}): _workspaces = workspaces,super._();
  

 final  List<Workspace> _workspaces;
@JsonKey() List<Workspace> get workspaces {
  if (_workspaces is EqualUnmodifiableListView) return _workspaces;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workspaces);
}

 final  WorkspaceId? activeId;
 final  Failure? lastFailure;

/// Create a copy of WorkspacesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspacesStateLoadedCopyWith<WorkspacesStateLoaded> get copyWith => _$WorkspacesStateLoadedCopyWithImpl<WorkspacesStateLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspacesStateLoaded&&const DeepCollectionEquality().equals(other._workspaces, _workspaces)&&(identical(other.activeId, activeId) || other.activeId == activeId)&&(identical(other.lastFailure, lastFailure) || other.lastFailure == lastFailure));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_workspaces),activeId,lastFailure);

@override
String toString() {
  return 'WorkspacesState.loaded(workspaces: $workspaces, activeId: $activeId, lastFailure: $lastFailure)';
}


}

/// @nodoc
abstract mixin class $WorkspacesStateLoadedCopyWith<$Res> implements $WorkspacesStateCopyWith<$Res> {
  factory $WorkspacesStateLoadedCopyWith(WorkspacesStateLoaded value, $Res Function(WorkspacesStateLoaded) _then) = _$WorkspacesStateLoadedCopyWithImpl;
@useResult
$Res call({
 List<Workspace> workspaces, WorkspaceId? activeId, Failure? lastFailure
});




}
/// @nodoc
class _$WorkspacesStateLoadedCopyWithImpl<$Res>
    implements $WorkspacesStateLoadedCopyWith<$Res> {
  _$WorkspacesStateLoadedCopyWithImpl(this._self, this._then);

  final WorkspacesStateLoaded _self;
  final $Res Function(WorkspacesStateLoaded) _then;

/// Create a copy of WorkspacesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? workspaces = null,Object? activeId = freezed,Object? lastFailure = freezed,}) {
  return _then(WorkspacesStateLoaded(
workspaces: null == workspaces ? _self._workspaces : workspaces // ignore: cast_nullable_to_non_nullable
as List<Workspace>,activeId: freezed == activeId ? _self.activeId : activeId // ignore: cast_nullable_to_non_nullable
as WorkspaceId?,lastFailure: freezed == lastFailure ? _self.lastFailure : lastFailure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

// dart format on
