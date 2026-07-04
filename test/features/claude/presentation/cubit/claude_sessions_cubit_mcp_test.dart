// [ClaudeSessionsCubit] MCP list handling. Covers the `sessionInit.mcpServers`
// merge contract that was previously only reachable through a full event
// round-trip against a private, TTL-gated cache. The list now lives in emitted
// state (`state.mcpServers`) so the "N active" count is reactive, and
// `mergeMcpServersFromSessionInit` is a `@visibleForTesting` seam:
//
//   1. merge into empty state adds every incoming server.
//   2. merge updates the status of a known server WITHOUT losing its
//      `commandOrUrl` (sessionInit doesn't carry it), and leaves others intact.
//   3. an empty merge is a no-op.
//   4. `ensureMcpServers` publishes the loaded list into emitted state.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/core/error/failures.dart';
import 'package:g_claude/core/utils/either.dart';
import 'package:g_claude/features/claude/data/datasources/claude_history_datasource.dart';
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

late SharedPreferences _sharedPrefs;

McpServer _srv(String name, McpServerStatus status, {String cmd = ''}) =>
    McpServer(name: name, displayName: name, commandOrUrl: cmd, status: status);

/// Builds a cubit with mocked collaborators. [seed] is what `listMcpServers`
/// returns, so a test can pre-populate `state.mcpServers` via `ensureMcpServers`.
ClaudeSessionsCubit _makeCubit({List<McpServer> seed = const [], AuthenticateMcpServer? auth}) {
  final listMcpServers = _MockListMcpServers();
  final wsCubit = _MockWorkspacesCubit();
  final ws = Workspace(id: _wid, path: _wid, name: 'proj', openedAt: DateTime.utc(2026, 1, 1));
  when(() => wsCubit.state).thenReturn(WorkspacesState.loaded(workspaces: [ws], activeId: ws.id));
  when(() => wsCubit.stream).thenAnswer((_) => const Stream.empty());
  when(() => listMcpServers.call()).thenAnswer((_) async => Right(seed));

  final cubit = ClaudeSessionsCubit(
    _MockSendPrompt(),
    _MockStopRun(),
    listMcpServers,
    auth ?? _MockAuthenticateMcpServer(),
    _MockLoadSessionMessages(),
    _MockClaudeHistoryDataSource(),
    wsCubit,
    _MockClaudeRepository(),
    _sharedPrefs,
    makeTestTalker(),
  );
  cubit.init();
  return cubit;
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    _sharedPrefs = await SharedPreferences.getInstance();
  });

  group('mergeMcpServersFromSessionInit', () {
    test('merge into empty state adds every incoming server', () async {
      final cubit = _makeCubit();
      cubit.mergeMcpServersFromSessionInit([
        _srv('claude.ai Slack', McpServerStatus.connected),
        _srv('claude.ai n8n', McpServerStatus.needsAuth),
      ]);

      final byName = {for (final s in cubit.state.mcpServers) s.name: s};
      expect(byName.keys, containsAll(['claude.ai Slack', 'claude.ai n8n']));
      expect(byName['claude.ai n8n']!.status, McpServerStatus.needsAuth);

      await cubit.close();
    });

    test('updates status of a known server, preserves commandOrUrl, leaves others', () async {
      final cubit = _makeCubit(
        seed: [
          _srv('context7', McpServerStatus.unknown, cmd: 'npx -y @upstash/context7-mcp'),
          _srv('dart', McpServerStatus.connected, cmd: 'dart mcp-server'),
        ],
      );
      // Publish the seed into emitted state.
      await cubit.ensureMcpServers();

      // sessionInit carries status only (no commandOrUrl).
      cubit.mergeMcpServersFromSessionInit([_srv('context7', McpServerStatus.connected)]);

      final byName = {for (final s in cubit.state.mcpServers) s.name: s};
      expect(byName['context7']!.status, McpServerStatus.connected);
      expect(byName['context7']!.commandOrUrl, 'npx -y @upstash/context7-mcp'); // not clobbered
      expect(byName['dart']!.status, McpServerStatus.connected); // untouched
      expect(byName.length, 2); // no spurious entries

      await cubit.close();
    });

    test('empty merge leaves the list unchanged', () async {
      final cubit = _makeCubit(seed: [_srv('context7', McpServerStatus.connected)]);
      await cubit.ensureMcpServers();
      final before = [for (final s in cubit.state.mcpServers) '${s.name}:${s.status}'];

      cubit.mergeMcpServersFromSessionInit(const []);

      final after = [for (final s in cubit.state.mcpServers) '${s.name}:${s.status}'];
      expect(after, equals(before));
      await cubit.close();
    });
  });

  group('authenticateMcpServer re-entrancy guard', () {
    test('a second call while one is in flight is ignored (no duplicate flow)', () async {
      final auth = _MockAuthenticateMcpServer();
      final gate = Completer<Either<Failure, String?>>();
      when(
        () => auth.call(
          cwd: any(named: 'cwd'),
          serverName: any(named: 'serverName'),
        ),
      ).thenAnswer((_) => gate.future);
      final cubit = _makeCubit(auth: auth);

      // First call: enters in-flight and awaits the (gated) usecase.
      final first = cubit.authenticateMcpServer(_wid, 'claude.ai n8n');
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.mcpAuthInFlight, contains('claude.ai n8n'));

      // Second call while in flight: bails immediately.
      await cubit.authenticateMcpServer(_wid, 'claude.ai n8n');
      verify(
        () => auth.call(
          cwd: any(named: 'cwd'),
          serverName: any(named: 'serverName'),
        ),
      ).called(1);

      // Complete the first flow (null authUrl → no browser open); flag clears.
      gate.complete(const Right<Failure, String?>(null));
      await first;
      expect(cubit.state.mcpAuthInFlight, isNot(contains('claude.ai n8n')));

      await cubit.close();
    });
  });

  group('ensureMcpServers publishes to emitted state', () {
    test('loaded list becomes state.mcpServers (reactive source for the count)', () async {
      final cubit = _makeCubit(seed: [_srv('a', McpServerStatus.connected), _srv('b', McpServerStatus.needsAuth)]);
      expect(cubit.state.mcpServers, isEmpty);

      await cubit.ensureMcpServers();

      expect(cubit.state.mcpServers.map((s) => s.name), containsAll(['a', 'b']));
      await cubit.close();
    });
  });
}
