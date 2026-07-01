// State-machine contracts for [ShellCubit].
//
// The cubit owns the shell chrome flags: the collapsible workspace sidebar
// (`sidebarCollapsed`, toggled by the sidebar chevron / Cmd+B), the selected
// activity (mini-rail), and persisted pane sizes.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/shell/presentation/cubit/shell_cubit.dart';

void main() {
  test('starts expanded (sidebarCollapsed=false) on the explorer activity', () {
    final cubit = ShellCubit();
    expect(cubit.state.sidebarCollapsed, isFalse);
    expect(cubit.state.selectedActivity, ActivityId.explorer);
    cubit.close();
  });

  blocTest<ShellCubit, ShellState>(
    'toggleSidebar flips sidebarCollapsed on each call',
    build: ShellCubit.new,
    act: (c) => c
      ..toggleSidebar()
      ..toggleSidebar(),
    expect: () => [
      isA<ShellState>().having((s) => s.sidebarCollapsed, 'collapsed', true),
      isA<ShellState>().having((s) => s.sidebarCollapsed, 'collapsed', false),
    ],
  );

  blocTest<ShellCubit, ShellState>(
    'setSidebarCollapsed is a no-op when the value is unchanged',
    build: ShellCubit.new,
    act: (c) => c.setSidebarCollapsed(false),
    expect: () => const <ShellState>[],
  );

  blocTest<ShellCubit, ShellState>(
    'selectActivity switches the active section',
    build: ShellCubit.new,
    act: (c) => c.selectActivity(ActivityId.terminal),
    expect: () => [isA<ShellState>().having((s) => s.selectedActivity, 'activity', ActivityId.terminal)],
  );
}
