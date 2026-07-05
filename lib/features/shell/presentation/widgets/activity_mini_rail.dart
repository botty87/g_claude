import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../cubit/shell_cubit.dart';

class _RailEntry {
  const _RailEntry({required this.id, required this.icon, required this.tooltipKey, required this.keyName});

  final ActivityId id;
  final IconData icon;
  final String tooltipKey;
  final String keyName;
}

// "Chat" maps to explorer (the default workspace view, with its Chat/Code/
// Terminal segmented control). Terminal is no longer here — it is a center
// segment.
const _entries = [
  _RailEntry(id: ActivityId.explorer, icon: Symbols.forum, tooltipKey: 'shell.activity.explorer', keyName: 'rail_chat'),
];

// Sessions, Logs and Settings are hidden until those views are reworked/
// implemented. Entries kept (and their ActivityId pages/cubits remain fully
// wired) so re-enabling is a one-line add back into [_entries].
// ignore: unused_element
const _sessionsEntry = _RailEntry(
  id: ActivityId.sessions,
  icon: Symbols.history,
  tooltipKey: 'shell.activity.sessions',
  keyName: 'rail_sessions',
);
// ignore: unused_element
const _logsEntry = _RailEntry(
  id: ActivityId.logs,
  icon: Symbols.receipt_long,
  tooltipKey: 'shell.activity.logs',
  keyName: 'rail_logs',
);
// ignore: unused_element
const _settingsEntry = _RailEntry(
  id: ActivityId.settings,
  icon: Symbols.settings,
  tooltipKey: 'shell.activity.settings',
  keyName: 'rail_settings',
);

/// Compact activity switcher living at the bottom of [WorkspaceSidebar].
/// Replaces the standalone vertical [ActivityBar].
class ActivityMiniRail extends StatelessWidget {
  const ActivityMiniRail({super.key, required this.axis});

  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final selected = context.select<ShellCubit, ActivityId>((c) => c.state.selectedActivity);

    final items = <Widget>[for (final e in _entries) _RailItem(entry: e, isActive: selected == e.id)];

    if (axis == Axis.horizontal) {
      return Row(children: items);
    }
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: item,
          ),
      ],
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({required this.entry, required this.isActive});

  final _RailEntry entry;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      onTap: () => context.read<ShellCubit>().selectActivity(entry.id),
      builder: (context, hover) => Tooltip(
        message: entry.tooltipKey.tr(),
        child: Container(
          key: ValueKey(entry.keyName),
          width: 28,
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.brandIndigo.withValues(alpha: 0.18)
                : (hover ? AppColors.glassHover : Colors.transparent),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Icon(entry.icon, size: 16, color: isActive ? AppColors.primary : AppColors.onSurfaceVariant),
        ),
      ),
    );
  }
}
