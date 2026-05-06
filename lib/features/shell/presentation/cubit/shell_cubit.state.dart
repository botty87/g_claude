part of 'shell_cubit.dart';

enum ActivityId { explorer, search, git, sessions, logs, terminal, settings }

@freezed
abstract class ShellState with _$ShellState {
  const factory ShellState({
    required bool workspaceOpen,
    required ActivityId selectedActivity,
    @Default(<String, double>{}) Map<String, double> paneSizes,
  }) = _ShellState;
}
