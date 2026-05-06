import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../app_logs/presentation/widgets/logs_view.dart';
import '../../../claude/presentation/widgets/sessions_list_view.dart';
import '../../../explorer/presentation/widgets/explorer_view.dart';
import '../cubit/shell_cubit.dart';

class SidePanel extends StatelessWidget {
  const SidePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(
          right: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      child: BlocBuilder<ShellCubit, ShellState>(
        buildWhen: (p, c) => p.selectedActivity != c.selectedActivity,
        builder: (context, state) {
          switch (state.selectedActivity) {
            case ActivityId.explorer:
              return const ExplorerView();
            case ActivityId.sessions:
              return const SessionsListView();
            case ActivityId.logs:
              return const LogsView();
            case ActivityId.terminal:
            case ActivityId.search:
            case ActivityId.git:
            case ActivityId.settings:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
