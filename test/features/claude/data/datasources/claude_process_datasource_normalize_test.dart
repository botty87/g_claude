// Contracts for the NDJSON normalizer in `claude_process_datasource.dart`.
//
// The parser is the most fragile surface in the app: a regression here
// silently corrupts every Claude session. Tests in this file consume REAL
// fixtures captured from `claude -p --output-format stream-json --verbose
// --include-partial-messages --no-session-persistence` so the assertions
// reflect the production contract — not our imagination of the format.
//
// One synthetic fixture (`with_rate_limit.ndjson`) lives under `synthetic/`
// because rate-limit events are not deterministically reproducible. Its
// shape mirrors the parser's case at lib/features/claude/data/datasources/
// claude_process_datasource.dart:526–531; if the contract changes, the
// fixture must be updated alongside the code.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/claude/data/datasources/claude_binary_resolver.dart';
import 'package:g_claude/features/claude/data/datasources/claude_process_datasource.dart';
import 'package:g_claude/features/claude/data/datasources/claude_settings_writer.dart';
import 'package:g_claude/features/claude/data/datasources/permission_server.dart';
import 'package:g_claude/features/claude/domain/entities/claude_event.dart';

import '../../../../helpers/fakes.dart';

/// Reads an NDJSON fixture, returning the list of decoded JSON objects per
/// line (skipping empty/whitespace lines, like the production stdout reader).
List<Map<String, dynamic>> _readFixture(String relativePath) {
  final raw = File('test/fixtures/ndjson/$relativePath').readAsStringSync();
  final out = <Map<String, dynamic>>[];
  for (final line in const LineSplitter().convert(raw)) {
    if (line.trim().isEmpty) continue;
    final decoded = jsonDecode(line);
    if (decoded is Map<String, dynamic>) out.add(decoded);
  }
  return out;
}

/// Runs every fixture line through the parser and collects the emitted events.
List<ClaudeEvent> _runFixture(ClaudeProcessDataSourceImpl parser, String relativePath) {
  parser.resetParserStateForTest();
  final events = <ClaudeEvent>[];
  for (final raw in _readFixture(relativePath)) {
    if (raw['type'] == 'control_response') continue; // matches production filter
    events.addAll(parser.normalizeForTest(raw));
  }
  return events;
}

ClaudeProcessDataSourceImpl _makeParser() {
  final talker = makeTestTalker();
  return ClaudeProcessDataSourceImpl(
    talker,
    PermissionServer(talker),
    ClaudeSettingsWriter(talker),
    ClaudeBinaryResolver(talker),
  );
}

