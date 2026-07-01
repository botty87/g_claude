// [ClaudeSessionsCubit] multi-tab contracts (Fase 4): a workspace holds N chat
// sessions as tabs. `sessionFor(wid)` returns the ACTIVE tab; open/switch/close
// mutate the tab set and the active tab id, never leaving a workspace with zero
// tabs.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/core/error/failures.dart';
import 'package:g_claude/core/l10n/l10n.dart';
import 'package:g_claude/core/utils/either.dart';
import 'package:g_claude/features/claude/data/datasources/claude_history_datasource.dart';
import 'package:g_claude/features/claude/domain/entities/claude_event.dart';
import 'package:g_claude/features/claude/domain/entities/claude_permission_mode.dart';
import 'package:g_claude/features/claude/domain/entities/mcp_server.dart';
import 'package:g_claude/features/claude/domain/repositories/claude_repository.dart';
import 'package:g_claude/features/claude/domain/usecases/authenticate_mcp_server.dart';
import 'package:g_claude/features/claude/domain/usecases/list_mcp_servers.dart';
import 'package:g_claude/features/claude/domain/usecases/load_session_messages.dart';
import 'package:g_claude/features/claude/domain/usecases/send_prompt.dart';
import 'package:g_claude/features/claude/domain/usecases/stop_run.dart';
import 'package:g_claude/features/claude/presentation/cubit/claude_sessions_cubit.dart';
import 'package:g_claude/features/workspace/domain/entities/workspace.dart';
import 'package:g_claude/features/workspace/presentation/cubit/workspaces_cubit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/fakes.dart';

class _MockSendPrompt extends Mock implements SendPrompt {}

class _MockStopRun extends Mock implements StopRun {}

class _MockListMcpServers extends Mock implements ListMcpServers {}

class _MockAuthenticateMcpServer extends Mock implements AuthenticateMcpServer {}

class _MockLoadSessionMessages extends Mock implements LoadSessionMessages {}

class _MockClaudeHistoryDataSource extends Mock implements ClaudeHistoryDataSource {}

class _MockWorkspacesCubit extends Mock implements WorkspacesCubit {}

class _MockClaudeRepository extends Mock implements ClaudeRepository {}

const _wid = '/proj';

late SharedPreferences _prefs;

ClaudeSessionsCubit _makeCubit() {
  final sendPrompt = _MockSendPrompt();
  final stopRun = _MockStopRun();
  final listMcpServers = _MockListMcpServers();
  final authenticateMcpServer = _MockAuthenticateMcpServer();
  final loadSessionMessages = _MockLoadSessionMessages();
  final historyDs = _MockClaudeHistoryDataSource();
  final wsCubit = _MockWorkspacesCubit();
  final repo = _MockClaudeRepository();

  final ws = Workspace(id: _wid, path: _wid, name: 'proj', openedAt: DateTime.utc(2026, 1, 1));
  when(() => wsCubit.state).thenReturn(WorkspacesState.loaded(workspaces: [ws], activeId: ws.id));
  when(() => wsCubit.stream).thenAnswer((_) => const Stream.empty());
  when(() => sendPrompt.call(any())).thenAnswer((_) => const Stream<Either<Failure, ClaudeEvent>>.empty());
  when(() => stopRun.call(sid: any(named: 'sid'))).thenAnswer((_) async {});
  when(() => listMcpServers.call()).thenAnswer((_) async => const Right(<McpServer>[]));

  final cubit = ClaudeSessionsCubit(
    sendPrompt,
    stopRun,
    listMcpServers,
    authenticateMcpServer,
    loadSessionMessages,
    historyDs,
    wsCubit,
    repo,
    _prefs,
    makeTestTalker(),
  );
  cubit.init();
  return cubit;
}

void main() {
  setUpAll(() {
    registerFallbackValue(const SendPromptParams(cwd: '/fallback', prompt: '', mode: ClaudePermissionMode.defaultMode));
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    _prefs = await SharedPreferences.getInstance();
  });

  test('a fresh workspace starts with exactly one active tab', () {
    final cubit = _makeCubit();
    expect(cubit.state.tabsList(_wid), hasLength(1));
    final active = cubit.state.sessionFor(_wid);
    expect(active, isNotNull);
    expect(cubit.state.tabsFor(_wid)!.activeTabId, active!.tabId);
    cubit.close();
  });

  test('openNewSession appends a tab and makes it active', () {
    final cubit = _makeCubit();
    final firstId = cubit.state.sessionFor(_wid)!.tabId;

    cubit.openNewSession(_wid);

    expect(cubit.state.tabsList(_wid), hasLength(2));
    final active = cubit.state.sessionFor(_wid)!;
    expect(active.tabId, isNot(firstId));
    expect(active.messages, isEmpty);
    expect(active.claudeSessionId, isNull);
    cubit.close();
  });

  test('switchTab activates the requested tab; sessionFor follows it', () {
    final cubit = _makeCubit();
    final firstId = cubit.state.sessionFor(_wid)!.tabId;
    cubit.openNewSession(_wid); // second tab now active

    cubit.switchTab(_wid, firstId);

    expect(cubit.state.tabsFor(_wid)!.activeTabId, firstId);
    expect(cubit.state.sessionFor(_wid)!.tabId, firstId);
    cubit.close();
  });

  test('closeTab removes a tab and picks a neighbor as active', () {
    final cubit = _makeCubit();
    final firstId = cubit.state.sessionFor(_wid)!.tabId;
    cubit.openNewSession(_wid);
    final secondId = cubit.state.sessionFor(_wid)!.tabId;

    // Close the active (second) tab → falls back to the first.
    cubit.closeTab(_wid, secondId);

    expect(cubit.state.tabsList(_wid), hasLength(1));
    expect(cubit.state.tabsFor(_wid)!.activeTabId, firstId);
    cubit.close();
  });

  test('closing the last tab recreates a fresh empty one (never zero tabs)', () {
    final cubit = _makeCubit();
    final onlyId = cubit.state.sessionFor(_wid)!.tabId;

    cubit.closeTab(_wid, onlyId);

    final tabs = cubit.state.tabsList(_wid);
    expect(tabs, hasLength(1));
    expect(tabs.single.tabId, isNot(onlyId));
    expect(tabs.single.messages, isEmpty);
    cubit.close();
  });

  test('sessionTitle: first user message wins, else the new-tab label', () {
    final cubit = _makeCubit();
    final empty = cubit.state.sessionFor(_wid)!;
    expect(ClaudeSessionsCubit.sessionTitle(empty), Locales.Claude.Session.newTab);
    cubit.close();
  });
}
