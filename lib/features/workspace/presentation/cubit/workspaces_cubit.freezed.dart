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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( WorkspacesStateInitial value)?  initial,TResult Function( WorkspacesStateLoaded value)?  loaded,TResult Function( WorkspacesStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case WorkspacesStateInitial() when initial != null:
return initial(_that);case WorkspacesStateLoaded() when loaded != null:
return loaded(_that);case WorkspacesStateError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( WorkspacesStateInitial value)  initial,required TResult Function( WorkspacesStateLoaded value)  loaded,required TResult Function( WorkspacesStateError value)  error,}){
final _that = this;
switch (_that) {
case WorkspacesStateInitial():
return initial(_that);case WorkspacesStateLoaded():
return loaded(_that);case WorkspacesStateError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( WorkspacesStateInitial value)?  initial,TResult? Function( WorkspacesStateLoaded value)?  loaded,TResult? Function( WorkspacesStateError value)?  error,}){
final _that = this;
switch (_that) {
case WorkspacesStateInitial() when initial != null:
return initial(_that);case WorkspacesStateLoaded() when loaded != null:
return loaded(_that);case WorkspacesStateError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( List<Workspace> workspaces,  WorkspaceId? activeId)?  loaded,TResult Function( Failure failure,  List<Workspace> workspaces,  WorkspaceId? activeId)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case WorkspacesStateInitial() when initial != null:
return initial();case WorkspacesStateLoaded() when loaded != null:
return loaded(_that.workspaces,_that.activeId);case WorkspacesStateError() when error != null:
return error(_that.failure,_that.workspaces,_that.activeId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( List<Workspace> workspaces,  WorkspaceId? activeId)  loaded,required TResult Function( Failure failure,  List<Workspace> workspaces,  WorkspaceId? activeId)  error,}) {final _that = this;
switch (_that) {
case WorkspacesStateInitial():
return initial();case WorkspacesStateLoaded():
return loaded(_that.workspaces,_that.activeId);case WorkspacesStateError():
return error(_that.failure,_that.workspaces,_that.activeId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( List<Workspace> workspaces,  WorkspaceId? activeId)?  loaded,TResult? Function( Failure failure,  List<Workspace> workspaces,  WorkspaceId? activeId)?  error,}) {final _that = this;
switch (_that) {
case WorkspacesStateInitial() when initial != null:
return initial();case WorkspacesStateLoaded() when loaded != null:
return loaded(_that.workspaces,_that.activeId);case WorkspacesStateError() when error != null:
return error(_that.failure,_that.workspaces,_that.activeId);case _:
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
  const WorkspacesStateLoaded({required final  List<Workspace> workspaces, this.activeId}): _workspaces = workspaces,super._();
  

 final  List<Workspace> _workspaces;
 List<Workspace> get workspaces {
  if (_workspaces is EqualUnmodifiableListView) return _workspaces;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workspaces);
}

 final  WorkspaceId? activeId;

/// Create a copy of WorkspacesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspacesStateLoadedCopyWith<WorkspacesStateLoaded> get copyWith => _$WorkspacesStateLoadedCopyWithImpl<WorkspacesStateLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspacesStateLoaded&&const DeepCollectionEquality().equals(other._workspaces, _workspaces)&&(identical(other.activeId, activeId) || other.activeId == activeId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_workspaces),activeId);

@override
String toString() {
  return 'WorkspacesState.loaded(workspaces: $workspaces, activeId: $activeId)';
}


}

/// @nodoc
abstract mixin class $WorkspacesStateLoadedCopyWith<$Res> implements $WorkspacesStateCopyWith<$Res> {
  factory $WorkspacesStateLoadedCopyWith(WorkspacesStateLoaded value, $Res Function(WorkspacesStateLoaded) _then) = _$WorkspacesStateLoadedCopyWithImpl;
@useResult
$Res call({
 List<Workspace> workspaces, WorkspaceId? activeId
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
@pragma('vm:prefer-inline') $Res call({Object? workspaces = null,Object? activeId = freezed,}) {
  return _then(WorkspacesStateLoaded(
workspaces: null == workspaces ? _self._workspaces : workspaces // ignore: cast_nullable_to_non_nullable
as List<Workspace>,activeId: freezed == activeId ? _self.activeId : activeId // ignore: cast_nullable_to_non_nullable
as WorkspaceId?,
  ));
}


}

/// @nodoc


class WorkspacesStateError extends WorkspacesState {
  const WorkspacesStateError({required this.failure, final  List<Workspace> workspaces = const <Workspace>[], this.activeId}): _workspaces = workspaces,super._();
  

 final  Failure failure;
 final  List<Workspace> _workspaces;
@JsonKey() List<Workspace> get workspaces {
  if (_workspaces is EqualUnmodifiableListView) return _workspaces;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workspaces);
}

 final  WorkspaceId? activeId;

/// Create a copy of WorkspacesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspacesStateErrorCopyWith<WorkspacesStateError> get copyWith => _$WorkspacesStateErrorCopyWithImpl<WorkspacesStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspacesStateError&&(identical(other.failure, failure) || other.failure == failure)&&const DeepCollectionEquality().equals(other._workspaces, _workspaces)&&(identical(other.activeId, activeId) || other.activeId == activeId));
}


@override
int get hashCode => Object.hash(runtimeType,failure,const DeepCollectionEquality().hash(_workspaces),activeId);

@override
String toString() {
  return 'WorkspacesState.error(failure: $failure, workspaces: $workspaces, activeId: $activeId)';
}


}

/// @nodoc
abstract mixin class $WorkspacesStateErrorCopyWith<$Res> implements $WorkspacesStateCopyWith<$Res> {
  factory $WorkspacesStateErrorCopyWith(WorkspacesStateError value, $Res Function(WorkspacesStateError) _then) = _$WorkspacesStateErrorCopyWithImpl;
@useResult
$Res call({
 Failure failure, List<Workspace> workspaces, WorkspaceId? activeId
});




}
/// @nodoc
class _$WorkspacesStateErrorCopyWithImpl<$Res>
    implements $WorkspacesStateErrorCopyWith<$Res> {
  _$WorkspacesStateErrorCopyWithImpl(this._self, this._then);

  final WorkspacesStateError _self;
  final $Res Function(WorkspacesStateError) _then;

/// Create a copy of WorkspacesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,Object? workspaces = null,Object? activeId = freezed,}) {
  return _then(WorkspacesStateError(
failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,workspaces: null == workspaces ? _self._workspaces : workspaces // ignore: cast_nullable_to_non_nullable
as List<Workspace>,activeId: freezed == activeId ? _self.activeId : activeId // ignore: cast_nullable_to_non_nullable
as WorkspaceId?,
  ));
}


}

// dart format on
