import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import 'glass_dialog.dart';

/// Radio choice for closing/removing a linked worktree. Not shown for the
/// main checkout, which can only be closed (never removed as a worktree).
enum _CloseChoice { closeOnly, removeWorktree, removeWorktreeAndBranch }

Future<void> showCloseWorktreeDialog(
  BuildContext context, {
  required WorkspaceId workspaceId,
  required String name,
  String? branch,
  required bool isMain,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: kGlassDialogBarrier,
    builder: (_) => CloseWorktreeDialog(workspaceId: workspaceId, name: name, branch: branch, isMain: isMain),
  );
}

String _messageOf(Failure f) => switch (f) {
  SubprocessFailure(:final message) => message,
  UnexpectedFailure(:final message) => message,
  NotFoundFailure(:final message) => message,
  _ => f.toString(),
};

class CloseWorktreeDialog extends HookWidget {
  const CloseWorktreeDialog({
    super.key,
    required this.workspaceId,
    required this.name,
    this.branch,
    required this.isMain,
  });

  final WorkspaceId workspaceId;
  final String name;
  final String? branch;
  final bool isMain;

  @override
  Widget build(BuildContext context) {
    final choice = useState(_CloseChoice.closeOnly);
    final force = useState(false);
    final error = useState<Failure?>(null);
    final busy = useState(false);

    Future<void> confirm() async {
      final cubit = context.read<WorkspacesCubit>();
      if (isMain || choice.value == _CloseChoice.closeOnly) {
        cubit.closeWorkspace(workspaceId);
        Navigator.of(context).pop();
        return;
      }

      busy.value = true;
      error.value = null;
      final result = await cubit.removeWorktree(
        workspaceId,
        deleteBranch: choice.value == _CloseChoice.removeWorktreeAndBranch,
        force: force.value,
        forceBranch: force.value,
        // Delete exactly the branch shown to the user (may be enriched from the
        // live git list when the workspace's own field is stale/null).
        branch: branch,
      );
      if (!context.mounted) return;
      result.fold((failure) {
        error.value = failure;
        busy.value = false;
      }, (_) => Navigator.of(context).pop());
    }

    final destructive = !isMain && choice.value == _CloseChoice.removeWorktreeAndBranch;

    return GlassDialog(
      width: 460,
      children: [
        GlassDialogHeader(
          icon: Symbols.warning,
          iconTint: AppColors.tertiary,
          title: Locales.Shell.CloseWorktree.title,
          divider: true,
          padding: const EdgeInsets.fromLTRB(22, 20, 16, 16),
          onClose: busy.value ? null : () => Navigator.of(context).pop(),
          subtitle: GlassBranchChip(name: name, branch: branch),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMain)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    Locales.Shell.CloseWorktree.mainCannotRemove,
                    style: AppTypography.navTab.copyWith(
                      fontSize: 12.5,
                      height: 1.5,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                )
              else ...[
                GlassOptionCard(
                  key: const ValueKey('close_worktree_option_closeOnly'),
                  selected: choice.value == _CloseChoice.closeOnly,
                  enabled: !busy.value,
                  onTap: () => choice.value = _CloseChoice.closeOnly,
                  icon: Symbols.chat_bubble,
                  title: Locales.Shell.CloseWorktree.optionCloseOnly,
                  description: Locales.Shell.CloseWorktree.optionCloseOnlyDescr,
                  badge: GlassBadge(label: Locales.Shell.CloseWorktree.badgeSafe, color: AppColors.secondary),
                ),
                const SizedBox(height: 8),
                GlassOptionCard(
                  key: const ValueKey('close_worktree_option_removeWorktree'),
                  selected: choice.value == _CloseChoice.removeWorktree,
                  enabled: !busy.value,
                  onTap: () => choice.value = _CloseChoice.removeWorktree,
                  icon: Symbols.folder,
                  title: Locales.Shell.CloseWorktree.optionRemoveWorktree,
                  description: Locales.Shell.CloseWorktree.optionRemoveWorktreeDescr,
                ),
                const SizedBox(height: 8),
                GlassOptionCard(
                  key: const ValueKey('close_worktree_option_removeWorktreeAndBranch'),
                  selected: choice.value == _CloseChoice.removeWorktreeAndBranch,
                  enabled: !busy.value,
                  onTap: () => choice.value = _CloseChoice.removeWorktreeAndBranch,
                  icon: Symbols.delete,
                  destructive: true,
                  title: Locales.Shell.CloseWorktree.optionRemoveBranch,
                  description: Locales.Shell.CloseWorktree.optionRemoveBranchDescr,
                  badge: GlassBadge(label: Locales.Shell.CloseWorktree.badgeDestructive, color: AppColors.error),
                ),
              ],
              if (error.value != null) ...[
                const SizedBox(height: 10),
                Text(
                  _messageOf(error.value!),
                  style: AppTypography.navTab.copyWith(fontSize: 12, height: 1.4, color: AppColors.error),
                ),
                Row(
                  children: [
                    Checkbox(
                      key: const ValueKey('close_worktree_force'),
                      value: force.value,
                      onChanged: busy.value ? null : (v) => force.value = v ?? false,
                    ),
                    Text(
                      Locales.Shell.CloseWorktree.force,
                      style: AppTypography.navTab.copyWith(fontSize: 12.5, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        GlassDialogActions(
          cancelLabel: Locales.Shell.CloseWorktree.cancel,
          onCancel: busy.value ? null : () => Navigator.of(context).pop(),
          confirmLabel: Locales.Shell.CloseWorktree.confirm,
          confirmKey: const ValueKey('close_worktree_confirm'),
          confirmBusy: busy.value,
          destructive: destructive,
          onConfirm: busy.value ? null : confirm,
        ),
      ],
    );
  }
}
