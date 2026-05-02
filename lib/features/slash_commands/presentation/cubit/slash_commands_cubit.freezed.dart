// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slash_commands_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SlashCommandsState {

 List<SlashCommand> get all;
/// Create a copy of SlashCommandsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlashCommandsStateCopyWith<SlashCommandsState> get copyWith => _$SlashCommandsStateCopyWithImpl<SlashCommandsState>(this as SlashCommandsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlashCommandsState&&const DeepCollectionEquality().equals(other.all, all));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(all));

@override
String toString() {
  return 'SlashCommandsState(all: $all)';
}


}

/// @nodoc
abstract mixin class $SlashCommandsStateCopyWith<$Res>  {
  factory $SlashCommandsStateCopyWith(SlashCommandsState value, $Res Function(SlashCommandsState) _then) = _$SlashCommandsStateCopyWithImpl;
@useResult
$Res call({
 List<SlashCommand> all
});




}
/// @nodoc
class _$SlashCommandsStateCopyWithImpl<$Res>
    implements $SlashCommandsStateCopyWith<$Res> {
  _$SlashCommandsStateCopyWithImpl(this._self, this._then);

  final SlashCommandsState _self;
  final $Res Function(SlashCommandsState) _then;

/// Create a copy of SlashCommandsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? all = null,}) {
  return _then(_self.copyWith(
all: null == all ? _self.all : all // ignore: cast_nullable_to_non_nullable
as List<SlashCommand>,
  ));
}

}


/// Adds pattern-matching-related methods to [SlashCommandsState].
extension SlashCommandsStatePatterns on SlashCommandsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SlashCommandsStateIdle value)?  idle,TResult Function( SlashCommandsStateSuggesting value)?  suggesting,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SlashCommandsStateIdle() when idle != null:
return idle(_that);case SlashCommandsStateSuggesting() when suggesting != null:
return suggesting(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SlashCommandsStateIdle value)  idle,required TResult Function( SlashCommandsStateSuggesting value)  suggesting,}){
final _that = this;
switch (_that) {
case SlashCommandsStateIdle():
return idle(_that);case SlashCommandsStateSuggesting():
return suggesting(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SlashCommandsStateIdle value)?  idle,TResult? Function( SlashCommandsStateSuggesting value)?  suggesting,}){
final _that = this;
switch (_that) {
case SlashCommandsStateIdle() when idle != null:
return idle(_that);case SlashCommandsStateSuggesting() when suggesting != null:
return suggesting(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<SlashCommand> all)?  idle,TResult Function( List<SlashCommand> all,  List<SlashCommand> filtered,  int selectedIndex,  String filter)?  suggesting,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SlashCommandsStateIdle() when idle != null:
return idle(_that.all);case SlashCommandsStateSuggesting() when suggesting != null:
return suggesting(_that.all,_that.filtered,_that.selectedIndex,_that.filter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<SlashCommand> all)  idle,required TResult Function( List<SlashCommand> all,  List<SlashCommand> filtered,  int selectedIndex,  String filter)  suggesting,}) {final _that = this;
switch (_that) {
case SlashCommandsStateIdle():
return idle(_that.all);case SlashCommandsStateSuggesting():
return suggesting(_that.all,_that.filtered,_that.selectedIndex,_that.filter);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<SlashCommand> all)?  idle,TResult? Function( List<SlashCommand> all,  List<SlashCommand> filtered,  int selectedIndex,  String filter)?  suggesting,}) {final _that = this;
switch (_that) {
case SlashCommandsStateIdle() when idle != null:
return idle(_that.all);case SlashCommandsStateSuggesting() when suggesting != null:
return suggesting(_that.all,_that.filtered,_that.selectedIndex,_that.filter);case _:
  return null;

}
}

}

/// @nodoc


class SlashCommandsStateIdle implements SlashCommandsState {
  const SlashCommandsStateIdle({final  List<SlashCommand> all = const <SlashCommand>[]}): _all = all;
  

 final  List<SlashCommand> _all;
@override@JsonKey() List<SlashCommand> get all {
  if (_all is EqualUnmodifiableListView) return _all;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_all);
}


