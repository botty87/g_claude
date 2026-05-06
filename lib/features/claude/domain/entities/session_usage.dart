import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_usage.freezed.dart';

@freezed
abstract class SessionUsage with _$SessionUsage {
  const SessionUsage._();

  const factory SessionUsage({
    @Default(0) int inputTokens,
    @Default(0) int cacheReadTokens,
    @Default(0) int cacheCreationTokens,
    @Default(0) int outputTokens,
  }) = _SessionUsage;

  /// Context window currently occupied (input + cache, excluding output).
  int get contextTokens => inputTokens + cacheReadTokens + cacheCreationTokens;
}
