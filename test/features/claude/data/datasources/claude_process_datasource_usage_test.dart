// Contracts for the usageUpdate event emitted by the NDJSON parser when it
// encounters `message_start` and `message_delta` stream_event envelopes.
//
// The `simple_text.ndjson` fixture (real run captured from production) contains
// both event types with usage data. Synthetic inputs cover the edge cases
// (missing usage field, partial fields only).

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/claude/data/datasources/claude_binary_resolver.dart';
import 'package:g_claude/features/claude/data/datasources/claude_process_datasource.dart';
import 'package:g_claude/features/claude/data/datasources/claude_settings_writer.dart';
import 'package:g_claude/features/claude/data/datasources/permission_server.dart';
import 'package:g_claude/features/claude/domain/entities/claude_event.dart';

import '../../../../helpers/fakes.dart';

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

List<ClaudeEvent> _runFixture(ClaudeProcessDataSourceImpl parser, String relativePath) {
  parser.resetParserStateForTest();
  final events = <ClaudeEvent>[];
  for (final raw in _readFixture(relativePath)) {
    if (raw['type'] == 'control_response') continue;
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

  group('usageUpdate from real simple_text fixture — message_start and message_delta', () {
    late List<ClaudeEventUsageUpdate> usageEvents;

    setUp(() {
      final events = _runFixture(parser, 'simple_text.ndjson');
      usageEvents = events.whereType<ClaudeEventUsageUpdate>().toList();
    });

    test('at least one usageUpdate is emitted from the message_start envelope', () {
      expect(usageEvents, isNotEmpty, reason: 'simple_text.ndjson has a message_start with a usage object');
    });

    test('the first usageUpdate carries non-zero inputTokens or cache tokens', () {
      final first = usageEvents.first;
      final hasPositiveContext =
          (first.inputTokens ?? 0) > 0 || (first.cacheReadTokens ?? 0) > 0 || (first.cacheCreationTokens ?? 0) > 0;
      expect(
        hasPositiveContext,
        isTrue,
        reason: 'message_start usage must include at least one non-zero input/cache field',
      );
    });
  });

  group('usageUpdate — synthetic: message_start with all usage fields', () {
    test('emits usageUpdate with all four fields parsed from message_start', () {
      final out = parser.normalizeForTest({
        'type': 'stream_event',
        'event': {
          'type': 'message_start',
          'message': {
            'usage': {
              'input_tokens': 100,
              'cache_read_input_tokens': 5000,
              'cache_creation_input_tokens': 200,
              'output_tokens': 0,
            },
          },
        },
      }).toList();

      expect(out, hasLength(1));
      final e = out.single as ClaudeEventUsageUpdate;
      expect(e.inputTokens, 100);
      expect(e.cacheReadTokens, 5000);
      expect(e.cacheCreationTokens, 200);
      expect(e.outputTokens, 0);
    });
  });

  group('usageUpdate — synthetic: message_delta with output_tokens only', () {
    test('emits usageUpdate with only outputTokens set from message_delta', () {
      final out = parser.normalizeForTest({
        'type': 'stream_event',
        'event': {
          'type': 'message_delta',
          'usage': {'output_tokens': 250},
        },
      }).toList();

      expect(out, hasLength(1));
      final e = out.single as ClaudeEventUsageUpdate;
      expect(e.outputTokens, 250);
      // input/cache fields are null — cubit merges from previous state
      expect(e.inputTokens, isNull);
      expect(e.cacheReadTokens, isNull);
      expect(e.cacheCreationTokens, isNull);
    });
  });

  group('usageUpdate — synthetic: frames without usage field emit no event', () {
    test('message_start without usage object emits zero usageUpdate events', () {
      final out = parser.normalizeForTest({
        'type': 'stream_event',
        'event': {
          'type': 'message_start',
          'message': {'model': 'claude-sonnet-4-5'},
        },
      }).toList();

      expect(out.whereType<ClaudeEventUsageUpdate>(), isEmpty);
    });

    test('message_delta without usage field emits zero usageUpdate events', () {
      final out = parser.normalizeForTest({
        'type': 'stream_event',
        'event': {
          'type': 'message_delta',
          'delta': {'stop_reason': 'end_turn'},
        },
      }).toList();

      expect(out.whereType<ClaudeEventUsageUpdate>(), isEmpty);
    });
  });
}
