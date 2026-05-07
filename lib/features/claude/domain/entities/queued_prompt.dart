import 'package:freezed_annotation/freezed_annotation.dart';

part 'queued_prompt.freezed.dart';

@freezed
abstract class QueuedPrompt with _$QueuedPrompt {
  const factory QueuedPrompt({required String text, required DateTime enqueuedAt}) = _QueuedPrompt;
}