void main() {
  late ClaudeProcessDataSourceImpl parser;

  setUp(() {
    parser = _makeParser();
  });

  group('normalizeForTest — simple_text fixture (real run)', () {
    late List<ClaudeEvent> events;

    setUp(() {
      events = _runFixture(parser, 'simple_text.ndjson');
    });

    test('emits at least one sessionInit at the start of the run', () {
      // The first emitted event is the sessionInit produced from the
      // system/init envelope. Hooks (system/hook_started, hook_response)
      // produce zero events — they are absorbed silently.
      final firstInit = events.firstWhere(
        (e) => e is ClaudeEventSessionInit,
        orElse: () => throw StateError('no sessionInit emitted'),
      );
      expect(firstInit, isA<ClaudeEventSessionInit>());
    });

    test('sessionInit carries non-empty sessionId and model from the JSON', () {
      final init = events.whereType<ClaudeEventSessionInit>().first;
      expect(init.sessionId, isNotEmpty);
      expect(init.model, isNotEmpty);
    });

    test('hook events (system/hook_started, system/hook_response) emit no ClaudeEvent', () {
      // Indirect contract: among the raw fixture lines we have hook envelopes;
      // they must not contribute to the event list. We assert by counting:
      // the only `system` lines that produce events are the `init` ones.
      final initLines = _readFixture('simple_text.ndjson').where(
        (raw) => raw['type'] == 'system' && raw['subtype'] == 'init',
      );
      final initEvents = events.whereType<ClaudeEventSessionInit>();
      expect(initEvents.length, initLines.length);
    });

    test('emits at least one textChunk for the assistant streaming text', () {
      final chunks = events.whereType<ClaudeEventTextChunk>();
      expect(chunks, isNotEmpty,
          reason: 'A non-empty assistant reply must produce textChunks.');
      // Every emitted textChunk has non-empty text — the parser short-circuits
      // empty deltas (line 415).
      for (final c in chunks) {
        expect(c.text, isNotEmpty);
      }
    });

    test('terminates with a single taskComplete (no errorEvent on success)', () {
      final completes = events.whereType<ClaudeEventTaskComplete>();
      final errors = events.whereType<ClaudeEventErrorEvent>();
      expect(completes.length, 1, reason: 'Exactly one terminal taskComplete.');
      expect(errors, isEmpty);
      expect(events.last, isA<ClaudeEventTaskComplete>());
    });
  });

  group('normalizeForTest — with_tool_call fixture (real run)', () {
    late List<ClaudeEvent> events;

    setUp(() {
      events = _runFixture(parser, 'with_tool_call.ndjson');
    });

    test('emits a toolCall before its toolCallComplete with matching index', () {
      final calls = events.whereType<ClaudeEventToolCall>().toList();
      final completes = events.whereType<ClaudeEventToolCallComplete>().toList();
      expect(calls, isNotEmpty);
      expect(completes, isNotEmpty);

      // Each toolCall must precede its matching toolCallComplete in the stream.
      for (final call in calls) {
        final callIdx = events.indexOf(call);
        final matchComplete = completes.firstWhere(
          (c) => c.index == call.index,
          orElse: () => throw StateError('no toolCallComplete for index ${call.index}'),
        );
        final completeIdx = events.indexOf(matchComplete);
        expect(completeIdx, greaterThan(callIdx),
            reason: 'toolCallComplete[index=${call.index}] must come AFTER its toolCall.');
      }
    });

    test('toolCallComplete carries the same toolId as the originating toolCall', () {
      final calls = events.whereType<ClaudeEventToolCall>().toList();
      final completes = events.whereType<ClaudeEventToolCallComplete>().toList();
      for (final call in calls) {
        final match = completes.firstWhere((c) => c.index == call.index);
        expect(match.toolId, call.toolId,
            reason: 'parser must thread toolId through _toolByIndex.');
      }
    });

    test('toolCallComplete.input is a populated Map for tool calls that received input_json_delta', () {
      // Only assert on completes that had partial JSON streamed in. The
      // parser sets input=null when partialJson is empty or jsonDecode fails.
      final completes = events.whereType<ClaudeEventToolCallComplete>().toList();
      final withInput = completes.where((c) => c.input != null);
      expect(withInput, isNotEmpty,
          reason: 'A real Read tool call streams its arguments via input_json_delta.');
    });

    test('emits a toolResult correlated by toolUseId to the toolCall', () {
      final calls = events.whereType<ClaudeEventToolCall>().toList();
      final results = events.whereType<ClaudeEventToolResult>().toList();
      expect(results, isNotEmpty);

      for (final result in results) {
        final hasMatchingCall = calls.any((c) => c.toolId == result.toolUseId);
        expect(hasMatchingCall, isTrue,
            reason: 'Every toolResult.toolUseId should match some emitted toolCall.toolId.');
      }
    });

    test('emits assistantMessage events for completed assistant turns', () {
      // The CLI emits both partial `stream_event.text_delta` (→ textChunk)
      // AND a final `assistant.message` (→ assistantMessage) per turn. The
      // assistantMessage is the closing snapshot.
      expect(events.whereType<ClaudeEventAssistantMessage>(), isNotEmpty);
    });
  });

  group('normalizeForTest — with_error fixture (real run, --bare auth_failed)', () {
    late List<ClaudeEvent> events;

    setUp(() {
      events = _runFixture(parser, 'with_error.ndjson');
    });

    test('terminates with errorEvent (NOT taskComplete) when result.is_error is true', () {
      // Captured against `claude -p --bare`: auth fails, the run still
      // produces a `result` envelope, but `is_error == true` ⇒ the parser
      // routes to errorEvent (line 514) instead of taskComplete.
      expect(events.last, isA<ClaudeEventErrorEvent>());
      expect(events.whereType<ClaudeEventTaskComplete>(), isEmpty);
    });

    test('errorEvent carries the message from result.result (or result.error fallback)', () {
      final err = events.whereType<ClaudeEventErrorEvent>().single;
      expect(err.message, isNotEmpty);
    });
  });

  group('normalizeForTest — multiline_partial fixture (real run, large Write tool)', () {
    late List<ClaudeEvent> events;
    late int toolCallUpdateCount;

    setUp(() {
      events = _runFixture(parser, 'multiline_partial.ndjson');
      toolCallUpdateCount = events.whereType<ClaudeEventToolCallUpdate>().length;
    });

    test('emits many toolCallUpdate events, one per input_json_delta line', () {
      // Captured fixture has hundreds of input_json_delta envelopes.
      expect(toolCallUpdateCount, greaterThan(50),
          reason: 'Streaming a large tool argument must surface as many toolCallUpdate events.');
    });

    test('every toolCallUpdate is bracketed by a preceding toolCall and a matching toolCallComplete', () {
      // Discovered while writing this test: the parser emits a
      // toolCallComplete on EVERY content_block_stop, even if the closing
      // block is `text` rather than `tool_use`. The "phantom" complete has
      // toolId=null, input=null. The cubit filters it downstream by checking
      // toolId.isNotEmpty (cubit line 777). So calls.length and
      // completes.length DO NOT match — there are typically more completes
      // than calls. Contract under test is narrower: every update must fall
      // between its matching toolCall (same toolId) and the toolCallComplete
      // for that toolCall's index.
      final updates = events.whereType<ClaudeEventToolCallUpdate>().toList();
      expect(updates, isNotEmpty);

      final calls = events.whereType<ClaudeEventToolCall>().toList();
      final completes = events.whereType<ClaudeEventToolCallComplete>().toList();

      for (final call in calls) {
        final callIdx = events.indexOf(call);
        // Real toolCallComplete (toolId == call.toolId), not a phantom one.
        final realComplete = completes.firstWhere(
          (c) => c.toolId == call.toolId,
          orElse: () => throw StateError('no real toolCallComplete for ${call.toolId}'),
        );
        final completeIdx = events.indexOf(realComplete);

        for (final update in updates) {
          if (update.toolId == call.toolId) {
            final upIdx = events.indexOf(update);
            expect(upIdx, greaterThan(callIdx),
                reason: 'update for ${call.toolId} must come AFTER its toolCall');
            expect(upIdx, lessThan(completeIdx),
                reason: 'update for ${call.toolId} must come BEFORE its toolCallComplete');
          }
        }
      }
    });

    test('phantom toolCallComplete on text block close has toolId=null and input=null', () {
      // Documents the parser behavior surfaced by the test above. Only assert
      // the phantom shape is what we expect (so a future fix that suppresses
      // it would update this test too — coordinated change).
      final completes = events.whereType<ClaudeEventToolCallComplete>().toList();
      final phantoms = completes.where((c) => c.toolId == null);
      for (final p in phantoms) {
        expect(p.input, isNull);
      }
      // We expect at least one phantom in this fixture (the text block stop
      // that follows the Write tool_use closing).
      expect(phantoms, isNotEmpty,
          reason: 'multiline_partial fixture has a content_block_stop on a text block.');
    });

    test('toolCallComplete.input contains the FULL accumulated JSON, not a partial', () {
      // The accumulated partialJson must parse to a Map and contain the
      // expected keys for a Write tool call.
      final completes = events.whereType<ClaudeEventToolCallComplete>().toList();
      expect(completes, isNotEmpty);
      final hasFullInput = completes.any(
        (c) => c.input != null && c.input!.containsKey('file_path'),
      );
      expect(hasFullInput, isTrue,
          reason: 'A real Write tool call must end with a fully-decoded input map.');
    });
  });

  group('normalizeForTest — synthetic with_rate_limit fixture', () {
    test('emits a rateLimit event for each rate_limit_event envelope', () {
      // SYNTHETIC FIXTURE: shape mirrors lib/features/claude/data/datasources/
      // claude_process_datasource.dart:526–531. Fixture has 2 events.
      final events = _runFixture(parser, 'synthetic/with_rate_limit.ndjson');
      final rateLimits = events.whereType<ClaudeEventRateLimit>().toList();
      expect(rateLimits, hasLength(2));
      expect(rateLimits[0].status, 'approaching_limit');
      expect(rateLimits[0].resetsAt, 1735689600);
      expect(rateLimits[1].status, 'limited');
    });
  });

  group('normalizeForTest — robustness on malformed / unknown input', () {
    test('an unknown top-level type emits zero events and does not throw', () {
      expect(parser.normalizeForTest({'type': 'completely_made_up'}), isEmpty);
    });

    test('a stream_event with unknown inner type emits zero events', () {
      expect(
        parser.normalizeForTest({
          'type': 'stream_event',
          'event': {'type': 'whatever_new_thing'},
        }),
        isEmpty,
      );
    });

    test('a stream_event whose `event` field is not a Map is silently ignored', () {
      expect(
        parser.normalizeForTest({'type': 'stream_event', 'event': 'not-a-map'}),
        isEmpty,
      );
    });

    test('a system envelope without subtype=init emits zero events', () {
      expect(
        parser.normalizeForTest({'type': 'system', 'subtype': 'hook_response'}),
        isEmpty,
      );
    });

    test('sessionInit with missing fields fills in safe defaults', () {
      final out = parser.normalizeForTest({
        'type': 'system',
        'subtype': 'init',
        // Intentionally omit session_id, model, tools, skills, plugins.
      }).toList();
      expect(out, hasLength(1));
      final init = out.single as ClaudeEventSessionInit;
      expect(init.sessionId, '');
      expect(init.model, '');
      expect(init.tools, isEmpty);
      expect(init.skills, isEmpty);
      expect(init.slashCommands, isEmpty);
      expect(init.plugins, isEmpty);
    });

    test('a text_delta with empty text emits NO textChunk (parser short-circuits empty)', () {
      expect(
        parser.normalizeForTest({
          'type': 'stream_event',
          'event': {
            'type': 'content_block_delta',
            'delta': {'type': 'text_delta', 'text': ''},
          },
        }),
        isEmpty,
      );
    });

    test('a content_block_stop for an unseen index emits a toolCallComplete with toolId=null and input=null', () {
      // The parser has no record of this index in _toolByIndex (we never saw
      // a content_block_start for it). It still emits a complete event so
      // downstream consumers can decide what to do — toolId is null.
      final out = parser.normalizeForTest({
        'type': 'stream_event',
        'event': {'type': 'content_block_stop', 'index': 99},
      }).toList();
      expect(out, hasLength(1));
      final complete = out.single as ClaudeEventToolCallComplete;
      expect(complete.index, 99);
      expect(complete.toolId, isNull);
      expect(complete.input, isNull);
    });

    test('a tool_result with content=null produces an empty-string flattened content', () {
      final out = parser.normalizeForTest({
        'type': 'user',
        'message': {
          'content': [
            {'type': 'tool_result', 'tool_use_id': 'tool_xyz', 'content': null},
          ],
        },
      }).toList();
      final result = out.single as ClaudeEventToolResult;
      expect(result.toolUseId, 'tool_xyz');
      expect(result.content, '');
      expect(result.isError, isFalse);
    });

    test('a tool_result with is_error=true sets isError on the emitted event', () {
      final out = parser.normalizeForTest({
        'type': 'user',
        'message': {
          'content': [
            {
              'type': 'tool_result',
              'tool_use_id': 'tool_xyz',
              'content': 'error message',
              'is_error': true,
            },
          ],
        },
      }).toList();
      final result = out.single as ClaudeEventToolResult;
      expect(result.isError, isTrue);
      expect(result.content, 'error message');
    });

    test('a tool_result with content=List of mixed blocks flattens text+image with newline join', () {
      final out = parser.normalizeForTest({
        'type': 'user',
        'message': {
          'content': [
            {
              'type': 'tool_result',
              'tool_use_id': 'tool_xyz',
              'content': [
                {'type': 'text', 'text': 'first'},
                {'type': 'image', 'source': {}},
                {'type': 'text', 'text': 'second'},
              ],
            },
          ],
        },
      }).toList();
      final result = out.single as ClaudeEventToolResult;
      // Per `_flattenToolResultContent`: text appended verbatim, image → "[image]",
      // each block followed by '\n', trimRight at the end.
      expect(result.content, 'first\n[image]\nsecond');
    });
  });
}
