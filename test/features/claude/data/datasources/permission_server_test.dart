// Contracts for `PermissionServer` (lib/features/claude/data/datasources/
// permission_server.dart).
//
// The server is the synchronization point between the Claude subprocess
// PreToolUse hook (a curl invocation that BLOCKS until response) and the
// Flutter UI permission system. A regression here either crashes Claude on
// a tool call ("malformed permission response") or hangs the run.
//
// Tests bind a real Shelf server on a loopback ephemeral port and POST real
// HTTP requests, mirroring the production wire protocol exactly. The
// alternative — calling _handle directly — would have to fake shelf.Request,
// which is more brittle than driving the actual server.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/claude/data/datasources/permission_server.dart';

import '../../../../helpers/fakes.dart';

Future<({PermissionServer server, Uri base})> _start() async {
  final server = PermissionServer(makeTestTalker());
  final port = await server.start();
  return (server: server, base: Uri.parse('http://127.0.0.1:$port'));
}

Future<HttpClientResponse> _post(Uri base, String path, String body) async {
  final client = HttpClient();
  try {
    final req = await client.postUrl(base.replace(path: path));
    req.headers.contentType = ContentType('application', 'json');
    req.write(body);
    return await req.close();
  } finally {
    client.close();
  }
}

Future<({int statusCode, Map<String, dynamic> json})> _postJson(
  Uri base,
  String path,
  Map<String, dynamic> payload,
) async {
  final res = await _post(base, path, jsonEncode(payload));
  final body = await res.transform(utf8.decoder).join();
  final decoded = body.isEmpty ? <String, dynamic>{} : jsonDecode(body);
  return (statusCode: res.statusCode, json: decoded is Map<String, dynamic> ? decoded : <String, dynamic>{});
}

String? _decisionFromBody(Map<String, dynamic> json) {
  final out = json['hookSpecificOutput'] as Map<String, dynamic>?;
  return out?['permissionDecision'] as String?;
}

