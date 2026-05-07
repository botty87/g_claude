import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../domain/entities/slash_command.dart';
import '../../domain/entities/slash_command_source.dart';
import '../../domain/usecases/filter_slash_commands.dart';
import '../../domain/usecases/load_slash_commands.dart';

part 'slash_commands_cubit.freezed.dart';
part 'slash_commands_cubit.state.dart';

final slashTriggerRegex = RegExp(r'^\s*\/[a-zA-Z0-9:_-]*$');

/// Matches the trailing slash token on a line: a `/` preceded by start-of-line
/// or whitespace, followed by zero or more allowed slash-command characters,
/// anchored to the end. Captures the token (including the leading slash).
final slashTokenAtEndRegex = RegExp(r'(?:^|\s)(\/[a-zA-Z0-9:_-]*)$');

@injectable
class SlashCommandsCubit extends Cubit<SlashCommandsState> {
  SlashCommandsCubit(this._load, this._filter, this._talker) : super(const SlashCommandsState.idle());

  final LoadSlashCommands _load;
  final FilterSlashCommands _filter;
  final Talker _talker;

  List<SlashCommand> get _all => switch (state) {
    SlashCommandsStateIdle(:final all) => all,
    SlashCommandsStateSuggesting(:final all) => all,
  };

  Future<void> loadFor(String? workspaceCwd) async {
    final result = await _load.call(workspaceCwd: workspaceCwd);
    if (isClosed) return;
    result.fold(
      (failure) {
        _talker.warning('slash_commands: load failed: $failure');
        emit(const SlashCommandsState.idle());
      },
      (commands) {
        emit(SlashCommandsState.idle(all: commands));
      },
    );
  }

  void updateSkills(List<String> skills) {
    final existing = _all;
    final existingTriggers = existing.map((c) => c.trigger).toSet();
    final skillCommands = skills
        .where((s) => s.isNotEmpty)
        .map((s) => SlashCommand(name: s, trigger: '/$s', description: s, source: SlashCommandSource.skill))
        .where((c) => !existingTriggers.contains(c.trigger))
        .toList();

    final merged = [...existing, ...skillCommands];

    switch (state) {
      case SlashCommandsStateIdle():
        emit(SlashCommandsState.idle(all: merged));
      case SlashCommandsStateSuggesting(:final filter, :final selectedIndex):
        final filtered = _filter.call(merged, filter);
        final clampedIndex = filtered.isEmpty ? 0 : selectedIndex.clamp(0, filtered.length - 1);
        emit(
          SlashCommandsState.suggesting(all: merged, filtered: filtered, selectedIndex: clampedIndex, filter: filter),
        );
    }
  }

  void onInputChanged(String text) {
    final lastLine = text.split('\n').last;
    final match = slashTokenAtEndRegex.firstMatch(lastLine);
    if (match != null) {
      final filter = match.group(1) ?? '/';
      final all = _all;
      final matched = _filter.call(all, filter);
      final filtered = matched.isEmpty ? all : matched;
      final current = state;
      final prevIndex = current is SlashCommandsStateSuggesting ? current.selectedIndex : 0;
      final clampedIndex = filtered.isEmpty ? 0 : prevIndex.clamp(0, filtered.length - 1);
      emit(SlashCommandsState.suggesting(all: all, filtered: filtered, selectedIndex: clampedIndex, filter: filter));
    } else {
      dismiss();
    }
  }

  void moveSelection(int delta) {
    final s = state;
    if (s is! SlashCommandsStateSuggesting) return;
    if (s.filtered.isEmpty) return;
    final next = (s.selectedIndex + delta).clamp(0, s.filtered.length - 1);
    emit(s.copyWith(selectedIndex: next));
  }

  void selectAt(int index) {
    final s = state;
    if (s is! SlashCommandsStateSuggesting) return;
    if (index < 0 || index >= s.filtered.length) return;
    emit(s.copyWith(selectedIndex: index));
  }

  SlashCommand? accept() {
    final s = state;
    if (s is! SlashCommandsStateSuggesting) return null;
    if (s.filtered.isEmpty) return null;
    final index = s.selectedIndex.clamp(0, s.filtered.length - 1);
    return s.filtered[index];
  }

  void dismiss() {
    final all = _all;
    emit(SlashCommandsState.idle(all: all));
  }
}
