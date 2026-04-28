part of 'shell_cubit.dart';

enum ActivityId { explorer, search, git, sessions, settings }

@freezed
abstract class ShellState with _$ShellState {
  const factory ShellState({
    required bool sidePanelOpen,
    required ActivityId selectedActivity,
  }) = _ShellState;
}
