import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../editor/presentation/cubit/file_tabs_cubit.dart';
import '../../../editor/presentation/widgets/file_viewer.dart';
import '../../../explorer/presentation/widgets/explorer_view.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';

enum _RightTab { files, diff, editor }

/// Right-hand navigation panel: Files tree, Diff (stub), and an Editor view for
/// the active file. Opening a file from the tree auto-focuses the Editor tab.
class RightPanel extends HookWidget {
  const RightPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final tab = useState(_RightTab.files);
    final activeId = context.select<WorkspacesCubit, WorkspaceId?>((c) => c.state.activeIdOrNull);
    final lastActivePath = useRef<String?>(null);

    return BlocListener<FileTabsCubit, FileTabsState>(
      listenWhen: (prev, curr) {
        if (activeId == null) return false;
        return prev.filesFor(activeId)?.activePath != curr.filesFor(activeId)?.activePath;
      },
      listener: (context, state) {
        final activePath = activeId == null ? null : state.filesFor(activeId)?.activePath;
        if (activePath != null && activePath != lastActivePath.value) {
          tab.value = _RightTab.editor;
        }
        lastActivePath.value = activePath;
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainer,
          border: Border(left: BorderSide(color: AppColors.outlineVariant, width: 1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TabBar(current: tab.value, onSelect: (t) => tab.value = t),
            Expanded(
              child: switch (tab.value) {
                _RightTab.files => const ExplorerView(),
                _RightTab.diff => const _StubMessage(),
                _RightTab.editor => const FileViewer(),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.current, required this.onSelect});

  final _RightTab current;
  final ValueChanged<_RightTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 1)),
      ),
      child: Row(
        children: [
          _TabButton(
            keyName: 'right_tab_files',
            icon: Symbols.folder,
            label: Locales.Shell.RightPanel.files,
            isActive: current == _RightTab.files,
            onTap: () => onSelect(_RightTab.files),
          ),
          _TabButton(
            keyName: 'right_tab_diff',
            icon: Symbols.difference,
            label: Locales.Shell.RightPanel.diff,
            isActive: current == _RightTab.diff,
            onTap: () => onSelect(_RightTab.diff),
          ),
          _TabButton(
            keyName: 'right_tab_editor',
            icon: Symbols.code,
            label: Locales.Shell.RightPanel.editor,
            isActive: current == _RightTab.editor,
            onTap: () => onSelect(_RightTab.editor),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.keyName,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String keyName;
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.onSurface : AppColors.outline;
    return GestureDetector(
      key: ValueKey(keyName),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isActive ? AppColors.brandIndigo : Colors.transparent, width: 2)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(label, style: AppTypography.navTab.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StubMessage extends StatelessWidget {
  const _StubMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        Locales.Shell.RightPanel.diffComingSoon,
        style: AppTypography.bodyMain.copyWith(fontSize: 13, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
      ),
    );
  }
}
