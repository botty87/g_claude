// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_log_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppLogEntry {

 int get id; int get sessionId; DateTime get time; AppLogLevel get level; String? get title; String get message; String? get exception; String? get stackTrace;
/// Create a copy of AppLogEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppLogEntryCopyWith<AppLogEntry> get copyWith => _$AppLogEntryCopyWithImpl<AppLogEntry>(this as AppLogEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppLogEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.time, time) || other.time == time)&&(identical(other.level, level) || other.level == level)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.exception, exception) || other.exception == exception)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,id,sessionId,time,level,title,message,exception,stackTrace);

@override
String toString() {
  return 'AppLogEntry(id: $id, sessionId: $sessionId, time: $time, level: $level, title: $title, message: $message, exception: $exception, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class $AppLogEntryCopyWith<$Res>  {
  factory $AppLogEntryCopyWith(AppLogEntry value, $Res Function(AppLogEntry) _then) = _$AppLogEntryCopyWithImpl;
@useResult
$Res call({
 int id, int sessionId, DateTime time, AppLogLevel level, String? title, String message, String? exception, String? stackTrace
});




}
/// @nodoc
class _$AppLogEntryCopyWithImpl<$Res>
    implements $AppLogEntryCopyWith<$Res> {
  _$AppLogEntryCopyWithImpl(this._self, this._then);

  final AppLogEntry _self;
  final $Res Function(AppLogEntry) _then;

/// Create a copy of AppLogEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sessionId = null,Object? time = null,Object? level = null,Object? title = freezed,Object? message = null,Object? exception = freezed,Object? stackTrace = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as int,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as AppLogLevel,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,exception: freezed == exception ? _self.exception : exception // ignore: cast_nullable_to_non_nullable
as String?,stackTrace: freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppLogEntry].
extension AppLogEntryPatterns on AppLogEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppLogEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppLogEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppLogEntry value)  $default,){
final _that = this;
switch (_that) {
case _AppLogEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppLogEntry value)?  $default,){
final _that = this;
switch (_that) {
case _AppLogEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int sessionId,  DateTime time,  AppLogLevel level,  String? title,  String message,  String? exception,  String? stackTrace)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppLogEntry() when $default != null:
return $default(_that.id,_that.sessionId,_that.time,_that.level,_that.title,_that.message,_that.exception,_that.stackTrace);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int sessionId,  DateTime time,  AppLogLevel level,  String? title,  String message,  String? exception,  String? stackTrace)  $default,) {final _that = this;
switch (_that) {
case _AppLogEntry():
return $default(_that.id,_that.sessionId,_that.time,_that.level,_that.title,_that.message,_that.exception,_that.stackTrace);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int sessionId,  DateTime time,  AppLogLevel level,  String? title,  String message,  String? exception,  String? stackTrace)?  $default,) {final _that = this;
switch (_that) {
case _AppLogEntry() when $default != null:
return $default(_that.id,_that.sessionId,_that.time,_that.level,_that.title,_that.message,_that.exception,_that.stackTrace);case _:
  return null;

}
}

}

/// @nodoc


