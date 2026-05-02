import 'package:freezed_annotation/freezed_annotation.dart';

import 'slash_command_source.dart';

part 'slash_command.freezed.dart';

@freezed
abstract class SlashCommand with _$SlashCommand {
  const factory SlashCommand({
    required String name,
    required String trigger,
    required String description,
    String? argumentHint,
    required SlashCommandSource source,
    String? filePath,
    @Default(<String>[]) List<String> allowedTools,
  }) = _SlashCommand;
}
