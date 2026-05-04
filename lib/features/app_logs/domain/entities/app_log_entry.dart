import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_log_entry.freezed.dart';

enum AppLogLevel { debug, info, warning, error, critical, verbose }

@freezed
abstract class AppLogEntry with _$AppLogEntry {
  const factory AppLogEntry({
    required int id,
    required int sessionId,
    required DateTime time,
    required AppLogLevel level,
    required String? title,
    required String message,
    required String? exception,
    required String? stackTrace,
  }) = _AppLogEntry;
}

@freezed
abstract class AppLogEntryDraft with _$AppLogEntryDraft {
  const factory AppLogEntryDraft({
    required DateTime time,
    required AppLogLevel level,
    required String? title,
    required String message,
    required String? exception,
    required String? stackTrace,
  }) = _AppLogEntryDraft;
}

AppLogLevel parseAppLogLevel(String? raw) {
  switch (raw?.toUpperCase()) {
    case 'DEBUG':
      return AppLogLevel.debug;
    case 'WARNING':
      return AppLogLevel.warning;
    case 'ERROR':
      return AppLogLevel.error;
    case 'CRITICAL':
      return AppLogLevel.critical;
    case 'VERBOSE':
      return AppLogLevel.verbose;
    case 'INFO':
    default:
      return AppLogLevel.info;
  }
}

String appLogLevelToString(AppLogLevel l) => l.name.toUpperCase();