class _AppLogEntry implements AppLogEntry {
  const _AppLogEntry({required this.id, required this.sessionId, required this.time, required this.level, required this.title, required this.message, required this.exception, required this.stackTrace});
  

@override final  int id;
@override final  int sessionId;
@override final  DateTime time;
@override final  AppLogLevel level;
@override final  String? title;
@override final  String message;
@override final  String? exception;
@override final  String? stackTrace;

/// Create a copy of AppLogEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppLogEntryCopyWith<_AppLogEntry> get copyWith => __$AppLogEntryCopyWithImpl<_AppLogEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppLogEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.time, time) || other.time == time)&&(identical(other.level, level) || other.level == level)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.exception, exception) || other.exception == exception)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,id,sessionId,time,level,title,message,exception,stackTrace);

@override
String toString() {
  return 'AppLogEntry(id: $id, sessionId: $sessionId, time: $time, level: $level, title: $title, message: $message, exception: $exception, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class _$AppLogEntryCopyWith<$Res> implements $AppLogEntryCopyWith<$Res> {
  factory _$AppLogEntryCopyWith(_AppLogEntry value, $Res Function(_AppLogEntry) _then) = __$AppLogEntryCopyWithImpl;
@override @useResult
$Res call({
 int id, int sessionId, DateTime time, AppLogLevel level, String? title, String message, String? exception, String? stackTrace
});




}
/// @nodoc
class __$AppLogEntryCopyWithImpl<$Res>
    implements _$AppLogEntryCopyWith<$Res> {
  __$AppLogEntryCopyWithImpl(this._self, this._then);

  final _AppLogEntry _self;
  final $Res Function(_AppLogEntry) _then;

/// Create a copy of AppLogEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sessionId = null,Object? time = null,Object? level = null,Object? title = freezed,Object? message = null,Object? exception = freezed,Object? stackTrace = freezed,}) {
  return _then(_AppLogEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as int,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as AppLogLevel,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,exception: freezed == exception ? _self.exception : exception // ignore: cast_nullable_to_non_nullable
as String?,stackTrace: freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$AppLogEntryDraft {

 DateTime get time; AppLogLevel get level; String? get title; String get message; String? get exception; String? get stackTrace;
/// Create a copy of AppLogEntryDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppLogEntryDraftCopyWith<AppLogEntryDraft> get copyWith => _$AppLogEntryDraftCopyWithImpl<AppLogEntryDraft>(this as AppLogEntryDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppLogEntryDraft&&(identical(other.time, time) || other.time == time)&&(identical(other.level, level) || other.level == level)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.exception, exception) || other.exception == exception)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,time,level,title,message,exception,stackTrace);

@override
String toString() {
  return 'AppLogEntryDraft(time: $time, level: $level, title: $title, message: $message, exception: $exception, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class $AppLogEntryDraftCopyWith<$Res>  {
  factory $AppLogEntryDraftCopyWith(AppLogEntryDraft value, $Res Function(AppLogEntryDraft) _then) = _$AppLogEntryDraftCopyWithImpl;
@useResult
$Res call({
 DateTime time, AppLogLevel level, String? title, String message, String? exception, String? stackTrace
});




}
/// @nodoc
class _$AppLogEntryDraftCopyWithImpl<$Res>
    implements $AppLogEntryDraftCopyWith<$Res> {
  _$AppLogEntryDraftCopyWithImpl(this._self, this._then);

  final AppLogEntryDraft _self;
  final $Res Function(AppLogEntryDraft) _then;

/// Create a copy of AppLogEntryDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? time = null,Object? level = null,Object? title = freezed,Object? message = null,Object? exception = freezed,Object? stackTrace = freezed,}) {
  return _then(_self.copyWith(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as AppLogLevel,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,exception: freezed == exception ? _self.exception : exception // ignore: cast_nullable_to_non_nullable
as String?,stackTrace: freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppLogEntryDraft].
extension AppLogEntryDraftPatterns on AppLogEntryDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppLogEntryDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppLogEntryDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppLogEntryDraft value)  $default,){
final _that = this;
switch (_that) {
case _AppLogEntryDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppLogEntryDraft value)?  $default,){
final _that = this;
switch (_that) {
case _AppLogEntryDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime time,  AppLogLevel level,  String? title,  String message,  String? exception,  String? stackTrace)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppLogEntryDraft() when $default != null:
return $default(_that.time,_that.level,_that.title,_that.message,_that.exception,_that.stackTrace);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime time,  AppLogLevel level,  String? title,  String message,  String? exception,  String? stackTrace)  $default,) {final _that = this;
switch (_that) {
case _AppLogEntryDraft():
return $default(_that.time,_that.level,_that.title,_that.message,_that.exception,_that.stackTrace);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime time,  AppLogLevel level,  String? title,  String message,  String? exception,  String? stackTrace)?  $default,) {final _that = this;
switch (_that) {
case _AppLogEntryDraft() when $default != null:
return $default(_that.time,_that.level,_that.title,_that.message,_that.exception,_that.stackTrace);case _:
  return null;

}
}

}

/// @nodoc


class _AppLogEntryDraft implements AppLogEntryDraft {
  const _AppLogEntryDraft({required this.time, required this.level, required this.title, required this.message, required this.exception, required this.stackTrace});
  

@override final  DateTime time;
@override final  AppLogLevel level;
@override final  String? title;
@override final  String message;
@override final  String? exception;
@override final  String? stackTrace;

/// Create a copy of AppLogEntryDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppLogEntryDraftCopyWith<_AppLogEntryDraft> get copyWith => __$AppLogEntryDraftCopyWithImpl<_AppLogEntryDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppLogEntryDraft&&(identical(other.time, time) || other.time == time)&&(identical(other.level, level) || other.level == level)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.exception, exception) || other.exception == exception)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,time,level,title,message,exception,stackTrace);

@override
String toString() {
  return 'AppLogEntryDraft(time: $time, level: $level, title: $title, message: $message, exception: $exception, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class _$AppLogEntryDraftCopyWith<$Res> implements $AppLogEntryDraftCopyWith<$Res> {
  factory _$AppLogEntryDraftCopyWith(_AppLogEntryDraft value, $Res Function(_AppLogEntryDraft) _then) = __$AppLogEntryDraftCopyWithImpl;
@override @useResult
$Res call({
 DateTime time, AppLogLevel level, String? title, String message, String? exception, String? stackTrace
});




}
/// @nodoc
class __$AppLogEntryDraftCopyWithImpl<$Res>
    implements _$AppLogEntryDraftCopyWith<$Res> {
  __$AppLogEntryDraftCopyWithImpl(this._self, this._then);

  final _AppLogEntryDraft _self;
  final $Res Function(_AppLogEntryDraft) _then;

/// Create a copy of AppLogEntryDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? time = null,Object? level = null,Object? title = freezed,Object? message = null,Object? exception = freezed,Object? stackTrace = freezed,}) {
  return _then(_AppLogEntryDraft(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as AppLogLevel,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,exception: freezed == exception ? _self.exception : exception // ignore: cast_nullable_to_non_nullable
as String?,stackTrace: freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
