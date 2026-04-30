import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' as p;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../cubit/file_tabs_cubit.dart';

class OpenFilesButton extends StatelessWidget {
  const OpenFilesButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      onTap: () => _showPopover(context),
      builder: (context, hover) => Container(
        width: 40,
        height: AppSpacing.toolbarHeight,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: hover ? AppColors.glassHover : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Tooltip(
          message: 'editor.openFiles.tooltip'.tr(),
          child: const Icon(
            Symbols.list,
            size: 18,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  void _showPopover(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;
    final position = renderBox.localToGlobal(
      renderBox.size.bottomLeft(Offset.zero),
      ancestor: overlay,
    );
    final workspacesCubit = context.read<WorkspacesCubit>();
    final fileTabsCubit = context.read<FileTabsCubit>();
    showDialog<void>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<WorkspacesCubit>.value(value: workspacesCubit),
          BlocProvider<FileTabsCubit>.value(value: fileTabsCubit),
        ],
        child: _OpenFilesPopover(anchor: position),
      ),
    );
  }
}

class _OpenFilesPopover extends HookWidget {
  const _OpenFilesPopover({required this.anchor});

  final Offset anchor;

  @override
  Widget build(BuildContext context) {
    final searchCtrl = useTextEditingController();
    final query = useState('');

    useEffect(() {
      void listener() {
        final q = searchCtrl.text.toLowerCase().trim();
        if (q == query.value) return;
        query.value = q;
      }
      searchCtrl.addListener(listener);
      return () => searchCtrl.removeListener(listener);
    }, [searchCtrl]);

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
        Positioned(
          left: anchor.dx,
          top: anchor.dy + 4,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(AppRadii.md),
            color: AppColors.surfaceContainerLow,
            child: SizedBox(
              width: 320,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: TextField(
                        key: const ValueKey('open_files_search'),
                        controller: searchCtrl,
                        autofocus: true,
                        style: AppTypography.bodyMain.copyWith(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'editor.openFiles.searchHint'.tr(),
                          hintStyle: AppTypography.bodyMain.copyWith(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                          prefixIcon: const Icon(Symbols.search, size: 16),
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                            borderSide: const BorderSide(
                                color: AppColors.outlineVariant, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                            borderSide: const BorderSide(
                                color: AppColors.outlineVariant, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                            borderSide: const BorderSide(
                                color: AppColors.brandIndigo, width: 1),
                          ),
                        ),
                      ),
                    ),
                    const Divider(
                        height: 1, color: AppColors.outlineVariant),
                    Flexible(child: _OpenFilesList(query: query.value)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OpenFilesList extends StatelessWidget {
  const _OpenFilesList({required this.query});

  final String query;

  bool _matches(String path, String workspacePath) {
    if (query.isEmpty) return true;
    final filename = p.basename(path).toLowerCase();
    if (filename.contains(query)) return true;
    final relativePath = p.relative(path, from: workspacePath).toLowerCase();
    return relativePath.contains(query);
  }

  @override
  Widget build(BuildContext context) {
    final active = context.select<WorkspacesCubit, Workspace?>(
      (c) => c.state.activeWorkspace,
    );
    if (active == null) {
      return _placeholder('editor.openFiles.empty'.tr());
    }
    final files = context.select<FileTabsCubit, WorkspaceFiles?>(
      (c) => c.state.filesFor(active.id),
    );
    final paths = files?.openPaths ?? const <String>[];
    if (paths.isEmpty) {
      return _placeholder('editor.openFiles.empty'.tr());
    }
    final filtered =
        paths.where((path) => _matches(path, active.path)).toList();
    if (filtered.isEmpty) {
      return _placeholder('editor.openFiles.noMatches'.tr());
    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final path = filtered[index];
        return _OpenFileRow(
          workspaceId: active.id,
          path: path,
          workspacePath: active.path,
          isActive: files?.activePath == path,
          isPreview: files?.previewPath == path,
        );
      },
    );
  }

  Widget _placeholder(String message) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: Text(
            message,
            style: AppTypography.bodyMain.copyWith(
              fontSize: 13,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
}

class _OpenFileRow extends StatelessWidget {
  const _OpenFileRow({
    required this.workspaceId,
    required this.path,
    required this.workspacePath,
    required this.isActive,
    required this.isPreview,
  });

  final WorkspaceId workspaceId;
  final String path;
  final String workspacePath;
  final bool isActive;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    final filename = p.basename(path);
    final relative = p.relative(path, from: workspacePath);
    return Hoverable(
      onTap: () {
        context.read<FileTabsCubit>().setActiveFile(workspaceId, path);
        Navigator.of(context).pop();
      },
      builder: (context, hover) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        color: isActive
            ? AppColors.surface
            : hover
                ? AppColors.glassHover
                : Colors.transparent,
        child: Row(
          children: [
            Icon(
              Symbols.description,
              size: 14,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    filename,
                    style: AppTypography.bodyMain.copyWith(
                      fontSize: 13,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w400,
                      fontStyle:
                          isPreview ? FontStyle.italic : FontStyle.normal,
                      color: AppColors.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    relative,
                    style: AppTypography.bodyMain.copyWith(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant
                          .withValues(alpha: 0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
