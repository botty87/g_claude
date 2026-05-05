// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shell_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ShellState {

 bool get workspaceOpen; ActivityId get selectedActivity; Map<String, double> get paneSizes;
/// Create a copy of ShellState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShellStateCopyWith<ShellState> get copyWith => _$ShellStateCopyWithImpl<ShellState>(this as ShellState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShellState&&(identical(other.workspaceOpen, workspaceOpen) || other.workspaceOpen == workspaceOpen)&&(identical(other.selectedActivity, selectedActivity) || other.selectedActivity == selectedActivity)&&const DeepCollectionEquality().equals(other.paneSizes, paneSizes));
}


@override
int get hashCode => Object.hash(runtimeType,workspaceOpen,selectedActivity,const DeepCollectionEquality().hash(paneSizes));

@override
String toString() {
  return 'ShellState(workspaceOpen: $workspaceOpen, selectedActivity: $selectedActivity, paneSizes: $paneSizes)';
}


}

/// @nodoc
abstract mixin class $ShellStateCopyWith<$Res>  {
  factory $ShellStateCopyWith(ShellState value, $Res Function(ShellState) _then) = _$ShellStateCopyWithImpl;
@useResult
$Res call({
 bool workspaceOpen, ActivityId selectedActivity, Map<String, double> paneSizes
});




}
/// @nodoc
class _$ShellStateCopyWithImpl<$Res>
    implements $ShellStateCopyWith<$Res> {
  _$ShellStateCopyWithImpl(this._self, this._then);

  final ShellState _self;
  final $Res Function(ShellState) _then;

/// Create a copy of ShellState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? workspaceOpen = null,Object? selectedActivity = null,Object? paneSizes = null,}) {
  return _then(_self.copyWith(
workspaceOpen: null == workspaceOpen ? _self.workspaceOpen : workspaceOpen // ignore: cast_nullable_to_non_nullable
as bool,selectedActivity: null == selectedActivity ? _self.selectedActivity : selectedActivity // ignore: cast_nullable_to_non_nullable
as ActivityId,paneSizes: null == paneSizes ? _self.paneSizes : paneSizes // ignore: cast_nullable_to_non_nullable
as Map<String, double>,
  ));
}

}


/// Adds pattern-matching-related methods to [ShellState].
extension ShellStatePatterns on ShellState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShellState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShellState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShellState value)  $default,){
final _that = this;
switch (_that) {
case _ShellState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShellState value)?  $default,){
final _that = this;
switch (_that) {
case _ShellState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool workspaceOpen,  ActivityId selectedActivity,  Map<String, double> paneSizes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShellState() when $default != null:
return $default(_that.workspaceOpen,_that.selectedActivity,_that.paneSizes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool workspaceOpen,  ActivityId selectedActivity,  Map<String, double> paneSizes)  $default,) {final _that = this;
switch (_that) {
case _ShellState():
return $default(_that.workspaceOpen,_that.selectedActivity,_that.paneSizes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool workspaceOpen,  ActivityId selectedActivity,  Map<String, double> paneSizes)?  $default,) {final _that = this;
switch (_that) {
case _ShellState() when $default != null:
return $default(_that.workspaceOpen,_that.selectedActivity,_that.paneSizes);case _:
  return null;

}
}

}

/// @nodoc


class _ShellState implements ShellState {
  const _ShellState({required this.workspaceOpen, required this.selectedActivity, final  Map<String, double> paneSizes = const <String, double>{}}): _paneSizes = paneSizes;
  

@override final  bool workspaceOpen;
@override final  ActivityId selectedActivity;
 final  Map<String, double> _paneSizes;
@override@JsonKey() Map<String, double> get paneSizes {
  if (_paneSizes is EqualUnmodifiableMapView) return _paneSizes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_paneSizes);
}


/// Create a copy of ShellState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShellStateCopyWith<_ShellState> get copyWith => __$ShellStateCopyWithImpl<_ShellState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShellState&&(identical(other.workspaceOpen, workspaceOpen) || other.workspaceOpen == workspaceOpen)&&(identical(other.selectedActivity, selectedActivity) || other.selectedActivity == selectedActivity)&&const DeepCollectionEquality().equals(other._paneSizes, _paneSizes));
}


@override
int get hashCode => Object.hash(runtimeType,workspaceOpen,selectedActivity,const DeepCollectionEquality().hash(_paneSizes));

@override
String toString() {
  return 'ShellState(workspaceOpen: $workspaceOpen, selectedActivity: $selectedActivity, paneSizes: $paneSizes)';
}


}

/// @nodoc
abstract mixin class _$ShellStateCopyWith<$Res> implements $ShellStateCopyWith<$Res> {
  factory _$ShellStateCopyWith(_ShellState value, $Res Function(_ShellState) _then) = __$ShellStateCopyWithImpl;
@override @useResult
$Res call({
 bool workspaceOpen, ActivityId selectedActivity, Map<String, double> paneSizes
});




}
/// @nodoc
class __$ShellStateCopyWithImpl<$Res>
    implements _$ShellStateCopyWith<$Res> {
  __$ShellStateCopyWithImpl(this._self, this._then);

  final _ShellState _self;
  final $Res Function(_ShellState) _then;

/// Create a copy of ShellState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? workspaceOpen = null,Object? selectedActivity = null,Object? paneSizes = null,}) {
  return _then(_ShellState(
workspaceOpen: null == workspaceOpen ? _self.workspaceOpen : workspaceOpen // ignore: cast_nullable_to_non_nullable
as bool,selectedActivity: null == selectedActivity ? _self.selectedActivity : selectedActivity // ignore: cast_nullable_to_non_nullable
as ActivityId,paneSizes: null == paneSizes ? _self._paneSizes : paneSizes // ignore: cast_nullable_to_non_nullable
as Map<String, double>,
  ));
}


}

// dart format on
