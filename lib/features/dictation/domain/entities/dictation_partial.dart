import 'package:freezed_annotation/freezed_annotation.dart';

part 'dictation_partial.freezed.dart';

@freezed
abstract class DictationPartial with _$DictationPartial {
  const factory DictationPartial({
    required String text,
    required bool isFinal,
  }) = _DictationPartial;
}
