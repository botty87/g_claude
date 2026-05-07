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

  /// Tokens occupying the context window as of the last turn the model
  /// processed. Sum of `input + cacheRead + cacheCreation` reported by
  /// Anthropic in `message_start.usage` — this is exactly what was sent
  /// to the model that turn. Output tokens are excluded because they are
  /// produced by the model and only count as input on the *next* turn.
  /// Updated per turn (not cumulative across turns).
  int get contextTokens => inputTokens + cacheReadTokens + cacheCreationTokens;
}
