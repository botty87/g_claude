// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_history_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WorkspaceHistory {

 List<ChatSessionSummary> get sessions; HistoryStatus get status; String? get selectedId; List<ClaudeMessage> get previewMessages; bool get previewLoading; String get query; List<ChatSessionSummary>? get searchResults; bool get searchLoading; Failure? get lastError;
/// Create a copy of WorkspaceHistory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspaceHistoryCopyWith<WorkspaceHistory> get copyWith => _$WorkspaceHistoryCopyWithImpl<WorkspaceHistory>(this as WorkspaceHistory, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceHistory&&const DeepCollectionEquality().equals(other.sessions, sessions)&&(identical(other.status, status) || other.status == status)&&(identical(other.selectedId, selectedId) || other.selectedId == selectedId)&&const DeepCollectionEquality().equals(other.previewMessages, previewMessages)&&(identical(other.previewLoading, previewLoading) || other.previewLoading == previewLoading)&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other.searchResults, searchResults)&&(identical(other.searchLoading, searchLoading) || other.searchLoading == searchLoading)&&(identical(other.lastError, lastError) || other.lastError == lastError));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(sessions),status,selectedId,const DeepCollectionEquality().hash(previewMessages),previewLoading,query,const DeepCollectionEquality().hash(searchResults),searchLoading,lastError);

@override
String toString() {
  return 'WorkspaceHistory(sessions: $sessions, status: $status, selectedId: $selectedId, previewMessages: $previewMessages, previewLoading: $previewLoading, query: $query, searchResults: $searchResults, searchLoading: $searchLoading, lastError: $lastError)';
}


}

/// @nodoc
abstract mixin class $WorkspaceHistoryCopyWith<$Res>  {
  factory $WorkspaceHistoryCopyWith(WorkspaceHistory value, $Res Function(WorkspaceHistory) _then) = _$WorkspaceHistoryCopyWithImpl;
@useResult
$Res call({
 List<ChatSessionSummary> sessions, HistoryStatus status, String? selectedId, List<ClaudeMessage> previewMessages, bool previewLoading, String query, List<ChatSessionSummary>? searchResults, bool searchLoading, Failure? lastError
});




}
/// @nodoc
class _$WorkspaceHistoryCopyWithImpl<$Res>
    implements $WorkspaceHistoryCopyWith<$Res> {
  _$WorkspaceHistoryCopyWithImpl(this._self, this._then);

  final WorkspaceHistory _self;
  final $Res Function(WorkspaceHistory) _then;

/// Create a copy of WorkspaceHistory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessions = null,Object? status = null,Object? selectedId = freezed,Object? previewMessages = null,Object? previewLoading = null,Object? query = null,Object? searchResults = freezed,Object? searchLoading = null,Object? lastError = freezed,}) {
  return _then(_self.copyWith(
sessions: null == sessions ? _self.sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<ChatSessionSummary>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HistoryStatus,selectedId: freezed == selectedId ? _self.selectedId : selectedId // ignore: cast_nullable_to_non_nullable
as String?,previewMessages: null == previewMessages ? _self.previewMessages : previewMessages // ignore: cast_nullable_to_non_nullable
as List<ClaudeMessage>,previewLoading: null == previewLoading ? _self.previewLoading : previewLoading // ignore: cast_nullable_to_non_nullable
as bool,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,searchResults: freezed == searchResults ? _self.searchResults : searchResults // ignore: cast_nullable_to_non_nullable
as List<ChatSessionSummary>?,searchLoading: null == searchLoading ? _self.searchLoading : searchLoading // ignore: cast_nullable_to_non_nullable
as bool,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkspaceHistory].
extension WorkspaceHistoryPatterns on WorkspaceHistory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkspaceHistory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkspaceHistory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkspaceHistory value)  $default,){
final _that = this;
switch (_that) {
case _WorkspaceHistory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkspaceHistory value)?  $default,){
final _that = this;
switch (_that) {
case _WorkspaceHistory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ChatSessionSummary> sessions,  HistoryStatus status,  String? selectedId,  List<ClaudeMessage> previewMessages,  bool previewLoading,  String query,  List<ChatSessionSummary>? searchResults,  bool searchLoading,  Failure? lastError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkspaceHistory() when $default != null:
return $default(_that.sessions,_that.status,_that.selectedId,_that.previewMessages,_that.previewLoading,_that.query,_that.searchResults,_that.searchLoading,_that.lastError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ChatSessionSummary> sessions,  HistoryStatus status,  String? selectedId,  List<ClaudeMessage> previewMessages,  bool previewLoading,  String query,  List<ChatSessionSummary>? searchResults,  bool searchLoading,  Failure? lastError)  $default,) {final _that = this;
switch (_that) {
case _WorkspaceHistory():
return $default(_that.sessions,_that.status,_that.selectedId,_that.previewMessages,_that.previewLoading,_that.query,_that.searchResults,_that.searchLoading,_that.lastError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ChatSessionSummary> sessions,  HistoryStatus status,  String? selectedId,  List<ClaudeMessage> previewMessages,  bool previewLoading,  String query,  List<ChatSessionSummary>? searchResults,  bool searchLoading,  Failure? lastError)?  $default,) {final _that = this;
switch (_that) {
case _WorkspaceHistory() when $default != null:
return $default(_that.sessions,_that.status,_that.selectedId,_that.previewMessages,_that.previewLoading,_that.query,_that.searchResults,_that.searchLoading,_that.lastError);case _:
  return null;

}
}

}

/// @nodoc


class _WorkspaceHistory implements WorkspaceHistory {
  const _WorkspaceHistory({final  List<ChatSessionSummary> sessions = const <ChatSessionSummary>[], this.status = HistoryStatus.idle, this.selectedId, final  List<ClaudeMessage> previewMessages = const <ClaudeMessage>[], this.previewLoading = false, this.query = '', final  List<ChatSessionSummary>? searchResults, this.searchLoading = false, this.lastError}): _sessions = sessions,_previewMessages = previewMessages,_searchResults = searchResults;
  

 final  List<ChatSessionSummary> _sessions;
@override@JsonKey() List<ChatSessionSummary> get sessions {
  if (_sessions is EqualUnmodifiableListView) return _sessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sessions);
}

@override@JsonKey() final  HistoryStatus status;
@override final  String? selectedId;
 final  List<ClaudeMessage> _previewMessages;
@override@JsonKey() List<ClaudeMessage> get previewMessages {
  if (_previewMessages is EqualUnmodifiableListView) return _previewMessages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_previewMessages);
}

