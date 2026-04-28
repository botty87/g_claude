// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'explorer_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExplorerState {

 Map<WorkspaceId, WorkspaceTree> get trees; bool get showHidden;
/// Create a copy of ExplorerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExplorerStateCopyWith<ExplorerState> get copyWith => _$ExplorerStateCopyWithImpl<ExplorerState>(this as ExplorerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExplorerState&&const DeepCollectionEquality().equals(other.trees, trees)&&(identical(other.showHidden, showHidden) || other.showHidden == showHidden));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(trees),showHidden);

@override
String toString() {
  return 'ExplorerState(trees: $trees, showHidden: $showHidden)';
}


}

/// @nodoc
abstract mixin class $ExplorerStateCopyWith<$Res>  {
  factory $ExplorerStateCopyWith(ExplorerState value, $Res Function(ExplorerState) _then) = _$ExplorerStateCopyWithImpl;
@useResult
$Res call({
 Map<WorkspaceId, WorkspaceTree> trees, bool showHidden
});




}
/// @nodoc
class _$ExplorerStateCopyWithImpl<$Res>
    implements $ExplorerStateCopyWith<$Res> {
  _$ExplorerStateCopyWithImpl(this._self, this._then);

  final ExplorerState _self;
  final $Res Function(ExplorerState) _then;

/// Create a copy of ExplorerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trees = null,Object? showHidden = null,}) {
  return _then(_self.copyWith(
trees: null == trees ? _self.trees : trees // ignore: cast_nullable_to_non_nullable
as Map<WorkspaceId, WorkspaceTree>,showHidden: null == showHidden ? _self.showHidden : showHidden // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ExplorerState].
extension ExplorerStatePatterns on ExplorerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExplorerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExplorerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExplorerState value)  $default,){
final _that = this;
switch (_that) {
case _ExplorerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExplorerState value)?  $default,){
final _that = this;
switch (_that) {
case _ExplorerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<WorkspaceId, WorkspaceTree> trees,  bool showHidden)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExplorerState() when $default != null:
return $default(_that.trees,_that.showHidden);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<WorkspaceId, WorkspaceTree> trees,  bool showHidden)  $default,) {final _that = this;
switch (_that) {
case _ExplorerState():
return $default(_that.trees,_that.showHidden);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<WorkspaceId, WorkspaceTree> trees,  bool showHidden)?  $default,) {final _that = this;
switch (_that) {
case _ExplorerState() when $default != null:
return $default(_that.trees,_that.showHidden);case _:
  return null;

}
}

}

/// @nodoc


class _ExplorerState implements ExplorerState {
  const _ExplorerState({final  Map<WorkspaceId, WorkspaceTree> trees = const <WorkspaceId, WorkspaceTree>{}, this.showHidden = false}): _trees = trees;
  

 final  Map<WorkspaceId, WorkspaceTree> _trees;
@override@JsonKey() Map<WorkspaceId, WorkspaceTree> get trees {
  if (_trees is EqualUnmodifiableMapView) return _trees;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_trees);
}

@override@JsonKey() final  bool showHidden;

/// Create a copy of ExplorerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExplorerStateCopyWith<_ExplorerState> get copyWith => __$ExplorerStateCopyWithImpl<_ExplorerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExplorerState&&const DeepCollectionEquality().equals(other._trees, _trees)&&(identical(other.showHidden, showHidden) || other.showHidden == showHidden));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_trees),showHidden);

@override
String toString() {
  return 'ExplorerState(trees: $trees, showHidden: $showHidden)';
}


}

