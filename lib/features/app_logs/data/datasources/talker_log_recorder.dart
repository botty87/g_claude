import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../domain/entities/app_log_entry.dart';
import '../../domain/repositories/app_logs_repository.dart';

@lazySingleton
class TalkerLogRecorder {
  TalkerLogRecorder(this._talker, this._repo);
  final Talker _talker;
  final AppLogsRepository _repo;

  StreamSubscription<TalkerData>? _sub;
  final List<AppLogEntryDraft> _buffer = [];
  Timer? _flushTimer;

  static const _flushDelay = Duration(milliseconds: 500);

  void start() {
    _sub ??= _talker.stream.listen(_onLog);
  }

  // Skip bloc-logger events emitted by app_logs cubits themselves: persisting
  // them triggers a DB UPDATE, which re-emits via watchSessions/watchEntries,
  // which produces another bloc-change event → infinite loop.
  static const _selfNoiseTokens = ['AppLogsCubit', 'AppLogDetailCubit'];

  void _onLog(TalkerData data) {
    final msg = data.generateTextMessage();
    for (final t in _selfNoiseTokens) {
      if (msg.contains(t)) return;
    }
    _buffer.add(
      AppLogEntryDraft(
        time: data.time,
        level: parseAppLogLevel(data.logLevel?.name),
        title: data.title,
        message: msg,
        exception: data.exception?.toString(),
        stackTrace: data.stackTrace?.toString(),
      ),
    );
    _flushTimer ??= Timer(_flushDelay, _flush);
  }

  Future<void> _flush() async {
    _flushTimer = null;
    if (_buffer.isEmpty) return;
    final batch = List.of(_buffer);
    _buffer.clear();
    await _repo.appendEntries(batch);
  }

  Future<void> stop() async {
    _flushTimer?.cancel();
    _flushTimer = null;
    await _sub?.cancel();
    _sub = null;
    await _flush();
  }
}