/// Create a copy of SlashCommandsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlashCommandsStateIdleCopyWith<SlashCommandsStateIdle> get copyWith => _$SlashCommandsStateIdleCopyWithImpl<SlashCommandsStateIdle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlashCommandsStateIdle&&const DeepCollectionEquality().equals(other._all, _all));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_all));

@override
String toString() {
  return 'SlashCommandsState.idle(all: $all)';
}


}

/// @nodoc
abstract mixin class $SlashCommandsStateIdleCopyWith<$Res> implements $SlashCommandsStateCopyWith<$Res> {
  factory $SlashCommandsStateIdleCopyWith(SlashCommandsStateIdle value, $Res Function(SlashCommandsStateIdle) _then) = _$SlashCommandsStateIdleCopyWithImpl;
@override @useResult
$Res call({
 List<SlashCommand> all
});




}
/// @nodoc
class _$SlashCommandsStateIdleCopyWithImpl<$Res>
    implements $SlashCommandsStateIdleCopyWith<$Res> {
  _$SlashCommandsStateIdleCopyWithImpl(this._self, this._then);

  final SlashCommandsStateIdle _self;
  final $Res Function(SlashCommandsStateIdle) _then;

/// Create a copy of SlashCommandsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? all = null,}) {
  return _then(SlashCommandsStateIdle(
all: null == all ? _self._all : all // ignore: cast_nullable_to_non_nullable
as List<SlashCommand>,
  ));
}


}

/// @nodoc


class SlashCommandsStateSuggesting implements SlashCommandsState {
  const SlashCommandsStateSuggesting({required final  List<SlashCommand> all, required final  List<SlashCommand> filtered, required this.selectedIndex, required this.filter}): _all = all,_filtered = filtered;
  

 final  List<SlashCommand> _all;
@override List<SlashCommand> get all {
  if (_all is EqualUnmodifiableListView) return _all;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_all);
}

 final  List<SlashCommand> _filtered;
 List<SlashCommand> get filtered {
  if (_filtered is EqualUnmodifiableListView) return _filtered;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_filtered);
}

 final  int selectedIndex;
 final  String filter;

/// Create a copy of SlashCommandsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlashCommandsStateSuggestingCopyWith<SlashCommandsStateSuggesting> get copyWith => _$SlashCommandsStateSuggestingCopyWithImpl<SlashCommandsStateSuggesting>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SlashCommandsStateSuggesting&&const DeepCollectionEquality().equals(other._all, _all)&&const DeepCollectionEquality().equals(other._filtered, _filtered)&&(identical(other.selectedIndex, selectedIndex) || other.selectedIndex == selectedIndex)&&(identical(other.filter, filter) || other.filter == filter));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_all),const DeepCollectionEquality().hash(_filtered),selectedIndex,filter);

@override
String toString() {
  return 'SlashCommandsState.suggesting(all: $all, filtered: $filtered, selectedIndex: $selectedIndex, filter: $filter)';
}


}

/// @nodoc
abstract mixin class $SlashCommandsStateSuggestingCopyWith<$Res> implements $SlashCommandsStateCopyWith<$Res> {
  factory $SlashCommandsStateSuggestingCopyWith(SlashCommandsStateSuggesting value, $Res Function(SlashCommandsStateSuggesting) _then) = _$SlashCommandsStateSuggestingCopyWithImpl;
@override @useResult
$Res call({
 List<SlashCommand> all, List<SlashCommand> filtered, int selectedIndex, String filter
});




}
/// @nodoc
class _$SlashCommandsStateSuggestingCopyWithImpl<$Res>
    implements $SlashCommandsStateSuggestingCopyWith<$Res> {
  _$SlashCommandsStateSuggestingCopyWithImpl(this._self, this._then);

  final SlashCommandsStateSuggesting _self;
  final $Res Function(SlashCommandsStateSuggesting) _then;

/// Create a copy of SlashCommandsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? all = null,Object? filtered = null,Object? selectedIndex = null,Object? filter = null,}) {
  return _then(SlashCommandsStateSuggesting(
all: null == all ? _self._all : all // ignore: cast_nullable_to_non_nullable
as List<SlashCommand>,filtered: null == filtered ? _self._filtered : filtered // ignore: cast_nullable_to_non_nullable
as List<SlashCommand>,selectedIndex: null == selectedIndex ? _self.selectedIndex : selectedIndex // ignore: cast_nullable_to_non_nullable
as int,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
