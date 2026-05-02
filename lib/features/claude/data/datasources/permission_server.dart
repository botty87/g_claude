import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:talker_flutter/talker_flutter.dart';

enum PermissionDecision { allow, deny, ask }

class PermissionRequest {
  const PermissionRequest({
    required this.sessionId,
    required this.toolName,
    required this.toolInput,
  });

  final String sessionId;
  final String toolName;
  final Map<String, dynamic> toolInput;
}

typedef PermissionResolver = Future<PermissionDecision> Function(
  PermissionRequest request,
);

/// Local HTTP listener that Claude Code invokes from its `PreToolUse` hook
/// (configured via the `--settings` file). The resolver is set by the cubit
/// at startup; it consults the live UI state to decide allow/deny per tool.
///
/// Replicates the approach of clui-cc: `--permission-mode default` + an
/// in-process server lets us flip permission mode mid-run without respawning.
@lazySingleton
class PermissionServer {
  PermissionServer(this._talker);

  final Talker _talker;
  HttpServer? _server;
  int? _port;
  PermissionResolver? _resolver;

  int? get port => _port;

  void setResolver(PermissionResolver resolver) => _resolver = resolver;

  Future<int> start() async {
    if (_port != null) return _port!;
    _server = await io.serve(_handle, InternetAddress.loopbackIPv4, 0);
    _port = _server!.port;
    _talker.info('PermissionServer listening on http://127.0.0.1:$_port');
    return _port!;
  }

  @disposeMethod
  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    _port = null;
  }

  Future<shelf.Response> _handle(shelf.Request request) async {
    if (request.method != 'POST' || request.url.path != 'permission') {
      return shelf.Response.notFound('');
    }
    final body = await request.readAsString();
    Map<String, dynamic> payload;
    try {
      payload = jsonDecode(body) as Map<String, dynamic>;
    } catch (e) {
      _talker.warning('PermissionServer: malformed body ($e): $body');
      return _ok(PermissionDecision.allow);
    }

    final req = PermissionRequest(
      sessionId: payload['session_id'] as String? ?? '',
      toolName: payload['tool_name'] as String? ?? '',
      toolInput:
          (payload['tool_input'] as Map?)?.cast<String, dynamic>() ?? const {},
    );

    final resolver = _resolver;
    final decision = resolver != null
        ? await resolver(req)
        : PermissionDecision.allow;

    _talker.debug(
      'PermissionServer: ${req.toolName} '
      '(session=${_short(req.sessionId)}) -> ${decision.name}',
    );
    return _ok(decision);
  }

  shelf.Response _ok(PermissionDecision decision) {
    return shelf.Response.ok(
      jsonEncode({
        'hookSpecificOutput': {
          'hookEventName': 'PreToolUse',
          'permissionDecision': decision.name,
        },
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  String _short(String s) =>
      s.isEmpty ? '?' : s.substring(0, s.length.clamp(0, 8));
}
