part of 'shell_cubit.dart';

enum ActivityId { explorer, search, git, sessions, logs, terminal, settings }

@freezed
abstract class ShellState with _$ShellState {
  const factory ShellState({
    required ActivityId selectedActivity,
    @Default(false) bool sidebarCollapsed,
    // In-memory only (mirrors [sidebarCollapsed]) — the right panel collapse is
    // deliberately not persisted, to behave exactly like the left sidebar.
    @Default(false) bool rightPanelCollapsed,
  }) = _ShellState;
}
