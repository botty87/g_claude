part of 'shell_cubit.dart';

enum ActivityId { explorer, search, git, sessions, logs, terminal, settings }

@freezed
abstract class ShellState with _$ShellState {
  const factory ShellState({
    required ActivityId selectedActivity,
    @Default(false) bool sidebarCollapsed,
    @Default(<String, double>{}) Map<String, double> paneSizes,
  }) = _ShellState;
}
