// State-machine contracts for [ShellCubit].
//
// The cubit owns the shell chrome flags: the collapsible workspace sidebar
// (`sidebarCollapsed`, toggled by the sidebar chevron / Cmd+B), the selected
// activity (mini-rail), and persisted pane sizes.

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/editor/presentation/cubit/file_tabs_cubit.dart';
import 'package:g_claude/features/shell/presentation/cubit/shell_cubit.dart';
import 'package:g_claude/features/workspace/presentation/cubit/workspaces_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockFileTabsCubit extends Mock implements FileTabsCubit {}

class _MockWorkspacesCubit extends Mock implements WorkspacesCubit {}

ShellCubit _makeCubit({
  required _MockFileTabsCubit tabs,
  required _MockWorkspacesCubit workspaces,
  required StreamController<FileTabsState> tabsController,
}) {
  when(() => tabs.stream).thenAnswer((_) => tabsController.stream);
  when(() => workspaces.state).thenReturn(const WorkspacesState.initial());
  final cubit = ShellCubit(tabs, workspaces);
  cubit.init();
  return cubit;
}

void main() {
  late _MockFileTabsCubit tabs;
  late _MockWorkspacesCubit workspaces;
  late StreamController<FileTabsState> tabsController;

  setUp(() {
    tabs = _MockFileTabsCubit();
    workspaces = _MockWorkspacesCubit();
    tabsController = StreamController<FileTabsState>.broadcast();
  });

  tearDown(() => tabsController.close());

  test('starts expanded (sidebarCollapsed=false) on the explorer activity', () {
    final cubit = _makeCubit(tabs: tabs, workspaces: workspaces, tabsController: tabsController);
    expect(cubit.state.sidebarCollapsed, isFalse);
    expect(cubit.state.selectedActivity, ActivityId.explorer);
    cubit.close();
  });

  blocTest<ShellCubit, ShellState>(
    'toggleSidebar flips sidebarCollapsed on each call',
    build: () => _makeCubit(tabs: tabs, workspaces: workspaces, tabsController: tabsController),
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
    build: () => _makeCubit(tabs: tabs, workspaces: workspaces, tabsController: tabsController),
    act: (c) => c.setSidebarCollapsed(false),
    expect: () => const <ShellState>[],
  );

  blocTest<ShellCubit, ShellState>(
    'selectActivity switches the active section',
    build: () => _makeCubit(tabs: tabs, workspaces: workspaces, tabsController: tabsController),
    act: (c) => c.selectActivity(ActivityId.terminal),
    expect: () => [isA<ShellState>().having((s) => s.selectedActivity, 'activity', ActivityId.terminal)],
  );
}
