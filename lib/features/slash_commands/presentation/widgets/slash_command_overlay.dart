import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../domain/entities/slash_command.dart';
import '../cubit/slash_commands_cubit.dart';
import 'slash_command_menu.dart';

class SlashCommandOverlay extends HookWidget {
  const SlashCommandOverlay({
    super.key,
    required this.link,
    required this.cubit,
    required this.onAccept,
    required this.onDismiss,
    required this.child,
    this.excludedTriggers = const {},
  });

  final LayerLink link;
  final SlashCommandsCubit cubit;
  final ValueChanged<SlashCommand> onAccept;
  final VoidCallback onDismiss;
  final Widget child;
  final Set<String> excludedTriggers;

  @override
  Widget build(BuildContext context) {
    final portalController = useMemoized(OverlayPortalController.new, const []);

    return BlocProvider.value(
      value: cubit,
      child: BlocListener<SlashCommandsCubit, SlashCommandsState>(
        listener: (context, state) {
          if (state is SlashCommandsStateSuggesting) {
            if (!portalController.isShowing) portalController.show();
          } else {
            if (portalController.isShowing) portalController.hide();
          }
        },
        child: OverlayPortal(
          controller: portalController,
          overlayChildBuilder: (context) {
            return BlocBuilder<SlashCommandsCubit, SlashCommandsState>(
              bloc: cubit,
              builder: (context, state) {
                if (state is! SlashCommandsStateSuggesting) {
                  return const SizedBox.shrink();
                }
                final visibleCommands = state.filtered
                    .where((c) => !excludedTriggers.contains(c.trigger))
                    .toList();
                final clampedIndex = visibleCommands.isEmpty
                    ? 0
                    : state.selectedIndex.clamp(0, visibleCommands.length - 1);
                return TapRegion(
                  onTapOutside: (_) => onDismiss(),
                  child: CompositedTransformFollower(
                    link: link,
                    targetAnchor: Alignment.topLeft,
                    followerAnchor: Alignment.bottomLeft,
                    offset: const Offset(0, -8),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: ExcludeFocus(
                        child: SlashCommandMenu(
                          commands: visibleCommands,
                          selectedIndex: clampedIndex,
                          onSelect: cubit.selectAt,
                          onAccept: onAccept,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
          child: child,
        ),
      ),
    );
  }
}
