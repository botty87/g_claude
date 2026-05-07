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
    required this.requestId,
    required this.sessionId,
    required this.toolName,
    required this.toolInput,
  });

  final String requestId;
  final String sessionId;
  final String toolName;
  final Map<String, dynamic> toolInput;
}

/// Resolver result. Either auto-decide (allow/deny) immediately or hand off
/// to interactive UI (`ask`); when `ask` is returned the server suspends the
/// HTTP response until [PermissionServer.respond] completes the request.
typedef PermissionResolver = Future<PermissionDecision> Function(PermissionRequest request);

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
  void Function(PermissionRequest req)? _interactiveHandler;

  final Map<String, Completer<PermissionDecision>> _pending = {};
  int _seq = 0;

  static const _interactiveTimeout = Duration(minutes: 5);

  int? get port => _port;

  void setResolver(PermissionResolver resolver) => _resolver = resolver;

  /// Registers a callback invoked when the resolver returns `ask` — the
  /// caller is responsible for showing UI and eventually calling [respond].
  void setInteractiveHandler(void Function(PermissionRequest) handler) => _interactiveHandler = handler;

  Future<int> start() async {
    if (_port != null) return _port!;
    _server = await io.serve(_handle, InternetAddress.loopbackIPv4, 0);
    _port = _server!.port;
    _talker.info('PermissionServer listening on http://127.0.0.1:$_port');
    return _port!;
  }

  @disposeMethod
  Future<void> stop() async {
    for (final c in _pending.values) {
      if (!c.isCompleted) c.complete(PermissionDecision.deny);
    }
    _pending.clear();
    await _server?.close(force: true);
    _server = null;
    _port = null;
  }

  /// Resolves a previously-suspended interactive request.
  void respond(String requestId, PermissionDecision decision) {
    final completer = _pending.remove(requestId);
    if (completer == null) {
      _talker.warning('PermissionServer.respond: unknown requestId=$requestId');
      return;
    }
    if (!completer.isCompleted) completer.complete(decision);
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

    final requestId = 'p-${DateTime.now().microsecondsSinceEpoch}-${_seq++}';
    final req = PermissionRequest(
      requestId: requestId,
      sessionId: payload['session_id'] as String? ?? '',
      toolName: payload['tool_name'] as String? ?? '',
      toolInput: (payload['tool_input'] as Map?)?.cast<String, dynamic>() ?? const {},
    );

    final resolver = _resolver;
    var decision = resolver != null ? await resolver(req) : PermissionDecision.allow;

    if (decision == PermissionDecision.ask) {
      final completer = Completer<PermissionDecision>();
      _pending[requestId] = completer;
      final handler = _interactiveHandler;
      if (handler == null) {
        _talker.warning('PermissionServer: ask returned but no interactive handler — denying');
        _pending.remove(requestId);
        decision = PermissionDecision.deny;
      } else {
        handler(req);
        try {
          decision = await completer.future.timeout(_interactiveTimeout);
        } on TimeoutException {
          _talker.warning('PermissionServer: interactive request $requestId timed out — denying');
          _pending.remove(requestId);
          decision = PermissionDecision.deny;
        }
      }
    }

    _talker.debug(
      'PermissionServer: ${req.toolName} '
      '(session=${_short(req.sessionId)}) -> ${decision.name}',
    );
    return _ok(decision);
  }

  /// Builds the PreToolUse hook response. INVARIANT: never include
  /// `updatedInput` here. Returning `updatedInput` with extra keys (even
  /// unrelated ones) silently corrupts the input schema of UI tools like
  /// `AskUserQuestion`, `EnterPlanMode`, `ExitPlanMode`, `TaskCreate`, etc.,
  /// which then auto-resolve with empty answers (see anthropics/claude-code
  /// #29530, root cause analysis by terrylica). Keep this response minimal:
  /// only `permissionDecision`.
  shelf.Response _ok(PermissionDecision decision) {
    return shelf.Response.ok(
      jsonEncode({
        'hookSpecificOutput': {'hookEventName': 'PreToolUse', 'permissionDecision': decision.name},
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  String _short(String s) => s.isEmpty ? '?' : s.substring(0, s.length.clamp(0, 8));
}
