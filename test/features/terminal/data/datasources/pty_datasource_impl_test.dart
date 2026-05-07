// Contracts for [PtyDataSourceImpl] that are verifiable without spawning
// a real PTY process.
//
// Tested here:
//   - terminalFor / controllerFor on unknown id return null.
//   - dispose on an unknown id completes without throw (idempotent).
//   - disposeAll() on an empty map closes the events stream cleanly.
//   - disposeAll() called a second time does not throw (isClosed guard).
//   - detectShell() returns a non-empty string.
//
// NOT tested here:
//   - getOrCreate / PTY spawn / output piping: requires a real shell binary
//     and Pty.start(); any stub would test the mock, not the code.
//   - _emitEvent after disposeAll via natural PTY exit: the pty.exitCode
//     future fires on a native callback after the process dies; not
//     triggerable without a real spawn.
//   - Platform.environment conditional in detectShell: static method reads
//     the real process environment, which varies per machine. Contract
//     (non-empty result) is verified; the $SHELL-vs-fallback branch is
//     platform-dependent and therefore skipped.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/terminal/data/datasources/pty_datasource_impl.dart';
import '../../../../helpers/fakes.dart';

void main() {
  late PtyDataSourceImpl ds;

  setUp(() {
    ds = PtyDataSourceImpl(makeTestTalker());
  });

  // -------------------------------------------------------------------------
  // terminalFor / controllerFor
  // -------------------------------------------------------------------------

  group('terminalFor / controllerFor — return null for unknown workspaceId', () {
    test('terminalFor returns null when no session exists for the id', () {
      expect(ds.terminalFor('does-not-exist'), isNull);
    });

    test('controllerFor returns null when no session exists for the id', () {
      expect(ds.controllerFor('does-not-exist'), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // dispose idempotency
  // -------------------------------------------------------------------------

  group('dispose — completes without throw for unknown id', () {
    test('dispose on unknown id is a no-op (does not throw)', () async {
      await expectLater(ds.dispose('never-created'), completes);
    });
  });

  // -------------------------------------------------------------------------
  // disposeAll on empty map
  // -------------------------------------------------------------------------

  group('disposeAll — closes events stream cleanly even with no sessions', () {
    test('disposeAll on empty session map completes without throw', () async {
      await expectLater(ds.disposeAll(), completes);
    });

    test('events stream is done after disposeAll()', () async {
      // Attach a listener before calling disposeAll so the done callback fires.
      final doneCompleter = Completer<void>();
      ds.events.listen((_) {}, onDone: doneCompleter.complete);

      await ds.disposeAll();
      await expectLater(doneCompleter.future, completes);
    });

    test('disposeAll() called twice does not throw (isClosed guard)', () async {
      await ds.disposeAll();
      // Second call must be safe.
      await expectLater(ds.disposeAll(), completes);
    });
  });

  // -------------------------------------------------------------------------
  // detectShell
  // -------------------------------------------------------------------------

  group('detectShell — returns a usable shell path', () {
    test('detectShell() returns a non-empty string', () {
      expect(ds.detectShell(), isNotEmpty);
    });

    // not testable: the $SHELL-vs-/bin/zsh branch depends on
    // Platform.environment, which reflects the real process environment.
    // Asserting a specific value would make the test machine-dependent.
  });

  // -------------------------------------------------------------------------
  // events stream
  // -------------------------------------------------------------------------

  group('events stream — is a broadcast stream', () {
    test('events is a broadcast stream (multiple listeners allowed)', () {
      expect(ds.events.isBroadcast, isTrue);
    });
  });
}

// Expose the impl for testing — the interface does not surface the constructor.
// We instantiate PtyDataSourceImpl directly because the contracts under test
// do not require the full DI container.
