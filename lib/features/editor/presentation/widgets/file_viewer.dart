import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../cubit/file_tabs_cubit.dart';
import 'file_preview.dart';

/// Bounded LRU pool of mounted [CodeView]s, switched via [IndexedStack].
///
/// Why a pool decoupled from `openPaths`: when a preview tab is replaced (its
/// path is swapped in `WorkspaceFiles.openPaths`), the displaced [CodeView]
/// would otherwise be disposed and re-built on next visit, dominating the
/// perceived "tab switch lag" even though the file content is cached. The
/// pool keeps up to [_maxLiveEditors] views alive per workspace and caps the
/// number of workspaces it tracks via [_maxLiveWorkspaces] so memory does not
/// grow unbounded as the user moves across workspaces.
class FileViewer extends StatelessWidget {
  const FileViewer({super.key});

  @override
  Widget build(BuildContext context) {
    final activeId = context.select<WorkspacesCubit, WorkspaceId?>(
      (c) => c.state.activeIdOrNull,
    );
    final activePath = context.select<FileTabsCubit, String?>(
      (c) => activeId == null ? null : c.state.filesFor(activeId)?.activePath,
    );
    final openPaths = context.select<FileTabsCubit, List<String>>(
      (c) => activeId == null
          ? const []
          : (c.state.filesFor(activeId)?.openPaths ?? const []),
    );
    if (activeId == null || activePath == null) {
      return const _EmptyState();
    }
    return _PooledStack(
      activeId: activeId,
      activePath: activePath,
      openPaths: openPaths,
    );
  }
}

class _PooledStack extends HookWidget {
  const _PooledStack({
    required this.activeId,
    required this.activePath,
    required this.openPaths,
  });

  final WorkspaceId activeId;
  final String activePath;
  final List<String> openPaths;

  static const _maxLiveEditors = 10;
  static const _maxLiveWorkspaces = 3;

  @override
  Widget build(BuildContext context) {
    final pools = useRef<LinkedHashMap<WorkspaceId, LinkedHashSet<String>>>(LinkedHashMap());

    final openSet = openPaths.toSet();
    final paths = useMemoized<List<String>>(() {
      final map = pools.value;
      // ignore: prefer_collection_literals
      final pool = map.remove(activeId) ?? LinkedHashSet<String>();
      // Drop pool entries for files that are no longer open in any tab so
      // a close+reopen forces a fresh CodeView mount (and re-read from disk).
      pool.removeWhere((p) => !openSet.contains(p));
      pool.remove(activePath);
      pool.add(activePath);
      while (pool.length > _maxLiveEditors) {
        pool.remove(pool.first);
      }
      map[activeId] = pool;
      while (map.length > _maxLiveWorkspaces) {
        map.remove(map.keys.first);
      }
      return pool.toList(growable: false);
    }, [activeId, activePath, openSet.length]);

    if (paths.isEmpty) {
      return const _EmptyState();
    }
    final activeIndex = paths.indexOf(activePath);

    return IndexedStack(
      index: activeIndex >= 0 ? activeIndex : 0,
      sizing: StackFit.expand,
      children: [
        for (final path in paths)
          KeyedSubtree(
            key: ValueKey('preview-$path'),
            child: FilePreview(path: path),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: Text(
          Locales.Editor.noFileOpen,
          style: AppTypography.bodyMain.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
