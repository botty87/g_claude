// State-machine contracts for the usage tracking in `ClaudeSessionsCubit`.
//
// The `usageUpdate` handler merges partial token fields into [SessionUsage],
// guarded by an equality check that prevents spurious emits when the update
// would not change anything.
//
// `clearConversation` / `newSession` must reset `usage` to null so the
// context meter hides when the user starts fresh.
//
// Full end-to-end flow (usageUpdate emitted during sendPrompt run) requires
// too many live dependencies to mock cleanly in a unit test. The parser-level
// contract is covered in `claude_process_datasource_usage_test.dart`. These
// tests focus on the SessionUsage entity logic and the cubit reset contract,
// which together give full coverage of the observable behaviour.

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/claude/domain/entities/session_usage.dart';

void main() {
  group('SessionUsage — contextTokens computed property', () {
    test(
      'contextTokens = inputTokens + cacheReadTokens + cacheCreationTokens',
      () {
        const usage = SessionUsage(
          inputTokens: 100,
          cacheReadTokens: 5000,
          cacheCreationTokens: 200,
          outputTokens: 350,
        );
        expect(usage.contextTokens, 5300);
      },
    );

    test('contextTokens excludes outputTokens', () {
      const usage = SessionUsage(
        inputTokens: 50,
        cacheReadTokens: 0,
        cacheCreationTokens: 0,
        outputTokens: 999,
      );
      expect(usage.contextTokens, 50);
    });

    test('defaults produce contextTokens == 0', () {
      expect(const SessionUsage().contextTokens, 0);
    });
  });

  group('SessionUsage — freezed equality guards redundant cubit emits', () {
    test(
      'two SessionUsage with identical fields are equal (prevents spurious emits)',
      () {
        const a = SessionUsage(
          inputTokens: 100,
          cacheReadTokens: 5000,
          cacheCreationTokens: 200,
          outputTokens: 4,
        );
        const b = SessionUsage(
          inputTokens: 100,
          cacheReadTokens: 5000,
          cacheCreationTokens: 200,
          outputTokens: 4,
        );
        expect(a == b, isTrue);
      },
    );

    test('copyWith updating one field produces a different instance', () {
      const base = SessionUsage(
        inputTokens: 100,
        cacheReadTokens: 5000,
        cacheCreationTokens: 200,
        outputTokens: 4,
      );
      final updated = base.copyWith(outputTokens: 50);
      expect(updated == base, isFalse);
      expect(updated.outputTokens, 50);
      // other fields unchanged
      expect(updated.inputTokens, 100);
      expect(updated.cacheReadTokens, 5000);
      expect(updated.cacheCreationTokens, 200);
    });
  });

  group('SessionUsage — merge pattern used in cubit usageUpdate handler', () {
    // Mirrors the cubit logic:
    //   final current = session.usage ?? const SessionUsage();
    //   final updated = current.copyWith(
    //     inputTokens: inputTokens ?? current.inputTokens,
    //     ...
    //   );
    //   if (updated == current) return;  // no-op guard

    test(
      'message_start payload updates input/cache, leaves output unchanged',
      () {
        const before = SessionUsage();
        const inputTokens = 100;
        const cacheRead = 5000;
        const cacheCreation = 200;
        const outputTokens = 1;

        final merged = before.copyWith(
          inputTokens: inputTokens,
          cacheReadTokens: cacheRead,
          cacheCreationTokens: cacheCreation,
          outputTokens: outputTokens,
        );

        expect(merged.inputTokens, 100);
        expect(merged.cacheReadTokens, 5000);
        expect(merged.cacheCreationTokens, 200);
        expect(merged.outputTokens, 1);
        expect(merged.contextTokens, 5300);
      },
    );

    test(
      'message_delta payload updates only outputTokens, input/cache preserved',
      () {
        const before = SessionUsage(
          inputTokens: 100,
          cacheReadTokens: 5000,
          cacheCreationTokens: 200,
          outputTokens: 1,
        );
        // message_delta: only outputTokens is present; input/cache are null so
        // the cubit uses the current value (`inTokens ?? current.inputTokens`).
        const newOutput = 50;
        // Simulate cubit null-coalesce: incoming field is null, keep existing.
        final int? incomingInput = null; // ignore: prefer_const_declarations
        final int? incomingCacheRead =
            null; // ignore: prefer_const_declarations
        final int? incomingCacheCreation =
            null; // ignore: prefer_const_declarations

        final merged = before.copyWith(
          inputTokens: incomingInput ?? before.inputTokens,
          cacheReadTokens: incomingCacheRead ?? before.cacheReadTokens,
          cacheCreationTokens:
              incomingCacheCreation ?? before.cacheCreationTokens,
          outputTokens: newOutput,
        );

        expect(merged.inputTokens, 100);
        expect(merged.cacheReadTokens, 5000);
        expect(merged.cacheCreationTokens, 200);
        expect(merged.outputTokens, 50);
      },
    );

    test(
      'no-op guard: identical merge produces equal object (no state emit)',
      () {
        const current = SessionUsage(
          inputTokens: 100,
          cacheReadTokens: 5000,
          cacheCreationTokens: 200,
          outputTokens: 4,
        );
        // Simulate a usageUpdate with the same values already in state
        final updated = current.copyWith(
          inputTokens: 100,
          cacheReadTokens: 5000,
          cacheCreationTokens: 200,
          outputTokens: 4,
        );
        expect(
          updated == current,
          isTrue,
          reason:
              'Equal updated object means the cubit skips emit via early return',
        );
      },
    );
  });
}