@override@JsonKey() final  bool previewLoading;
@override@JsonKey() final  String query;
 final  List<ChatSessionSummary>? _searchResults;
@override List<ChatSessionSummary>? get searchResults {
  final value = _searchResults;
  if (value == null) return null;
  if (_searchResults is EqualUnmodifiableListView) return _searchResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey() final  bool searchLoading;
@override final  Failure? lastError;

/// Create a copy of WorkspaceHistory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkspaceHistoryCopyWith<_WorkspaceHistory> get copyWith => __$WorkspaceHistoryCopyWithImpl<_WorkspaceHistory>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceHistory&&const DeepCollectionEquality().equals(other._sessions, _sessions)&&(identical(other.status, status) || other.status == status)&&(identical(other.selectedId, selectedId) || other.selectedId == selectedId)&&const DeepCollectionEquality().equals(other._previewMessages, _previewMessages)&&(identical(other.previewLoading, previewLoading) || other.previewLoading == previewLoading)&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other._searchResults, _searchResults)&&(identical(other.searchLoading, searchLoading) || other.searchLoading == searchLoading)&&(identical(other.lastError, lastError) || other.lastError == lastError));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_sessions),status,selectedId,const DeepCollectionEquality().hash(_previewMessages),previewLoading,query,const DeepCollectionEquality().hash(_searchResults),searchLoading,lastError);

@override
String toString() {
  return 'WorkspaceHistory(sessions: $sessions, status: $status, selectedId: $selectedId, previewMessages: $previewMessages, previewLoading: $previewLoading, query: $query, searchResults: $searchResults, searchLoading: $searchLoading, lastError: $lastError)';
}


}

