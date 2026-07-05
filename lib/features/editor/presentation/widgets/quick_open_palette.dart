import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../shell/presentation/widgets/glass_dialog.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../cubit/editor_view_cubit.dart';
import '../cubit/file_tabs_cubit.dart';

/// Opens the ⌘P quick-open palette: a filterable list of the workspace's
/// currently *open* files (no disk scan — that is a separate future task).
/// Picking a file jumps straight to the Code view.
Future<void> showQuickOpen(BuildContext context, WorkspaceId workspaceId) {
  return showDialog<void>(
    context: context,
    barrierColor: kGlassDialogBarrier,
    builder: (_) => _QuickOpenPalette(workspaceId: workspaceId),
  );
}

class _QuickOpenPalette extends HookWidget {
  const _QuickOpenPalette({required this.workspaceId});

  final WorkspaceId workspaceId;

  void _select(BuildContext context, _OpenEntry entry) {
    final files = context.read<FileTabsCubit>();
    if (entry.isDiff) {
      files.setActiveDiff(workspaceId, entry.path);
    } else {
      files.setActiveFile(workspaceId, entry.path);
    }
    context.read<EditorViewCubit>().setView(workspaceId, CenterView.code);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final query = useState('');
    final selectedIndex = useState(0);

    useEffect(() {
      void listener() {
        final next = controller.text.trim().toLowerCase();
        if (next == query.value) return;
        query.value = next;
        selectedIndex.value = 0;
      }

      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [controller]);

    final files = context.read<FileTabsCubit>().state.filesFor(workspaceId);
    final entries = <_OpenEntry>[
      for (final path in files?.openPaths ?? const <String>[]) _OpenEntry(path, isDiff: false),
      for (final diff in files?.openDiffs ?? const <DiffTabRef>[]) _OpenEntry(diff.path, isDiff: true),
    ];
    // Match on the file name only — not the path. The repo folder (e.g.
    // "g_claude") and shared dirs are prefixes of every open file, so matching
    // the path makes a query like "claud" hit everything.
    final q = query.value;
    final filtered = q.isEmpty
        ? entries
        : entries.where((e) => p.basename(e.path).toLowerCase().contains(q)).toList();

    final clampedIndex = filtered.isEmpty ? 0 : selectedIndex.value.clamp(0, filtered.length - 1);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.only(top: 92),
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 420,
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowDown): () {
              if (filtered.isEmpty) return;
              selectedIndex.value = (clampedIndex + 1) % filtered.length;
            },
            const SingleActivator(LogicalKeyboardKey.arrowUp): () {
              if (filtered.isEmpty) return;
              selectedIndex.value = (clampedIndex - 1 + filtered.length) % filtered.length;
            },
            const SingleActivator(LogicalKeyboardKey.enter): () {
              if (filtered.isEmpty) return;
              _select(context, filtered[clampedIndex]);
            },
            const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.of(context).pop(),
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.glassBorder),
              boxShadow: const [
                BoxShadow(color: Color(0xB3000000), blurRadius: 50, spreadRadius: -20, offset: Offset(0, 30)),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Symbols.search, size: 16, color: AppColors.brandIndigo),
                      const SizedBox(width: 9),
                      Expanded(
                        child: TextField(
                          key: const ValueKey('quick_open_search_field'),
                          controller: controller,
                          autofocus: true,
                          style: AppTypography.terminalCode.copyWith(color: AppColors.onSurface, fontSize: 13),
                          decoration: InputDecoration.collapsed(
                            hintText: Locales.Editor.QuickOpen.placeholder,
                            hintStyle: AppTypography.terminalCode.copyWith(color: AppColors.outline, fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.glassHover,
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                        child: Text(
                          Locales.Editor.QuickOpen.badge,
                          style: AppTypography.navTab.copyWith(fontSize: 9.5, color: AppColors.outline),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: filtered.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
                          child: Text(
                            entries.isEmpty ? Locales.Editor.QuickOpen.empty : Locales.Editor.QuickOpen.noMatch,
                            style: AppTypography.navTab.copyWith(color: AppColors.outline),
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 0; i < filtered.length; i++)
                              _QuickOpenRow(
                                path: filtered[i].path,
                                isDiff: filtered[i].isDiff,
                                selected: i == clampedIndex,
                                onTap: () => _select(context, filtered[i]),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One open tab in the quick-open list: an editor file or a diff view.
class _OpenEntry {
  const _OpenEntry(this.path, {required this.isDiff});

  final String path;
  final bool isDiff;
}

class _QuickOpenRow extends StatelessWidget {
  const _QuickOpenRow({required this.path, required this.isDiff, required this.selected, required this.onTap});

  final String path;
  final bool isDiff;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      onTap: onTap,
      builder: (context, hover) => Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.brandIndigo.withValues(alpha: 0.14)
              : (hover ? AppColors.glassHover : Colors.transparent),
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Row(
          children: [
            Icon(
              isDiff ? Symbols.difference : Symbols.description,
              size: 14,
              color: isDiff
                  ? AppColors.secondary
                  : (selected ? AppColors.secondary : AppColors.outline),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                p.basename(path),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.terminalCode.copyWith(
                  fontSize: 11.5,
                  color: selected ? AppColors.onSurface : AppColors.onSurfaceVariant,
                ),
              ),
            ),
            if (isDiff) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.brandIndigo.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Text(
                  Locales.Editor.Diff.badge,
                  style: AppTypography.navTab.copyWith(fontSize: 9.5, color: AppColors.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
