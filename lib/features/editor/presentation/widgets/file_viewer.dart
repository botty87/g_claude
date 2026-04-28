import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../cubit/file_tabs_cubit.dart';
import 'code_view.dart';

class FileViewer extends StatelessWidget {
  const FileViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<WorkspacesCubit, WorkspacesState, WorkspaceId?>(
      selector: (state) => state.activeIdOrNull,
      builder: (context, activeId) {
        if (activeId == null) {
          return _emptyState();
        }
        return BlocSelector<FileTabsCubit, FileTabsState, String?>(
          selector: (state) => state.filesFor(activeId)?.activePath,
          builder: (context, activePath) {
            if (activePath == null) {
              return _emptyState();
            }
            return CodeView(
              key: ValueKey(activePath),
              path: activePath,
            );
          },
        );
      },
    );
  }

  Widget _emptyState() {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: Text(
          'editor.noFileOpen'.tr(),
          style: AppTypography.bodyMain.copyWith(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
