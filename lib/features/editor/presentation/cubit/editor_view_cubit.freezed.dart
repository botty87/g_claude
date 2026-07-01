// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'editor_view_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EditorViewData {

 CenterView get view; bool get peekOpen;
/// Create a copy of EditorViewData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditorViewDataCopyWith<EditorViewData> get copyWith => _$EditorViewDataCopyWithImpl<EditorViewData>(this as EditorViewData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditorViewData&&(identical(other.view, view) || other.view == view)&&(identical(other.peekOpen, peekOpen) || other.peekOpen == peekOpen));
}


@override
int get hashCode => Object.hash(runtimeType,view,peekOpen);

@override
String toString() {
  return 'EditorViewData(view: $view, peekOpen: $peekOpen)';
}


}

/// @nodoc
abstract mixin class $EditorViewDataCopyWith<$Res>  {
  factory $EditorViewDataCopyWith(EditorViewData value, $Res Function(EditorViewData) _then) = _$EditorViewDataCopyWithImpl;
@useResult
$Res call({
 CenterView view, bool peekOpen
});




}
/// @nodoc
class _$EditorViewDataCopyWithImpl<$Res>
    implements $EditorViewDataCopyWith<$Res> {
  _$EditorViewDataCopyWithImpl(this._self, this._then);

  final EditorViewData _self;
  final $Res Function(EditorViewData) _then;

/// Create a copy of EditorViewData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? view = null,Object? peekOpen = null,}) {
  return _then(_self.copyWith(
view: null == view ? _self.view : view // ignore: cast_nullable_to_non_nullable
as CenterView,peekOpen: null == peekOpen ? _self.peekOpen : peekOpen // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [EditorViewData].
extension EditorViewDataPatterns on EditorViewData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EditorViewData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EditorViewData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EditorViewData value)  $default,){
final _that = this;
switch (_that) {
case _EditorViewData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EditorViewData value)?  $default,){
final _that = this;
switch (_that) {
case _EditorViewData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CenterView view,  bool peekOpen)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EditorViewData() when $default != null:
return $default(_that.view,_that.peekOpen);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CenterView view,  bool peekOpen)  $default,) {final _that = this;
switch (_that) {
case _EditorViewData():
return $default(_that.view,_that.peekOpen);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CenterView view,  bool peekOpen)?  $default,) {final _that = this;
switch (_that) {
case _EditorViewData() when $default != null:
return $default(_that.view,_that.peekOpen);case _:
  return null;

}
}

}

/// @nodoc


class _EditorViewData implements EditorViewData {
  const _EditorViewData({this.view = CenterView.chat, this.peekOpen = false});
  

@override@JsonKey() final  CenterView view;
@override@JsonKey() final  bool peekOpen;

/// Create a copy of EditorViewData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditorViewDataCopyWith<_EditorViewData> get copyWith => __$EditorViewDataCopyWithImpl<_EditorViewData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditorViewData&&(identical(other.view, view) || other.view == view)&&(identical(other.peekOpen, peekOpen) || other.peekOpen == peekOpen));
}


@override
int get hashCode => Object.hash(runtimeType,view,peekOpen);

@override
String toString() {
  return 'EditorViewData(view: $view, peekOpen: $peekOpen)';
}


}

