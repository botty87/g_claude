@Tags(['integration'])
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'package:g_claude/features/claude/data/datasources/claude_binary_resolver.dart';
import 'package:g_claude/features/claude/data/datasources/sidecar_client_datasource.dart';
import 'package:g_claude/features/claude/data/datasources/sidecar_transport.dart';
import 'package:g_claude/features/claude/domain/entities/claude_event.dart';
import 'package:g_claude/features/claude/domain/entities/claude_permission_mode.dart';

// Live end-to-end test of the Dart↔sidecar bridge. Spawns the real sidecar
// (npx tsx backend/src/sidecar.ts) driving the real `claude` CLI over the
// subscription OAuth. Opt-in: `flutter test --tags integration`.
void main() {
  late Talker talker;
  late StdioSidecarTransport transport;
  late SidecarClientDataSource ds;
  late Directory sandbox;

  setUp(() {
    talker = Talker();
    transport = StdioSidecarTransport(talker, ClaudeBinaryResolver(talker));
    ds = SidecarClientDataSource(transport, talker);
    sandbox = Directory.systemTemp.createTempSync('clyde-bridge-');
  });
  tearDown(() async {
    await transport.dispose();
    if (sandbox.existsSync()) sandbox.deleteSync(recursive: true);
  });

  // Full lifecycle through Dart: start → assistant text → taskComplete →
  // sidecar closes → sessionDead → stream completes.
  test('lifecycle: simple turn completes and stream ends', () async {
    final seen = <String>[];
    final done = Completer<void>();
    final sub = ds
        .startRun(
          cwd: sandbox.path,
          prompt: 'Reply with exactly the word DONE. Do not use any tools.',
          mode: ClaudePermissionMode.defaultMode,
        )
        .listen((e) {
          seen.add(e.runtimeType.toString());
          if (e is ClaudeEventSessionDead && !done.isCompleted) done.complete();
        });
    await done.future.timeout(const Duration(seconds: 90));
    await sub.cancel();

    expect(seen, contains('ClaudeEventSessionInit'));
    expect(seen, contains('ClaudeEventTaskComplete'));
    expect(seen, contains('ClaudeEventSessionDead'));
  }, timeout: const Timeout(Duration(minutes: 3)));

  // Plan round-trip through Dart: planProposed → approve → file written in cwd.
  test('plan round-trip: approve → file written in cwd', () async {
    var sawPlan = false;
    final done = Completer<void>();
    final sub = ds
        .startRun(
          cwd: sandbox.path,
          prompt:
              'Without reading or exploring any files, IMMEDIATELY call ExitPlanMode '
              'with a one-line plan to create calc.js (exporting add(a,b)) in the current '
              'working directory. After I approve, create calc.js with a relative path.',
          mode: ClaudePermissionMode.plan,
        )
        .listen((e) {
          switch (e) {
            case ClaudeEventPlanProposed(:final toolUseId):
              sawPlan = true;
              ds.answerPlan(
                sid: sandbox.path,
                toolUseID: toolUseId,
                approve: true,
                mode: ClaudePermissionMode.acceptEdits,
              );
            case ClaudeEventPermissionRequest(:final requestId):
              ds.respondPermission(sid: sandbox.path, toolUseID: requestId, allow: true);
            case ClaudeEventSessionDead():
              if (!done.isCompleted) done.complete();
            default:
              break;
          }
        });
    await done.future.timeout(const Duration(seconds: 150));
    await sub.cancel();

    expect(sawPlan, isTrue, reason: 'ExitPlanMode should reach the client as planProposed');
    expect(
      File('${sandbox.path}/calc.js').existsSync(),
      isTrue,
      reason: 'approved plan should let Claude write calc.js in cwd',
    );
  }, timeout: const Timeout(Duration(minutes: 4)));
}
