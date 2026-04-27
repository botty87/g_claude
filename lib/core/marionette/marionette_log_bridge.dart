import 'dart:async';

import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Forwards every Talker event to Marionette's [PrintLogCollector] so the
/// MCP `get_logs` tool surfaces app-level logs (Bloc transitions, repository
/// errors, service info) alongside framework output.
class MarionetteLogBridge {
  MarionetteLogBridge({required this.talker, required this.collector});

  final Talker talker;
  final PrintLogCollector collector;
  StreamSubscription<TalkerData>? _sub;

  void start() {
    _sub ??= talker.stream.listen((data) {
      final level = data.logLevel?.name.toUpperCase() ?? 'LOG';
      final body = data.generateTextMessage();
      final exception = data.exception != null ? '\n${data.exception}' : '';
      final error = data.error != null ? '\n${data.error}' : '';
      collector.addLog('[$level] $body$exception$error');
    });
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }
}
