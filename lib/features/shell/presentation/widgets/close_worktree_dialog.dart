import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';

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

    final subtitle = branch == null ? name : '$name  ($branch)';

    Future<void> confirm() async {
      final cubit = context.read<WorkspacesCubit>();
      if (isMain) {
        cubit.closeWorkspace(workspaceId);
        Navigator.of(context).pop();
        return;
      }

      if (choice.value == _CloseChoice.closeOnly) {
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

    return AlertDialog(
      title: Text(Locales.Shell.CloseWorktree.title),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            if (isMain)
              Text(Locales.Shell.CloseWorktree.mainCannotRemove)
            else ...[
              RadioGroup<_CloseChoice>(
                groupValue: choice.value,
                onChanged: busy.value ? (_) {} : (v) => choice.value = v!,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<_CloseChoice>(
                      key: const ValueKey('close_worktree_option_closeOnly'),
                      value: _CloseChoice.closeOnly,
                      enabled: !busy.value,
                      title: Text(Locales.Shell.CloseWorktree.optionCloseOnly),
                      subtitle: Text(Locales.Shell.CloseWorktree.optionCloseOnlyDescr),
                    ),
                    RadioListTile<_CloseChoice>(
                      key: const ValueKey('close_worktree_option_removeWorktree'),
                      value: _CloseChoice.removeWorktree,
                      enabled: !busy.value,
                      title: Text(Locales.Shell.CloseWorktree.optionRemoveWorktree),
                      subtitle: Text(Locales.Shell.CloseWorktree.optionRemoveWorktreeDescr),
                    ),
                    RadioListTile<_CloseChoice>(
                      key: const ValueKey('close_worktree_option_removeWorktreeAndBranch'),
                      value: _CloseChoice.removeWorktreeAndBranch,
                      enabled: !busy.value,
                      title: Text(Locales.Shell.CloseWorktree.optionRemoveBranch),
                      subtitle: Text(Locales.Shell.CloseWorktree.optionRemoveBranchDescr),
                    ),
                  ],
                ),
              ),
              if (error.value != null) ...[
                const SizedBox(height: 8),
                Text(_messageOf(error.value!), style: TextStyle(color: Theme.of(context).colorScheme.error)),
                Row(
                  children: [
                    Checkbox(
                      key: const ValueKey('close_worktree_force'),
                      value: force.value,
                      onChanged: busy.value ? null : (v) => force.value = v ?? false,
                    ),
                    Text(Locales.Shell.CloseWorktree.force),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy.value ? null : () => Navigator.of(context).pop(),
          child: Text(Locales.Shell.CloseWorktree.cancel),
        ),
        TextButton(
          key: const ValueKey('close_worktree_confirm'),
          onPressed: busy.value ? null : confirm,
          child: busy.value
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(Locales.Shell.CloseWorktree.confirm),
        ),
      ],
    );
  }
}
