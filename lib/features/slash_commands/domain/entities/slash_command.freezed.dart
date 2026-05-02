// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slash_command.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SlashCommand {

 String get name; String get trigger; String get description; String? get argumentHint; SlashCommandSource get source; String? get filePath; List<String> get allowedTools;
/// Create a copy of SlashCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlashCommandCopyWith<SlashCommand> get copyWith => _$SlashCommandCopyWithImpl<SlashCommand>(this as SlashCommand, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlashCommand&&(identical(other.name, name) || other.name == name)&&(identical(other.trigger, trigger) || other.trigger == trigger)&&(identical(other.description, description) || other.description == description)&&(identical(other.argumentHint, argumentHint) || other.argumentHint == argumentHint)&&(identical(other.source, source) || other.source == source)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&const DeepCollectionEquality().equals(other.allowedTools, allowedTools));
}


@override
int get hashCode => Object.hash(runtimeType,name,trigger,description,argumentHint,source,filePath,const DeepCollectionEquality().hash(allowedTools));

@override
String toString() {
  return 'SlashCommand(name: $name, trigger: $trigger, description: $description, argumentHint: $argumentHint, source: $source, filePath: $filePath, allowedTools: $allowedTools)';
}


}

/// @nodoc
abstract mixin class $SlashCommandCopyWith<$Res>  {
  factory $SlashCommandCopyWith(SlashCommand value, $Res Function(SlashCommand) _then) = _$SlashCommandCopyWithImpl;
@useResult
$Res call({
 String name, String trigger, String description, String? argumentHint, SlashCommandSource source, String? filePath, List<String> allowedTools
});




}
/// @nodoc
class _$SlashCommandCopyWithImpl<$Res>
    implements $SlashCommandCopyWith<$Res> {
  _$SlashCommandCopyWithImpl(this._self, this._then);

  final SlashCommand _self;
  final $Res Function(SlashCommand) _then;

/// Create a copy of SlashCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? trigger = null,Object? description = null,Object? argumentHint = freezed,Object? source = null,Object? filePath = freezed,Object? allowedTools = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,trigger: null == trigger ? _self.trigger : trigger // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,argumentHint: freezed == argumentHint ? _self.argumentHint : argumentHint // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as SlashCommandSource,filePath: freezed == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String?,allowedTools: null == allowedTools ? _self.allowedTools : allowedTools // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SlashCommand].
extension SlashCommandPatterns on SlashCommand {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SlashCommand value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SlashCommand() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SlashCommand value)  $default,){
final _that = this;
switch (_that) {
case _SlashCommand():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SlashCommand value)?  $default,){
final _that = this;
switch (_that) {
case _SlashCommand() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String trigger,  String description,  String? argumentHint,  SlashCommandSource source,  String? filePath,  List<String> allowedTools)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SlashCommand() when $default != null:
return $default(_that.name,_that.trigger,_that.description,_that.argumentHint,_that.source,_that.filePath,_that.allowedTools);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String trigger,  String description,  String? argumentHint,  SlashCommandSource source,  String? filePath,  List<String> allowedTools)  $default,) {final _that = this;
switch (_that) {
case _SlashCommand():
return $default(_that.name,_that.trigger,_that.description,_that.argumentHint,_that.source,_that.filePath,_that.allowedTools);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String trigger,  String description,  String? argumentHint,  SlashCommandSource source,  String? filePath,  List<String> allowedTools)?  $default,) {final _that = this;
switch (_that) {
case _SlashCommand() when $default != null:
return $default(_that.name,_that.trigger,_that.description,_that.argumentHint,_that.source,_that.filePath,_that.allowedTools);case _:
  return null;

}
}

}

/// @nodoc


class _SlashCommand implements SlashCommand {
  const _SlashCommand({required this.name, required this.trigger, required this.description, this.argumentHint, required this.source, this.filePath, final  List<String> allowedTools = const <String>[]}): _allowedTools = allowedTools;
  

@override final  String name;
@override final  String trigger;
@override final  String description;
@override final  String? argumentHint;
@override final  SlashCommandSource source;
@override final  String? filePath;
 final  List<String> _allowedTools;
@override@JsonKey() List<String> get allowedTools {
  if (_allowedTools is EqualUnmodifiableListView) return _allowedTools;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allowedTools);
}


/// Create a copy of SlashCommand
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SlashCommandCopyWith<_SlashCommand> get copyWith => __$SlashCommandCopyWithImpl<_SlashCommand>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SlashCommand&&(identical(other.name, name) || other.name == name)&&(identical(other.trigger, trigger) || other.trigger == trigger)&&(identical(other.description, description) || other.description == description)&&(identical(other.argumentHint, argumentHint) || other.argumentHint == argumentHint)&&(identical(other.source, source) || other.source == source)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&const DeepCollectionEquality().equals(other._allowedTools, _allowedTools));
}


@override
int get hashCode => Object.hash(runtimeType,name,trigger,description,argumentHint,source,filePath,const DeepCollectionEquality().hash(_allowedTools));

@override
String toString() {
  return 'SlashCommand(name: $name, trigger: $trigger, description: $description, argumentHint: $argumentHint, source: $source, filePath: $filePath, allowedTools: $allowedTools)';
}


}

/// @nodoc
abstract mixin class _$SlashCommandCopyWith<$Res> implements $SlashCommandCopyWith<$Res> {
  factory _$SlashCommandCopyWith(_SlashCommand value, $Res Function(_SlashCommand) _then) = __$SlashCommandCopyWithImpl;
@override @useResult
$Res call({
 String name, String trigger, String description, String? argumentHint, SlashCommandSource source, String? filePath, List<String> allowedTools
});




}
/// @nodoc
class __$SlashCommandCopyWithImpl<$Res>
    implements _$SlashCommandCopyWith<$Res> {
  __$SlashCommandCopyWithImpl(this._self, this._then);

  final _SlashCommand _self;
  final $Res Function(_SlashCommand) _then;

/// Create a copy of SlashCommand
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? trigger = null,Object? description = null,Object? argumentHint = freezed,Object? source = null,Object? filePath = freezed,Object? allowedTools = null,}) {
  return _then(_SlashCommand(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,trigger: null == trigger ? _self.trigger : trigger // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,argumentHint: freezed == argumentHint ? _self.argumentHint : argumentHint // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as SlashCommandSource,filePath: freezed == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String?,allowedTools: null == allowedTools ? _self._allowedTools : allowedTools // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