void main() {
  group('PermissionServer — routing', () {
    test('GET / returns 404 (only POST /permission is served)', () async {
      final s = await _start();
      addTearDown(s.server.stop);

      final client = HttpClient();
      addTearDown(client.close);
      final res = await (await client.getUrl(s.base.replace(path: '/'))).close();
      expect(res.statusCode, 404);
    });

    test('POST to a path other than /permission returns 404', () async {
      final s = await _start();
      addTearDown(s.server.stop);

      final res = await _post(s.base, '/something_else', '{}');
      expect(res.statusCode, 404);
      // Drain.
      await res.transform(utf8.decoder).join();
    });

    test('GET /permission returns 404 (POST only)', () async {
      final s = await _start();
      addTearDown(s.server.stop);

      final client = HttpClient();
      addTearDown(client.close);
      final res = await (await client.getUrl(s.base.replace(path: '/permission'))).close();
      expect(res.statusCode, 404);
    });
  });

  group('PermissionServer — decision when no resolver registered', () {
    test('defaults to "allow" so the hook never blocks the subprocess', () async {
      final s = await _start();
      addTearDown(s.server.stop);

      final res = await _postJson(s.base, '/permission', {
        'session_id': 'abc',
        'tool_name': 'Read',
        'tool_input': {'file_path': '/tmp/x'},
      });
      expect(res.statusCode, 200);
      expect(_decisionFromBody(res.json), 'allow');
    });
  });

  group('PermissionServer — resolver-driven decisions', () {
    test('resolver returning allow propagates as allow in the response', () async {
      final s = await _start();
      addTearDown(s.server.stop);

      s.server.setResolver((_) async => PermissionDecision.allow);

      final res = await _postJson(s.base, '/permission', {'session_id': 'a', 'tool_name': 'Read', 'tool_input': {}});
      expect(_decisionFromBody(res.json), 'allow');
    });

    test('resolver returning deny propagates as deny in the response', () async {
      final s = await _start();
      addTearDown(s.server.stop);

      s.server.setResolver((_) async => PermissionDecision.deny);

      final res = await _postJson(s.base, '/permission', {
        'session_id': 'a',
        'tool_name': 'Bash',
        'tool_input': {'command': 'rm -rf /'},
      });
      expect(_decisionFromBody(res.json), 'deny');
    });

    test('resolver receives populated PermissionRequest with sessionId / toolName / toolInput', () async {
      final s = await _start();
      addTearDown(s.server.stop);

      PermissionRequest? captured;
      s.server.setResolver((req) async {
        captured = req;
        return PermissionDecision.allow;
      });

      await _postJson(s.base, '/permission', {
        'session_id': 'sess-xyz',
        'tool_name': 'Edit',
        'tool_input': {'file_path': '/tmp/foo'},
      });

      expect(captured, isNotNull);
      expect(captured!.sessionId, 'sess-xyz');
      expect(captured!.toolName, 'Edit');
      expect(captured!.toolInput['file_path'], '/tmp/foo');
      // Server-generated requestId is non-empty so consumers can correlate.
      expect(captured!.requestId, isNotEmpty);
    });
  });

  group('PermissionServer — interactive (resolver returns "ask")', () {
    test('without interactive handler registered, ask is downgraded to deny (safety fallback)', () async {
      final s = await _start();
      addTearDown(s.server.stop);

      s.server.setResolver((_) async => PermissionDecision.ask);
      // Note: deliberately NOT calling setInteractiveHandler.

      final res = await _postJson(s.base, '/permission', {'session_id': 'a', 'tool_name': 'Read', 'tool_input': {}});
      expect(_decisionFromBody(res.json), 'deny');
    });

    test('with handler, the request suspends until respond() resolves it', () async {
      final s = await _start();
      addTearDown(s.server.stop);

      s.server.setResolver((_) async => PermissionDecision.ask);

      final handlerCalled = Completer<PermissionRequest>();
      s.server.setInteractiveHandler(handlerCalled.complete);

      // Fire the HTTP request asynchronously so we can drive the resolver.
      final pending = _postJson(s.base, '/permission', {'session_id': 'a', 'tool_name': 'Read', 'tool_input': {}});

      // The server must have invoked the handler before we resolve.
      final req = await handlerCalled.future;
      // The HTTP request is still pending — assert this by racing it against
      // a short delay.
      final raced = await Future.any<Object?>([
        pending,
        Future.delayed(const Duration(milliseconds: 100), () => 'timeout'),
      ]);
      expect(raced, 'timeout', reason: 'response must not arrive before respond() is called.');

      // Now release the request.
      s.server.respond(req.requestId, PermissionDecision.allow);
      final res = await pending;
      expect(_decisionFromBody(res.json), 'allow');
    });

    test('respond() with an unknown requestId is a no-op (no exception)', () async {
      final s = await _start();
      addTearDown(s.server.stop);

      // No pending request, but respond should not throw.
      expect(() => s.server.respond('p-does-not-exist', PermissionDecision.allow), returnsNormally);
    });
  });

  group('PermissionServer — malformed body safety net', () {
    test('non-JSON body resolves to "allow" (current contract; bug-flagged in lessons.md)', () async {
      // CONTRACT (current): the server logs the parse error and returns
      // `allow` so a hook misconfiguration does not block the subprocess.
      // This is permissive — see tasks/lessons.md for discussion.
      final s = await _start();
      addTearDown(s.server.stop);

      final res = await _post(s.base, '/permission', 'not-json');
      final body = await res.transform(utf8.decoder).join();
      expect(res.statusCode, 200);
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      expect(_decisionFromBody(decoded), 'allow');
    });

    test('empty payload (no session_id / tool_name / tool_input) still produces a valid response', () async {
      final s = await _start();
      addTearDown(s.server.stop);

      PermissionRequest? captured;
      s.server.setResolver((req) async {
        captured = req;
        return PermissionDecision.allow;
      });

      final res = await _postJson(s.base, '/permission', {});
      expect(res.statusCode, 200);
      expect(captured, isNotNull);
      // Defaults: sessionId empty, toolName empty, toolInput empty map.
      expect(captured!.sessionId, '');
      expect(captured!.toolName, '');
      expect(captured!.toolInput, isEmpty);
    });
  });

  group('PermissionServer — response shape invariants', () {
    test('response body contains hookSpecificOutput.{hookEventName, permissionDecision} ONLY', () async {
      // The response must never include `updatedInput`: extra keys silently
      // corrupt schemas of UI tools like AskUserQuestion / EnterPlanMode.
      final s = await _start();
      addTearDown(s.server.stop);

      s.server.setResolver((_) async => PermissionDecision.allow);

      final res = await _postJson(s.base, '/permission', {});
      expect(res.json.keys, ['hookSpecificOutput']);
      final inner = res.json['hookSpecificOutput'] as Map<String, dynamic>;
      expect(inner.keys.toSet(), {'hookEventName', 'permissionDecision'});
      expect(inner['hookEventName'], 'PreToolUse');
      expect(
        inner.containsKey('updatedInput'),
        isFalse,
        reason: 'updatedInput corrupts UI-tool schemas; must never appear.',
      );
    });

    test('Content-Type response header is application/json', () async {
      final s = await _start();
      addTearDown(s.server.stop);

      final res = await _post(s.base, '/permission', '{}');
      expect(res.headers.contentType?.mimeType, 'application/json');
      await res.transform(utf8.decoder).join();
    });
  });

  group('PermissionServer — start / stop lifecycle', () {
    test('start() is idempotent: a second call returns the same port', () async {
      final s = await _start();
      addTearDown(s.server.stop);

      final port2 = await s.server.start();
      expect(port2, s.base.port);
    });

    test('stop() drops pending HTTP connections instead of leaving them suspended', () async {
      // Discovered while writing this test:
      //   stop() does TWO things — (a) complete all pending interactive
      //   completers with deny, (b) close the HTTP server with `force: true`.
      //   The forced close drops the TCP connection before shelf can write
      //   the deny body, so the curl-side caller observes "connection closed"
      //   rather than a valid `deny` response.
      // In production this is acceptable (the app is exiting), but it IS
      // the current contract — any future cleanup must keep the test honest.
      final s = await _start();

      s.server.setResolver((_) async => PermissionDecision.ask);
      s.server.setInteractiveHandler((_) {
        /* never respond */
      });

      final pending = _postJson(s.base, '/permission', {});
      // Let the handler register the completer.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await s.server.stop();

      // The pending HTTP request must fail with a connection error — NOT
      // hang and NOT return a body.
      await expectLater(pending, throwsA(isA<HttpException>()));
    });
  });
}
