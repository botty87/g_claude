import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' as p;

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../../../editor/presentation/cubit/editor_view_cubit.dart';
import '../../../editor/presentation/cubit/file_tabs_cubit.dart';
import '../../../git/domain/entities/git_diff_file.dart';
import '../../../git/presentation/cubit/git_diff_cubit.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';

/// A flattened row of the diff tree view.
class DiffTreeEntry {
  const DiffTreeEntry.dir({required this.fullPath, required this.name, required this.depth, required this.fileCount})
    : isDir = true,
      file = null;

  const DiffTreeEntry.file({required this.file, required this.depth})
    : isDir = false,
      fullPath = '',
      name = '',
      fileCount = 0;

  final bool isDir;
  final String fullPath;
  final String name;
  final int depth;
  final int fileCount;
  final GitDiffFile? file;
}

class _DirNode {
  final Map<String, _DirNode> dirs = {};
  final List<GitDiffFile> files = [];
  int count = 0;
}

/// Groups [files] by directory into a flattened, depth-annotated row list.
/// Directories in [collapsedDirs] (by full path) hide their descendants.
@visibleForTesting
List<DiffTreeEntry> buildDiffTreeRows(List<GitDiffFile> files, Set<String> collapsedDirs) {
  final root = _DirNode();
  for (final f in files) {
    final dir = p.dirname(f.path);
    final segments = (dir == '.' || dir.isEmpty) ? const <String>[] : p.split(dir);
    var node = root;
    node.count++;
    for (final seg in segments) {
      node = node.dirs.putIfAbsent(seg, _DirNode.new);
      node.count++;
    }
    node.files.add(f);
  }

  final out = <DiffTreeEntry>[];
  void walk(_DirNode node, String prefix, int depth) {
    final dirNames = node.dirs.keys.toList()..sort();
    for (final name in dirNames) {
      final child = node.dirs[name]!;
      final full = prefix.isEmpty ? name : '$prefix/$name';
      out.add(DiffTreeEntry.dir(fullPath: full, name: name, depth: depth, fileCount: child.count));
      if (!collapsedDirs.contains(full)) {
        walk(child, full, depth + 1);
      }
    }
    final sortedFiles = [...node.files]..sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));
    for (final f in sortedFiles) {
      out.add(DiffTreeEntry.file(file: f, depth: depth));
    }
  }

  walk(root, '', 0);
  return out;
}

/// Right-panel "Diff" tab: uncommitted changes (working tree vs HEAD) as a flat
/// list or a collapsible folder tree. Clicking a file opens a diff tab in the
/// center "Code" surface (peek or full).
class DiffPanelView extends HookWidget {
  const DiffPanelView({super.key});

