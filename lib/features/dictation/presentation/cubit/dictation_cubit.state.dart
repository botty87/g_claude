part of 'dictation_cubit.dart';

@freezed
sealed class DictationState with _$DictationState {
  const factory DictationState.initial({
    required DictationMode mode,
  }) = DictationStateInitial;

  const factory DictationState.listening({
    required String workspaceId,
    required String baseText,
    required int baseOffset,
    required String currentPartial,
    required DictationMode mode,
  }) = DictationStateListening;

  const factory DictationState.error({
    required Failure failure,
    required DictationMode mode,
  }) = DictationStateError;
}
