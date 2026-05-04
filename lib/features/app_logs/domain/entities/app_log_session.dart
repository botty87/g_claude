import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_log_session.freezed.dart';

@freezed
abstract class AppLogSession with _$AppLogSession {
  const factory AppLogSession({
    required int id,
    required DateTime startedAt,
    required DateTime? endedAt,
    required String? appVersion,
    required String platform,
    required int errorCount,
    required int warningCount,
    required int totalCount,
  }) = _AppLogSession;
}
