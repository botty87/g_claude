part of 'slash_commands_cubit.dart';

@freezed
sealed class SlashCommandsState with _$SlashCommandsState {
  const factory SlashCommandsState.idle({@Default(<SlashCommand>[]) List<SlashCommand> all}) = SlashCommandsStateIdle;

  const factory SlashCommandsState.suggesting({
    required List<SlashCommand> all,
    required List<SlashCommand> filtered,
    required int selectedIndex,
    required String filter,
  }) = SlashCommandsStateSuggesting;
}
