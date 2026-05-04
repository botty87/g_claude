part of 'app_log_detail_cubit.dart';

@freezed
abstract class AppLogDetailState with _$AppLogDetailState {
  const factory AppLogDetailState({
    int? sessionId,
    @Default([]) List<AppLogEntry> entries,
    @Default({}) Set<AppLogLevel> levelFilter,
    @Default('') String search,
    @Default(true) bool loading,
  }) = _AppLogDetailState;
}
