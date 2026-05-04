// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_log_detail_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppLogDetailState {

 int? get sessionId; List<AppLogEntry> get entries; Set<AppLogLevel> get levelFilter; String get search; bool get loading;
/// Create a copy of AppLogDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppLogDetailStateCopyWith<AppLogDetailState> get copyWith => _$AppLogDetailStateCopyWithImpl<AppLogDetailState>(this as AppLogDetailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppLogDetailState&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&const DeepCollectionEquality().equals(other.entries, entries)&&const DeepCollectionEquality().equals(other.levelFilter, levelFilter)&&(identical(other.search, search) || other.search == search)&&(identical(other.loading, loading) || other.loading == loading));
}


@override
int get hashCode => Object.hash(runtimeType,sessionId,const DeepCollectionEquality().hash(entries),const DeepCollectionEquality().hash(levelFilter),search,loading);

@override
String toString() {
  return 'AppLogDetailState(sessionId: $sessionId, entries: $entries, levelFilter: $levelFilter, search: $search, loading: $loading)';
}


}

/// @nodoc
abstract mixin class $AppLogDetailStateCopyWith<$Res>  {
  factory $AppLogDetailStateCopyWith(AppLogDetailState value, $Res Function(AppLogDetailState) _then) = _$AppLogDetailStateCopyWithImpl;
@useResult
$Res call({
 int? sessionId, List<AppLogEntry> entries, Set<AppLogLevel> levelFilter, String search, bool loading
});




}
/// @nodoc
class _$AppLogDetailStateCopyWithImpl<$Res>
    implements $AppLogDetailStateCopyWith<$Res> {
  _$AppLogDetailStateCopyWithImpl(this._self, this._then);

  final AppLogDetailState _self;
  final $Res Function(AppLogDetailState) _then;

/// Create a copy of AppLogDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = freezed,Object? entries = null,Object? levelFilter = null,Object? search = null,Object? loading = null,}) {
  return _then(_self.copyWith(
sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as int?,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<AppLogEntry>,levelFilter: null == levelFilter ? _self.levelFilter : levelFilter // ignore: cast_nullable_to_non_nullable
as Set<AppLogLevel>,search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppLogDetailState].
extension AppLogDetailStatePatterns on AppLogDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppLogDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppLogDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppLogDetailState value)  $default,){
final _that = this;
switch (_that) {
case _AppLogDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppLogDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _AppLogDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? sessionId,  List<AppLogEntry> entries,  Set<AppLogLevel> levelFilter,  String search,  bool loading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppLogDetailState() when $default != null:
return $default(_that.sessionId,_that.entries,_that.levelFilter,_that.search,_that.loading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? sessionId,  List<AppLogEntry> entries,  Set<AppLogLevel> levelFilter,  String search,  bool loading)  $default,) {final _that = this;
switch (_that) {
case _AppLogDetailState():
return $default(_that.sessionId,_that.entries,_that.levelFilter,_that.search,_that.loading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? sessionId,  List<AppLogEntry> entries,  Set<AppLogLevel> levelFilter,  String search,  bool loading)?  $default,) {final _that = this;
switch (_that) {
case _AppLogDetailState() when $default != null:
return $default(_that.sessionId,_that.entries,_that.levelFilter,_that.search,_that.loading);case _:
  return null;

}
}

}

/// @nodoc


class _AppLogDetailState implements AppLogDetailState {
  const _AppLogDetailState({this.sessionId, final  List<AppLogEntry> entries = const [], final  Set<AppLogLevel> levelFilter = const {}, this.search = '', this.loading = true}): _entries = entries,_levelFilter = levelFilter;
  

@override final  int? sessionId;
 final  List<AppLogEntry> _entries;
@override@JsonKey() List<AppLogEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

 final  Set<AppLogLevel> _levelFilter;
@override@JsonKey() Set<AppLogLevel> get levelFilter {
  if (_levelFilter is EqualUnmodifiableSetView) return _levelFilter;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_levelFilter);
}

@override@JsonKey() final  String search;
@override@JsonKey() final  bool loading;

/// Create a copy of AppLogDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppLogDetailStateCopyWith<_AppLogDetailState> get copyWith => __$AppLogDetailStateCopyWithImpl<_AppLogDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppLogDetailState&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&const DeepCollectionEquality().equals(other._entries, _entries)&&const DeepCollectionEquality().equals(other._levelFilter, _levelFilter)&&(identical(other.search, search) || other.search == search)&&(identical(other.loading, loading) || other.loading == loading));
}


@override
int get hashCode => Object.hash(runtimeType,sessionId,const DeepCollectionEquality().hash(_entries),const DeepCollectionEquality().hash(_levelFilter),search,loading);

@override
String toString() {
  return 'AppLogDetailState(sessionId: $sessionId, entries: $entries, levelFilter: $levelFilter, search: $search, loading: $loading)';
}


}

/// @nodoc
abstract mixin class _$AppLogDetailStateCopyWith<$Res> implements $AppLogDetailStateCopyWith<$Res> {
  factory _$AppLogDetailStateCopyWith(_AppLogDetailState value, $Res Function(_AppLogDetailState) _then) = __$AppLogDetailStateCopyWithImpl;
@override @useResult
$Res call({
 int? sessionId, List<AppLogEntry> entries, Set<AppLogLevel> levelFilter, String search, bool loading
});




}
/// @nodoc
class __$AppLogDetailStateCopyWithImpl<$Res>
    implements _$AppLogDetailStateCopyWith<$Res> {
  __$AppLogDetailStateCopyWithImpl(this._self, this._then);

  final _AppLogDetailState _self;
  final $Res Function(_AppLogDetailState) _then;

/// Create a copy of AppLogDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = freezed,Object? entries = null,Object? levelFilter = null,Object? search = null,Object? loading = null,}) {
  return _then(_AppLogDetailState(
sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as int?,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<AppLogEntry>,levelFilter: null == levelFilter ? _self._levelFilter : levelFilter // ignore: cast_nullable_to_non_nullable
as Set<AppLogLevel>,search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
