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

/// Hosts a bounded LRU pool of [CodeView]s and switches them via [Offstage].
///
/// The preview tab slot in [FileTabsCubit.openFile] *replaces* its path when
/// a new file is opened while a preview is active — the old path leaves
/// [WorkspaceFiles.openPaths]. If the live editor pool were tied to
/// `openPaths` (its first iteration was), the displaced [CodeView] would be
/// disposed and re-built from scratch on the next visit, dominating the
/// perceived "tab switch lag" even though the file content is cached.
///
/// Strategy: keep up to [_maxLiveEditors] [CodeView]s alive per workspace
/// regardless of `openPaths`, ordered by recent use. Switching tabs (or
/// re-opening a recently displaced preview) hits the pool, flips
/// [Offstage], and preserves controller / scroll / selection state.
class FileViewer extends HookWidget {
  const FileViewer({super.key});

  static const _maxLiveEditors = 10;

  @override
  Widget build(BuildContext context) {
    // Per-workspace LRU of paths whose CodeView is currently mounted in the
    // Stack. Insertion order = LRU order (last touched is at the end).
    final pools = useRef<Map<WorkspaceId, LinkedHashSet<String>>>({});

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

            final pool =
                pools.value.putIfAbsent(activeId, () => LinkedHashSet());
            // Touch: re-insert at the tail so it becomes the MRU entry.
            pool.remove(activePath);
            pool.add(activePath);
            while (pool.length > _maxLiveEditors) {
              pool.remove(pool.first);
            }

            return Stack(
              children: [
                for (final path in pool)
                  Offstage(
                    key: ValueKey('codeview-$path'),
                    offstage: path != activePath,
                    child: TickerMode(
                      enabled: path == activePath,
                      child: CodeView(path: path),
                    ),
                  ),
              ],
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
