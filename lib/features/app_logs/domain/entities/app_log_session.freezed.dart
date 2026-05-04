// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_log_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppLogSession {

 int get id; DateTime get startedAt; DateTime? get endedAt; String? get appVersion; String get platform; int get errorCount; int get warningCount; int get totalCount;
/// Create a copy of AppLogSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppLogSessionCopyWith<AppLogSession> get copyWith => _$AppLogSessionCopyWithImpl<AppLogSession>(this as AppLogSession, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppLogSession&&(identical(other.id, id) || other.id == id)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.errorCount, errorCount) || other.errorCount == errorCount)&&(identical(other.warningCount, warningCount) || other.warningCount == warningCount)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount));
}


@override
int get hashCode => Object.hash(runtimeType,id,startedAt,endedAt,appVersion,platform,errorCount,warningCount,totalCount);

@override
String toString() {
  return 'AppLogSession(id: $id, startedAt: $startedAt, endedAt: $endedAt, appVersion: $appVersion, platform: $platform, errorCount: $errorCount, warningCount: $warningCount, totalCount: $totalCount)';
}


}

/// @nodoc
abstract mixin class $AppLogSessionCopyWith<$Res>  {
  factory $AppLogSessionCopyWith(AppLogSession value, $Res Function(AppLogSession) _then) = _$AppLogSessionCopyWithImpl;
@useResult
$Res call({
 int id, DateTime startedAt, DateTime? endedAt, String? appVersion, String platform, int errorCount, int warningCount, int totalCount
});




}
/// @nodoc
class _$AppLogSessionCopyWithImpl<$Res>
    implements $AppLogSessionCopyWith<$Res> {
  _$AppLogSessionCopyWithImpl(this._self, this._then);

  final AppLogSession _self;
  final $Res Function(AppLogSession) _then;

/// Create a copy of AppLogSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? startedAt = null,Object? endedAt = freezed,Object? appVersion = freezed,Object? platform = null,Object? errorCount = null,Object? warningCount = null,Object? totalCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,appVersion: freezed == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String?,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,errorCount: null == errorCount ? _self.errorCount : errorCount // ignore: cast_nullable_to_non_nullable
as int,warningCount: null == warningCount ? _self.warningCount : warningCount // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AppLogSession].
extension AppLogSessionPatterns on AppLogSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppLogSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppLogSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppLogSession value)  $default,){
final _that = this;
switch (_that) {
case _AppLogSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppLogSession value)?  $default,){
final _that = this;
switch (_that) {
case _AppLogSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  DateTime startedAt,  DateTime? endedAt,  String? appVersion,  String platform,  int errorCount,  int warningCount,  int totalCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppLogSession() when $default != null:
return $default(_that.id,_that.startedAt,_that.endedAt,_that.appVersion,_that.platform,_that.errorCount,_that.warningCount,_that.totalCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  DateTime startedAt,  DateTime? endedAt,  String? appVersion,  String platform,  int errorCount,  int warningCount,  int totalCount)  $default,) {final _that = this;
switch (_that) {
case _AppLogSession():
return $default(_that.id,_that.startedAt,_that.endedAt,_that.appVersion,_that.platform,_that.errorCount,_that.warningCount,_that.totalCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  DateTime startedAt,  DateTime? endedAt,  String? appVersion,  String platform,  int errorCount,  int warningCount,  int totalCount)?  $default,) {final _that = this;
switch (_that) {
case _AppLogSession() when $default != null:
return $default(_that.id,_that.startedAt,_that.endedAt,_that.appVersion,_that.platform,_that.errorCount,_that.warningCount,_that.totalCount);case _:
  return null;

}
}

}

/// @nodoc


class _AppLogSession implements AppLogSession {
  const _AppLogSession({required this.id, required this.startedAt, required this.endedAt, required this.appVersion, required this.platform, required this.errorCount, required this.warningCount, required this.totalCount});
  

@override final  int id;
@override final  DateTime startedAt;
@override final  DateTime? endedAt;
@override final  String? appVersion;
@override final  String platform;
@override final  int errorCount;
@override final  int warningCount;
@override final  int totalCount;

/// Create a copy of AppLogSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppLogSessionCopyWith<_AppLogSession> get copyWith => __$AppLogSessionCopyWithImpl<_AppLogSession>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppLogSession&&(identical(other.id, id) || other.id == id)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.errorCount, errorCount) || other.errorCount == errorCount)&&(identical(other.warningCount, warningCount) || other.warningCount == warningCount)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount));
}


@override
int get hashCode => Object.hash(runtimeType,id,startedAt,endedAt,appVersion,platform,errorCount,warningCount,totalCount);

@override
String toString() {
  return 'AppLogSession(id: $id, startedAt: $startedAt, endedAt: $endedAt, appVersion: $appVersion, platform: $platform, errorCount: $errorCount, warningCount: $warningCount, totalCount: $totalCount)';
}


}

/// @nodoc
abstract mixin class _$AppLogSessionCopyWith<$Res> implements $AppLogSessionCopyWith<$Res> {
  factory _$AppLogSessionCopyWith(_AppLogSession value, $Res Function(_AppLogSession) _then) = __$AppLogSessionCopyWithImpl;
@override @useResult
$Res call({
 int id, DateTime startedAt, DateTime? endedAt, String? appVersion, String platform, int errorCount, int warningCount, int totalCount
});




}
/// @nodoc
class __$AppLogSessionCopyWithImpl<$Res>
    implements _$AppLogSessionCopyWith<$Res> {
  __$AppLogSessionCopyWithImpl(this._self, this._then);

  final _AppLogSession _self;
  final $Res Function(_AppLogSession) _then;

/// Create a copy of AppLogSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? startedAt = null,Object? endedAt = freezed,Object? appVersion = freezed,Object? platform = null,Object? errorCount = null,Object? warningCount = null,Object? totalCount = null,}) {
  return _then(_AppLogSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,appVersion: freezed == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String?,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,errorCount: null == errorCount ? _self.errorCount : errorCount // ignore: cast_nullable_to_non_nullable
as int,warningCount: null == warningCount ? _self.warningCount : warningCount // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