/// @nodoc
abstract mixin class _$WorkspaceHistoryCopyWith<$Res> implements $WorkspaceHistoryCopyWith<$Res> {
  factory _$WorkspaceHistoryCopyWith(_WorkspaceHistory value, $Res Function(_WorkspaceHistory) _then) = __$WorkspaceHistoryCopyWithImpl;
@override @useResult
$Res call({
 List<ChatSessionSummary> sessions, HistoryStatus status, String? selectedId, List<ClaudeMessage> previewMessages, bool previewLoading, String query, List<ChatSessionSummary>? searchResults, bool searchLoading, Failure? lastError
});




}
/// @nodoc
class __$WorkspaceHistoryCopyWithImpl<$Res>
    implements _$WorkspaceHistoryCopyWith<$Res> {
  __$WorkspaceHistoryCopyWithImpl(this._self, this._then);

  final _WorkspaceHistory _self;
  final $Res Function(_WorkspaceHistory) _then;

/// Create a copy of WorkspaceHistory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessions = null,Object? status = null,Object? selectedId = freezed,Object? previewMessages = null,Object? previewLoading = null,Object? query = null,Object? searchResults = freezed,Object? searchLoading = null,Object? lastError = freezed,}) {
  return _then(_WorkspaceHistory(
sessions: null == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<ChatSessionSummary>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HistoryStatus,selectedId: freezed == selectedId ? _self.selectedId : selectedId // ignore: cast_nullable_to_non_nullable
as String?,previewMessages: null == previewMessages ? _self._previewMessages : previewMessages // ignore: cast_nullable_to_non_nullable
as List<ClaudeMessage>,previewLoading: null == previewLoading ? _self.previewLoading : previewLoading // ignore: cast_nullable_to_non_nullable
as bool,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,searchResults: freezed == searchResults ? _self._searchResults : searchResults // ignore: cast_nullable_to_non_nullable
as List<ChatSessionSummary>?,searchLoading: null == searchLoading ? _self.searchLoading : searchLoading // ignore: cast_nullable_to_non_nullable
as bool,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

/// @nodoc
mixin _$ChatHistoryState {

 Map<String, WorkspaceHistory> get byWorkspace;
/// Create a copy of ChatHistoryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatHistoryStateCopyWith<ChatHistoryState> get copyWith => _$ChatHistoryStateCopyWithImpl<ChatHistoryState>(this as ChatHistoryState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatHistoryState&&const DeepCollectionEquality().equals(other.byWorkspace, byWorkspace));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(byWorkspace));

@override
String toString() {
  return 'ChatHistoryState(byWorkspace: $byWorkspace)';
}


}

/// @nodoc
abstract mixin class $ChatHistoryStateCopyWith<$Res>  {
  factory $ChatHistoryStateCopyWith(ChatHistoryState value, $Res Function(ChatHistoryState) _then) = _$ChatHistoryStateCopyWithImpl;
@useResult
$Res call({
 Map<String, WorkspaceHistory> byWorkspace
});




}
/// @nodoc
class _$ChatHistoryStateCopyWithImpl<$Res>
    implements $ChatHistoryStateCopyWith<$Res> {
  _$ChatHistoryStateCopyWithImpl(this._self, this._then);

  final ChatHistoryState _self;
  final $Res Function(ChatHistoryState) _then;

/// Create a copy of ChatHistoryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? byWorkspace = null,}) {
  return _then(_self.copyWith(
byWorkspace: null == byWorkspace ? _self.byWorkspace : byWorkspace // ignore: cast_nullable_to_non_nullable
as Map<String, WorkspaceHistory>,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatHistoryState].
extension ChatHistoryStatePatterns on ChatHistoryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatHistoryState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatHistoryState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatHistoryState value)  $default,){
final _that = this;
switch (_that) {
case _ChatHistoryState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatHistoryState value)?  $default,){
final _that = this;
switch (_that) {
case _ChatHistoryState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, WorkspaceHistory> byWorkspace)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatHistoryState() when $default != null:
return $default(_that.byWorkspace);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, WorkspaceHistory> byWorkspace)  $default,) {final _that = this;
switch (_that) {
case _ChatHistoryState():
return $default(_that.byWorkspace);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, WorkspaceHistory> byWorkspace)?  $default,) {final _that = this;
switch (_that) {
case _ChatHistoryState() when $default != null:
return $default(_that.byWorkspace);case _:
  return null;

}
}

}

/// @nodoc


class _ChatHistoryState extends ChatHistoryState {
  const _ChatHistoryState({final  Map<String, WorkspaceHistory> byWorkspace = const <String, WorkspaceHistory>{}}): _byWorkspace = byWorkspace,super._();
  

 final  Map<String, WorkspaceHistory> _byWorkspace;
@override@JsonKey() Map<String, WorkspaceHistory> get byWorkspace {
  if (_byWorkspace is EqualUnmodifiableMapView) return _byWorkspace;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_byWorkspace);
}


/// Create a copy of ChatHistoryState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatHistoryStateCopyWith<_ChatHistoryState> get copyWith => __$ChatHistoryStateCopyWithImpl<_ChatHistoryState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatHistoryState&&const DeepCollectionEquality().equals(other._byWorkspace, _byWorkspace));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_byWorkspace));

@override
String toString() {
  return 'ChatHistoryState(byWorkspace: $byWorkspace)';
}


}

/// @nodoc
abstract mixin class _$ChatHistoryStateCopyWith<$Res> implements $ChatHistoryStateCopyWith<$Res> {
  factory _$ChatHistoryStateCopyWith(_ChatHistoryState value, $Res Function(_ChatHistoryState) _then) = __$ChatHistoryStateCopyWithImpl;
@override @useResult
$Res call({
 Map<String, WorkspaceHistory> byWorkspace
});




}
/// @nodoc
class __$ChatHistoryStateCopyWithImpl<$Res>
    implements _$ChatHistoryStateCopyWith<$Res> {
  __$ChatHistoryStateCopyWithImpl(this._self, this._then);

  final _ChatHistoryState _self;
  final $Res Function(_ChatHistoryState) _then;

/// Create a copy of ChatHistoryState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? byWorkspace = null,}) {
  return _then(_ChatHistoryState(
byWorkspace: null == byWorkspace ? _self._byWorkspace : byWorkspace // ignore: cast_nullable_to_non_nullable
as Map<String, WorkspaceHistory>,
  ));
}


}

// dart format on
