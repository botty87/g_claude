import 'dart:collection';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../cubit/file_tabs_cubit.dart';
import 'code_view.dart';

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
    return BlocSelector<WorkspacesCubit, WorkspacesState, WorkspaceId?>(
      selector: (state) => state.activeIdOrNull,
      builder: (context, activeId) {
        if (activeId == null) {
          return const _EmptyState();
        }
        return BlocSelector<FileTabsCubit, FileTabsState, String?>(
          selector: (state) => state.filesFor(activeId)?.activePath,
          builder: (context, activePath) {
            if (activePath == null) {
              return const _EmptyState();
            }
            return _PooledStack(activeId: activeId, activePath: activePath);
          },
        );
      },
    );
  }
}

class _PooledStack extends HookWidget {
  const _PooledStack({required this.activeId, required this.activePath});

  final WorkspaceId activeId;
  final String activePath;

  static const _maxLiveEditors = 10;
  static const _maxLiveWorkspaces = 3;

  @override
  Widget build(BuildContext context) {
    final pools = useRef<LinkedHashMap<WorkspaceId, LinkedHashSet<String>>>(LinkedHashMap());

    final paths = useMemoized<List<String>>(() {
      final map = pools.value;
      // ignore: prefer_collection_literals
      final pool = map.remove(activeId) ?? LinkedHashSet<String>();
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
    }, [activeId, activePath]);

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
            key: ValueKey('codeview-$path'),
            child: CodeView(path: path),
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
          'editor.noFileOpen'.tr(),
          style: AppTypography.bodyMain.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