/// @nodoc
abstract mixin class _$EditorViewDataCopyWith<$Res> implements $EditorViewDataCopyWith<$Res> {
  factory _$EditorViewDataCopyWith(_EditorViewData value, $Res Function(_EditorViewData) _then) = __$EditorViewDataCopyWithImpl;
@override @useResult
$Res call({
 CenterView view, bool peekOpen
});




}
/// @nodoc
class __$EditorViewDataCopyWithImpl<$Res>
    implements _$EditorViewDataCopyWith<$Res> {
  __$EditorViewDataCopyWithImpl(this._self, this._then);

  final _EditorViewData _self;
  final $Res Function(_EditorViewData) _then;

/// Create a copy of EditorViewData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? view = null,Object? peekOpen = null,}) {
  return _then(_EditorViewData(
view: null == view ? _self.view : view // ignore: cast_nullable_to_non_nullable
as CenterView,peekOpen: null == peekOpen ? _self.peekOpen : peekOpen // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$EditorViewState {

 Map<WorkspaceId, EditorViewData> get perWorkspace;
/// Create a copy of EditorViewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditorViewStateCopyWith<EditorViewState> get copyWith => _$EditorViewStateCopyWithImpl<EditorViewState>(this as EditorViewState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditorViewState&&const DeepCollectionEquality().equals(other.perWorkspace, perWorkspace));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(perWorkspace));

@override
String toString() {
  return 'EditorViewState(perWorkspace: $perWorkspace)';
}


}

/// @nodoc
abstract mixin class $EditorViewStateCopyWith<$Res>  {
  factory $EditorViewStateCopyWith(EditorViewState value, $Res Function(EditorViewState) _then) = _$EditorViewStateCopyWithImpl;
@useResult
$Res call({
 Map<WorkspaceId, EditorViewData> perWorkspace
});




}
/// @nodoc
class _$EditorViewStateCopyWithImpl<$Res>
    implements $EditorViewStateCopyWith<$Res> {
  _$EditorViewStateCopyWithImpl(this._self, this._then);

  final EditorViewState _self;
  final $Res Function(EditorViewState) _then;

/// Create a copy of EditorViewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? perWorkspace = null,}) {
  return _then(_self.copyWith(
perWorkspace: null == perWorkspace ? _self.perWorkspace : perWorkspace // ignore: cast_nullable_to_non_nullable
as Map<WorkspaceId, EditorViewData>,
  ));
}

}


/// Adds pattern-matching-related methods to [EditorViewState].
extension EditorViewStatePatterns on EditorViewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EditorViewState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EditorViewState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EditorViewState value)  $default,){
final _that = this;
switch (_that) {
case _EditorViewState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EditorViewState value)?  $default,){
final _that = this;
switch (_that) {
case _EditorViewState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<WorkspaceId, EditorViewData> perWorkspace)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EditorViewState() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<WorkspaceId, EditorViewData> perWorkspace)  $default,) {final _that = this;
switch (_that) {
case _EditorViewState():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<WorkspaceId, EditorViewData> perWorkspace)?  $default,) {final _that = this;
switch (_that) {
case _EditorViewState() when $default != null:
return $default(_that.perWorkspace);case _:
  return null;

}
}

}

/// @nodoc


class _EditorViewState extends EditorViewState {
  const _EditorViewState({final  Map<WorkspaceId, EditorViewData> perWorkspace = const <WorkspaceId, EditorViewData>{}}): _perWorkspace = perWorkspace,super._();
  

 final  Map<WorkspaceId, EditorViewData> _perWorkspace;
@override@JsonKey() Map<WorkspaceId, EditorViewData> get perWorkspace {
  if (_perWorkspace is EqualUnmodifiableMapView) return _perWorkspace;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_perWorkspace);
}


/// Create a copy of EditorViewState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditorViewStateCopyWith<_EditorViewState> get copyWith => __$EditorViewStateCopyWithImpl<_EditorViewState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditorViewState&&const DeepCollectionEquality().equals(other._perWorkspace, _perWorkspace));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_perWorkspace));

@override
String toString() {
  return 'EditorViewState(perWorkspace: $perWorkspace)';
}


}

/// @nodoc
abstract mixin class _$EditorViewStateCopyWith<$Res> implements $EditorViewStateCopyWith<$Res> {
  factory _$EditorViewStateCopyWith(_EditorViewState value, $Res Function(_EditorViewState) _then) = __$EditorViewStateCopyWithImpl;
@override @useResult
$Res call({
 Map<WorkspaceId, EditorViewData> perWorkspace
});




}
/// @nodoc
class __$EditorViewStateCopyWithImpl<$Res>
    implements _$EditorViewStateCopyWith<$Res> {
  __$EditorViewStateCopyWithImpl(this._self, this._then);

  final _EditorViewState _self;
  final $Res Function(_EditorViewState) _then;

/// Create a copy of EditorViewState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? perWorkspace = null,}) {
  return _then(_EditorViewState(
perWorkspace: null == perWorkspace ? _self._perWorkspace : perWorkspace // ignore: cast_nullable_to_non_nullable
as Map<WorkspaceId, EditorViewData>,
  ));
}


}

// dart format on