  @override
  Widget build(BuildContext context) {
    final activeId = context.select<WorkspacesCubit, WorkspaceId?>((c) => c.state.activeIdOrNull);
    final path = context.select<WorkspacesCubit, String?>((c) => c.state.activeWorkspace?.path);
    final isRepo = context.select<WorkspacesCubit, bool>((c) => c.state.activeWorkspace?.repoRoot != null);

    useEffect(() {
      if (activeId != null && path != null && isRepo) {
        context.read<GitDiffCubit>().load(workspaceId: activeId, path: path);
      }
      return null;
    }, [activeId, path, isRepo]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(activeId: activeId, path: path, enabled: isRepo),
        Expanded(
          child: !isRepo || activeId == null
              ? _Message(text: Locales.Shell.DiffPanel.notRepo, icon: Symbols.commit)
              : _DiffContent(activeId: activeId, cwd: path ?? ''),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.activeId, required this.path, required this.enabled});

  final WorkspaceId? activeId;
  final String? path;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final viewMode = context.select<GitDiffCubit, DiffViewMode>((c) => c.state.diffFor(activeId).viewMode);
    final loading = context.select<GitDiffCubit, bool>((c) => c.state.diffFor(activeId).loading);

    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 1)),
      ),
      child: Row(
        children: [
          if (loading)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.brandIndigo),
            )
          else
            _IconBtn(
              keyName: 'diff_refresh',
              icon: Symbols.refresh,
              tooltip: Locales.Shell.DiffPanel.refresh,
              onTap: enabled && activeId != null && path != null
                  ? () => context.read<GitDiffCubit>().refresh(workspaceId: activeId!, path: path!)
                  : null,
            ),
          const Spacer(),
          if (enabled && activeId != null)
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ViewChip(
                    keyName: 'diff_view_flat',
                    icon: Symbols.list,
                    tooltip: Locales.Shell.DiffPanel.flatView,
                    isActive: viewMode == DiffViewMode.flat,
                    onTap: () => context.read<GitDiffCubit>().setViewMode(activeId!, DiffViewMode.flat),
                  ),
                  _ViewChip(
                    keyName: 'diff_view_tree',
                    icon: Symbols.account_tree,
                    tooltip: Locales.Shell.DiffPanel.treeView,
                    isActive: viewMode == DiffViewMode.tree,
                    onTap: () => context.read<GitDiffCubit>().setViewMode(activeId!, DiffViewMode.tree),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DiffContent extends StatelessWidget {
  const _DiffContent({required this.activeId, required this.cwd});

  final WorkspaceId activeId;
  final String cwd;

  @override
  Widget build(BuildContext context) {
    final hasFailure = context.select<GitDiffCubit, bool>((c) => c.state.diffFor(activeId).failure != null);
    final files = context.select<GitDiffCubit, List<GitDiffFile>>((c) => c.state.diffFor(activeId).files);
    final viewMode = context.select<GitDiffCubit, DiffViewMode>((c) => c.state.diffFor(activeId).viewMode);

    if (hasFailure) {
      return _Message(text: Locales.Shell.DiffPanel.loadError, icon: Symbols.error_outline);
    }
    if (files.isEmpty) {
      return _Message(text: Locales.Shell.DiffPanel.empty, icon: Symbols.check_circle);
    }
    return viewMode == DiffViewMode.flat
        ? _FlatList(activeId: activeId, cwd: cwd, files: files)
        : _TreeList(activeId: activeId, cwd: cwd, files: files);
  }
}

class _FlatList extends StatelessWidget {
  const _FlatList({required this.activeId, required this.cwd, required this.files});

  final WorkspaceId activeId;
  final String cwd;
  final List<GitDiffFile> files;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: files.length,
      itemExtent: _DiffFileRow.rowHeight,
      itemBuilder: (context, i) =>
          _DiffFileRow(activeId: activeId, cwd: cwd, file: files[i], depth: 0, showFullPath: true),
    );
  }
}

class _TreeList extends StatelessWidget {
  const _TreeList({required this.activeId, required this.cwd, required this.files});

  final WorkspaceId activeId;
  final String cwd;
  final List<GitDiffFile> files;

  @override
  Widget build(BuildContext context) {
    final collapsed = context.select<GitDiffCubit, Set<String>>((c) => c.state.diffFor(activeId).collapsedDirs);
    final rows = buildDiffTreeRows(files, collapsed);
    return ListView.builder(
      itemCount: rows.length,
      itemExtent: _DiffFileRow.rowHeight,
      itemBuilder: (context, i) {
        final row = rows[i];
        if (row.isDir) {
          return _DiffDirRow(
            activeId: activeId,
            name: row.name,
            fullPath: row.fullPath,
            depth: row.depth,
            fileCount: row.fileCount,
            collapsed: collapsed.contains(row.fullPath),
          );
        }
        return _DiffFileRow(activeId: activeId, cwd: cwd, file: row.file!, depth: row.depth, showFullPath: false);
      },
    );
  }
}

class _DiffDirRow extends StatelessWidget {
  const _DiffDirRow({
    required this.activeId,
    required this.name,
    required this.fullPath,
    required this.depth,
    required this.fileCount,
    required this.collapsed,
  });

