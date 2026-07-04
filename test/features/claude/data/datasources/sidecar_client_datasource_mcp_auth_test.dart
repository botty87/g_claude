// [SidecarClientDataSource.authenticateMcpServer] round-trip. The MCP OAuth
// flow is request/response over the shared event stream, correlated by a
// throwaway `sid` (`mcpauth:<cwd>:<serverName>`):
//   1. `mcpAuthUrl` for the matching sid → resolves with the authUrl.
//   2. `mcpAuthError` for the matching sid → throws McpAuthException.
//   3. events for a different sid are ignored (no cross-talk).

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/claude/data/datasources/sidecar_client_datasource.dart';
import 'package:g_claude/features/claude/data/datasources/sidecar_transport.dart';

import '../../../../helpers/fakes.dart';

class _FakeTransport implements SidecarTransport {
  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  final List<Map<String, dynamic>> sent = [];

  void emit(Map<String, dynamic> e) => _controller.add(e);

  @override
  Future<void> start() async {}

  @override
  Stream<Map<String, dynamic>> get events => _controller.stream;

  @override
  void send(Map<String, dynamic> req) => sent.add(req);

  @override
  Future<void> dispose() async => _controller.close();
}

void main() {
  const cwd = '/proj';
  const server = 'claude.ai n8n';
  const sid = 'mcpauth:$cwd:$server';

  late _FakeTransport transport;
  late SidecarClientDataSource ds;

  setUp(() {
    transport = _FakeTransport();
    ds = SidecarClientDataSource(transport, makeTestTalker());
  });

  test('sends an mcpAuth request with cwd + serverName', () async {
    final future = ds.authenticateMcpServer(cwd: cwd, serverName: server);
    await Future<void>.delayed(Duration.zero);
    transport.emit({'t': 'mcpAuthUrl', 'sid': sid, 'serverName': server, 'authUrl': 'https://x'});
    await future;

    expect(transport.sent.single, {'t': 'mcpAuth', 'sid': sid, 'cwd': cwd, 'serverName': server});
  });

  test('mcpAuthUrl for the matching sid resolves with the authUrl', () async {
    final future = ds.authenticateMcpServer(cwd: cwd, serverName: server);
    await Future<void>.delayed(Duration.zero);
    transport.emit({'t': 'mcpAuthUrl', 'sid': sid, 'serverName': server, 'authUrl': 'https://claude.ai/auth'});

    expect(await future, 'https://claude.ai/auth');
  });

  test('mcpAuthError for the matching sid throws McpAuthException', () async {
    final future = ds.authenticateMcpServer(cwd: cwd, serverName: server);
    await Future<void>.delayed(Duration.zero);
    transport.emit({'t': 'mcpAuthError', 'sid': sid, 'serverName': server, 'message': 'server not found'});

    await expectLater(future, throwsA(isA<McpAuthException>().having((e) => e.message, 'message', 'server not found')));
  });

  test('an event for a different sid does not resolve the flow', () async {
    final future = ds.authenticateMcpServer(cwd: cwd, serverName: server);
    await Future<void>.delayed(Duration.zero);
    // Wrong sid → ignored.
    transport.emit({'t': 'mcpAuthUrl', 'sid': 'mcpauth:/other:foo', 'authUrl': 'https://nope'});
    // Correct sid → resolves.
    transport.emit({'t': 'mcpAuthUrl', 'sid': sid, 'authUrl': 'https://yes'});

    expect(await future, 'https://yes');
  });
}
