import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/glass/glass_pane.dart';
import '../../domain/entities/slash_command.dart';
import 'slash_command_item.dart';

class SlashCommandMenu extends HookWidget {
  const SlashCommandMenu({
    super.key,
    required this.commands,
    required this.selectedIndex,
    required this.onSelect,
    required this.onAccept,
  });

  final List<SlashCommand> commands;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final ValueChanged<SlashCommand> onAccept;

  static const _itemHeight = 44.0;
  static const _maxVisible = 6;

  @override
  Widget build(BuildContext context) {
    final controller = useScrollController();

    useEffect(() {
      if (commands.isEmpty) return null;
      final offset = selectedIndex * _itemHeight;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!controller.hasClients) return;
        controller.animateTo(
          offset.clamp(0.0, controller.position.maxScrollExtent),
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
        );
      });
      return null;
    }, [selectedIndex]);

    if (commands.isEmpty) {
      return GlassPane(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            Locales.SlashCommands.empty,
            style: AppTypography.bodyMain.copyWith(fontSize: 12, color: AppColors.outline, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    final visibleCount = commands.length.clamp(1, _maxVisible);
    final height = visibleCount * _itemHeight;

    return GlassPane(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560, maxHeight: height),
        child: ListView.builder(
          controller: controller,
          padding: EdgeInsets.zero,
          itemCount: commands.length,
          itemExtent: _itemHeight,
          itemBuilder: (context, index) => SlashCommandItem(
            key: ValueKey(commands[index].trigger),
            command: commands[index],
            selected: index == selectedIndex,
            onTap: () {
              onSelect(index);
              onAccept(commands[index]);
            },
          ),
        ),
      ),
    );
  }
}