  final WorkspaceId activeId;
  final String name;
  final String fullPath;
  final int depth;
  final int fileCount;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      onTap: () => context.read<GitDiffCubit>().toggleDir(activeId, fullPath),
      builder: (context, hover) => Container(
        height: _DiffFileRow.rowHeight,
        color: hover ? AppColors.glassHover : Colors.transparent,
        padding: EdgeInsetsDirectional.only(start: AppSpacing.sm + depth * 14.0, end: AppSpacing.sm),
        child: Row(
          children: [
            Icon(collapsed ? Symbols.chevron_right : Symbols.expand_more, size: 14, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 2),
            Icon(collapsed ? Symbols.folder : Symbols.folder_open, size: 15, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                name,
                style: AppTypography.bodyMain.copyWith(fontSize: 13),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Text(
              '$fileCount',
              style: AppTypography.terminalCode.copyWith(
                fontSize: 11,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiffFileRow extends StatelessWidget {
  const _DiffFileRow({
    required this.activeId,
    required this.cwd,
    required this.file,
    required this.depth,
    required this.showFullPath,
  });

  final WorkspaceId activeId;
  final String cwd;
  final GitDiffFile file;
  final int depth;
  final bool showFullPath;

  static const rowHeight = 24.0;

  void _open(BuildContext context, {bool pin = false}) {
    final tabs = context.read<FileTabsCubit>();
    tabs.openDiff(activeId, DiffTabRef(path: file.path, status: file.status, added: file.added, deleted: file.deleted));
    // Double-click pins the diff (mirrors the Files tree: single = preview,
    // double = fixed tab).
    if (pin) tabs.pinDiff(activeId, file.path);
    final editorView = context.read<EditorViewCubit>();
    if (editorView.state.dataFor(activeId).view != CenterView.code) {
      editorView.openPeek(activeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = showFullPath ? file.path : p.basename(file.path);
    return Hoverable(
      key: ValueKey('diff_file_${file.path}'),
      onTap: () => _open(context),
      onDoubleTap: () => _open(context, pin: true),
      builder: (context, hover) => Container(
        height: rowHeight,
        color: hover ? AppColors.glassHover : Colors.transparent,
        padding: EdgeInsetsDirectional.only(
          start: AppSpacing.sm + (showFullPath ? 0 : (depth + 1) * 14.0),
          end: AppSpacing.sm,
        ),
        child: Row(
          children: [
            _StatusBadge(status: file.status),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMain.copyWith(fontSize: 13),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 6),
            if (file.added > 0)
              Text(
                '+${file.added}',
                style: AppTypography.terminalCode.copyWith(fontSize: 11, color: AppColors.diffAdd),
              ),
            if (file.added > 0 && file.deleted > 0) const SizedBox(width: 4),
            if (file.deleted > 0)
              Text(
                '−${file.deleted}',
                style: AppTypography.terminalCode.copyWith(fontSize: 11, color: AppColors.diffDel),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final GitFileStatus status;

  @override
  Widget build(BuildContext context) {
    final (letter, color) = switch (status) {
      GitFileStatus.modified => ('M', AppColors.tertiary),
      GitFileStatus.added => ('A', AppColors.diffAdd),
      GitFileStatus.deleted => ('D', AppColors.diffDel),
      GitFileStatus.renamed => ('R', AppColors.secondary),
      GitFileStatus.untracked => ('U', AppColors.diffAdd),
    };
    return Container(
      width: 16,
      height: 16,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(AppRadii.sm)),
      child: Text(letter, style: AppTypography.terminalCode.copyWith(fontSize: 10, color: color, height: 1.0)),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.keyName, required this.icon, required this.tooltip, required this.onTap});

  final String keyName;
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Hoverable(
        onTap: onTap,
        builder: (context, hover) => Container(
          key: ValueKey(keyName),
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: hover ? AppColors.glassHover : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Icon(
            icon,
            size: 15,
            color: onTap == null ? AppColors.onSurfaceVariant.withValues(alpha: 0.35) : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _ViewChip extends StatelessWidget {
  const _ViewChip({
    required this.keyName,
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onTap,
  });

  final String keyName;
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Hoverable(
        onTap: onTap,
        builder: (context, hover) => Container(
          key: ValueKey(keyName),
          width: 26,
          height: 22,
          decoration: BoxDecoration(
            color: isActive ? AppColors.brandIndigo : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Icon(icon, size: 14, color: isActive ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 26, color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMain.copyWith(
                fontSize: 13,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
