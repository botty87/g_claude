import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../workspace/domain/entities/workspace.dart';

class WorkspaceView extends StatelessWidget {
  const WorkspaceView({super.key, required this.workspace});

  final Workspace workspace;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            workspace.path,
            style: AppTypography.sidebarLabel.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _ClaudeMdView(content: workspace.claudeMd),
          ),
          const SizedBox(height: AppSpacing.md),
          const _DisabledChatInput(),
        ],
      ),
    );
  }
}

class _ClaudeMdView extends StatelessWidget {
  const _ClaudeMdView({required this.content});

  final String? content;

  @override
  Widget build(BuildContext context) {
    if (content == null) {
      return Center(
        child: Text(
          'No CLAUDE.md in this workspace',
          style: AppTypography.bodyMain.copyWith(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SingleChildScrollView(
        child: SelectableText(
          content!,
          key: const ValueKey('claude_md_content'),
          style: AppTypography.terminalCode.copyWith(
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}

class _DisabledChatInput extends StatelessWidget {
  const _DisabledChatInput();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Coming in session 3',
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.outlineVariant, width: 1),
        ),
        child: Row(
          children: [
            Icon(
              Icons.lock_outline,
              size: 16,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Ask Claude... (coming in session 3)',
              style: AppTypography.bodyMain.copyWith(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
