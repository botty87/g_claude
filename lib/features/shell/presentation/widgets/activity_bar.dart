import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/shell_cubit.dart';
import 'activity_bar_item.dart';

class ActivityBar extends StatelessWidget {
  const ActivityBar({super.key});

  static const double width = 50;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShellCubit, ShellState>(
      builder: (context, state) {
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
              _item(
                context,
                key: 'activity_explorer',
                icon: Symbols.folder,
                tooltip: 'Explorer',
                id: ActivityId.explorer,
                state: state,
                isEnabled: true,
              ),
              _item(
                context,
                key: 'activity_search',
                icon: Symbols.search,
                tooltip: 'Search',
                id: ActivityId.search,
                state: state,
                isEnabled: false,
              ),
              _item(
                context,
                key: 'activity_git',
                icon: Symbols.fork_right,
                tooltip: 'Source Control',
                id: ActivityId.git,
                state: state,
                isEnabled: false,
              ),
              _item(
                context,
                key: 'activity_sessions',
                icon: Symbols.chat,
                tooltip: 'Sessions',
                id: ActivityId.sessions,
                state: state,
                isEnabled: false,
              ),
              const Spacer(),
              _item(
                context,
                key: 'activity_settings',
                icon: Symbols.settings,
                tooltip: 'Settings',
                id: ActivityId.settings,
                state: state,
                isEnabled: false,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _item(
    BuildContext context, {
    required String key,
    required IconData icon,
    required String tooltip,
    required ActivityId id,
    required ShellState state,
    required bool isEnabled,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ActivityBarItem(
        key: ValueKey(key),
        icon: icon,
        tooltip: tooltip,
        isActive: state.selectedActivity == id,
        isEnabled: isEnabled,
        onTap: () => context.read<ShellCubit>().selectActivity(id),
      ),
    );
  }
}
