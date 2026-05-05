import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/shell_cubit.dart';
import 'activity_bar_item.dart';

class _ActivityEntry {
  const _ActivityEntry({
    required this.id,
    required this.icon,
    required this.tooltipKey,
    required this.keyName,
    required this.isEnabled,
  });

  final ActivityId id;
  final IconData icon;
  final String tooltipKey;
  final String keyName;
  final bool isEnabled;
}

const _topEntries = [
  _ActivityEntry(
    id: ActivityId.explorer,
    icon: Symbols.folder,
    tooltipKey: 'shell.activity.explorer',
    keyName: 'activity_explorer',
    isEnabled: true,
  ),
  _ActivityEntry(
    id: ActivityId.sessions,
    icon: Symbols.chat,
    tooltipKey: 'shell.activity.sessions',
    keyName: 'activity_sessions',
    isEnabled: true,
  ),
  _ActivityEntry(
    id: ActivityId.logs,
    icon: Symbols.receipt_long,
    tooltipKey: 'shell.activity.logs',
    keyName: 'activity_logs',
    isEnabled: true,
  ),
];

class ActivityBar extends StatelessWidget {
  const ActivityBar({super.key});

  static const double width = 50;

  @override
  Widget build(BuildContext context) {
    final selected = context.select<ShellCubit, ActivityId>(
      (c) => c.state.selectedActivity,
    );
    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          right: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          for (final e in _topEntries) _entryItem(context, e, selected),
        ],
      ),
    );
  }

  Widget _entryItem(BuildContext context, _ActivityEntry e, ActivityId selected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ActivityBarItem(
        key: ValueKey(e.keyName),
        icon: e.icon,
        tooltip: e.tooltipKey.tr(),
        isActive: selected == e.id,
        isEnabled: e.isEnabled,
        onTap: () => context.read<ShellCubit>().selectActivity(e.id),
      ),
    );
  }
}