/// @nodoc
abstract mixin class _$ExplorerStateCopyWith<$Res> implements $ExplorerStateCopyWith<$Res> {
  factory _$ExplorerStateCopyWith(_ExplorerState value, $Res Function(_ExplorerState) _then) = __$ExplorerStateCopyWithImpl;
@override @useResult
$Res call({
 Map<WorkspaceId, WorkspaceTree> trees, bool showHidden
});




}
/// @nodoc
class __$ExplorerStateCopyWithImpl<$Res>
    implements _$ExplorerStateCopyWith<$Res> {
  __$ExplorerStateCopyWithImpl(this._self, this._then);

  final _ExplorerState _self;
  final $Res Function(_ExplorerState) _then;

/// Create a copy of ExplorerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trees = null,Object? showHidden = null,}) {
  return _then(_ExplorerState(
trees: null == trees ? _self._trees : trees // ignore: cast_nullable_to_non_nullable
as Map<WorkspaceId, WorkspaceTree>,showHidden: null == showHidden ? _self.showHidden : showHidden // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$WorkspaceTree {

 Map<String, List<FileNode>> get children; Set<String> get expanded; Set<String> get loading; Map<String, Failure> get errors;
/// Create a copy of WorkspaceTree
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspaceTreeCopyWith<WorkspaceTree> get copyWith => _$WorkspaceTreeCopyWithImpl<WorkspaceTree>(this as WorkspaceTree, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceTree&&const DeepCollectionEquality().equals(other.children, children)&&const DeepCollectionEquality().equals(other.expanded, expanded)&&const DeepCollectionEquality().equals(other.loading, loading)&&const DeepCollectionEquality().equals(other.errors, errors));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(children),const DeepCollectionEquality().hash(expanded),const DeepCollectionEquality().hash(loading),const DeepCollectionEquality().hash(errors));

@override
String toString() {
  return 'WorkspaceTree(children: $children, expanded: $expanded, loading: $loading, errors: $errors)';
}


}

/// @nodoc
abstract mixin class $WorkspaceTreeCopyWith<$Res>  {
  factory $WorkspaceTreeCopyWith(WorkspaceTree value, $Res Function(WorkspaceTree) _then) = _$WorkspaceTreeCopyWithImpl;
@useResult
$Res call({
 Map<String, List<FileNode>> children, Set<String> expanded, Set<String> loading, Map<String, Failure> errors
});




}
/// @nodoc
class _$WorkspaceTreeCopyWithImpl<$Res>
    implements $WorkspaceTreeCopyWith<$Res> {
  _$WorkspaceTreeCopyWithImpl(this._self, this._then);

  final WorkspaceTree _self;
  final $Res Function(WorkspaceTree) _then;

/// Create a copy of WorkspaceTree
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? children = null,Object? expanded = null,Object? loading = null,Object? errors = null,}) {
  return _then(_self.copyWith(
children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as Map<String, List<FileNode>>,expanded: null == expanded ? _self.expanded : expanded // ignore: cast_nullable_to_non_nullable
as Set<String>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as Set<String>,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, Failure>,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkspaceTree].
extension WorkspaceTreePatterns on WorkspaceTree {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkspaceTree value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkspaceTree() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkspaceTree value)  $default,){
final _that = this;
switch (_that) {
case _WorkspaceTree():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkspaceTree value)?  $default,){
final _that = this;
switch (_that) {
case _WorkspaceTree() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, List<FileNode>> children,  Set<String> expanded,  Set<String> loading,  Map<String, Failure> errors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkspaceTree() when $default != null:
return $default(_that.children,_that.expanded,_that.loading,_that.errors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, List<FileNode>> children,  Set<String> expanded,  Set<String> loading,  Map<String, Failure> errors)  $default,) {final _that = this;
switch (_that) {
case _WorkspaceTree():
return $default(_that.children,_that.expanded,_that.loading,_that.errors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, List<FileNode>> children,  Set<String> expanded,  Set<String> loading,  Map<String, Failure> errors)?  $default,) {final _that = this;
switch (_that) {
case _WorkspaceTree() when $default != null:
return $default(_that.children,_that.expanded,_that.loading,_that.errors);case _:
  return null;

}
}

}

/// @nodoc


class _WorkspaceTree implements WorkspaceTree {
  const _WorkspaceTree({final  Map<String, List<FileNode>> children = const <String, List<FileNode>>{}, final  Set<String> expanded = const <String>{}, final  Set<String> loading = const <String>{}, final  Map<String, Failure> errors = const <String, Failure>{}}): _children = children,_expanded = expanded,_loading = loading,_errors = errors;
  

 final  Map<String, List<FileNode>> _children;
@override@JsonKey() Map<String, List<FileNode>> get children {
  if (_children is EqualUnmodifiableMapView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_children);
}

 final  Set<String> _expanded;
@override@JsonKey() Set<String> get expanded {
  if (_expanded is EqualUnmodifiableSetView) return _expanded;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_expanded);
}

 final  Set<String> _loading;
@override@JsonKey() Set<String> get loading {
  if (_loading is EqualUnmodifiableSetView) return _loading;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_loading);
}

 final  Map<String, Failure> _errors;
@override@JsonKey() Map<String, Failure> get errors {
  if (_errors is EqualUnmodifiableMapView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_errors);
}


/// Create a copy of WorkspaceTree
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkspaceTreeCopyWith<_WorkspaceTree> get copyWith => __$WorkspaceTreeCopyWithImpl<_WorkspaceTree>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceTree&&const DeepCollectionEquality().equals(other._children, _children)&&const DeepCollectionEquality().equals(other._expanded, _expanded)&&const DeepCollectionEquality().equals(other._loading, _loading)&&const DeepCollectionEquality().equals(other._errors, _errors));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_children),const DeepCollectionEquality().hash(_expanded),const DeepCollectionEquality().hash(_loading),const DeepCollectionEquality().hash(_errors));

@override
String toString() {
  return 'WorkspaceTree(children: $children, expanded: $expanded, loading: $loading, errors: $errors)';
}


}

/// @nodoc
abstract mixin class _$WorkspaceTreeCopyWith<$Res> implements $WorkspaceTreeCopyWith<$Res> {
  factory _$WorkspaceTreeCopyWith(_WorkspaceTree value, $Res Function(_WorkspaceTree) _then) = __$WorkspaceTreeCopyWithImpl;
@override @useResult
$Res call({
 Map<String, List<FileNode>> children, Set<String> expanded, Set<String> loading, Map<String, Failure> errors
});




}
/// @nodoc
class __$WorkspaceTreeCopyWithImpl<$Res>
    implements _$WorkspaceTreeCopyWith<$Res> {
  __$WorkspaceTreeCopyWithImpl(this._self, this._then);

  final _WorkspaceTree _self;
  final $Res Function(_WorkspaceTree) _then;

/// Create a copy of WorkspaceTree
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? children = null,Object? expanded = null,Object? loading = null,Object? errors = null,}) {
  return _then(_WorkspaceTree(
children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as Map<String, List<FileNode>>,expanded: null == expanded ? _self._expanded : expanded // ignore: cast_nullable_to_non_nullable
as Set<String>,loading: null == loading ? _self._loading : loading // ignore: cast_nullable_to_non_nullable
as Set<String>,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, Failure>,
  ));
}


}

// dart format on
