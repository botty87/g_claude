part of 'app_logs_cubit.dart';

@freezed
abstract class AppLogsState with _$AppLogsState {
  const factory AppLogsState({
    @Default([]) List<AppLogSession> sessions,
    int? selectedSessionId,
    @Default(true) bool loading,
  }) = _AppLogsState;
}
