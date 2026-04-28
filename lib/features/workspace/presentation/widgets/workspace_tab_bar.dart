import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../cubit/workspaces_cubit.dart';
import 'new_workspace_button.dart';
import 'workspace_tab.dart';

class WorkspaceTabBar extends StatelessWidget {
  const WorkspaceTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspacesCubit, WorkspacesState>(
      builder: (context, state) {
        final list = state.workspacesOrEmpty;
        final activeId = state.activeIdOrNull;
        return Container(
          height: AppSpacing.toolbarHeight,
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLow,
            border: Border(
              bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            children: [
              const SizedBox(width: 64), // space for macOS traffic lights
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final w in list)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: WorkspaceTab(
                            key: ValueKey('workspace_tab_${w.id}'),
                            workspace: w,
                            isActive: w.id == activeId,
                            onTap: () => context.read<WorkspacesCubit>().setActive(w.id),
                            onClose: () => context.read<WorkspacesCubit>().closeWorkspace(w.id),
                          ),
                        ),
                      const NewWorkspaceButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
