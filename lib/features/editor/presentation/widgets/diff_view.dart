import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' as p;

import '../../../../core/di/di.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../../../git/domain/entities/file_diff.dart';
import '../../../git/domain/entities/git_diff_file.dart';
import '../../../git/domain/usecases/read_file_diff.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../cubit/file_tabs_cubit.dart';

enum _DiffLayout { unified, split }

sealed class _DiffState {
  const _DiffState();
}

class _DiffLoading extends _DiffState {
  const _DiffLoading();
}

class _DiffLoaded extends _DiffState {
  const _DiffLoaded(this.diff);
  final FileDiff diff;
}

class _DiffError extends _DiffState {
  const _DiffError(this.failure);
  final Failure failure;
}

/// Read-only viewer for a single file's git diff (working tree vs HEAD).
/// Unified is the default layout; Split is a side-by-side refinement.
class DiffView extends HookWidget {
  const DiffView({super.key, required this.workspaceId, required this.ref});

  final WorkspaceId workspaceId;
  final DiffTabRef ref;

  @override
  Widget build(BuildContext context) {
    final layout = useState(_DiffLayout.unified);
    final state = useState<_DiffState>(const _DiffLoading());

    final cwd = context.select<WorkspacesCubit, String?>((c) => c.state.activeWorkspace?.path);

    useEffect(() {
      var cancelled = false;
      state.value = const _DiffLoading();
      if (cwd == null) {
        state.value = const _DiffError(UnexpectedFailure('no workspace path'));
        return null;
      }
      final file = GitDiffFile(path: ref.path, status: ref.status, added: ref.added, deleted: ref.deleted);
      getIt<ReadFileDiff>().call(cwd: cwd, file: file).then((either) {
        if (cancelled) return;
        either.fold((f) => state.value = _DiffError(f), (d) => state.value = _DiffLoaded(d));
      });
      return () => cancelled = true;
      // added/deleted are in the deps so a re-open of the same path after the
      // file changed (counts differ) re-reads the diff body, not just the header.
    }, [cwd, ref.path, ref.status, ref.added, ref.deleted]);

    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(ref: ref, layout: layout.value, onLayout: (l) => layout.value = l),
          Expanded(
            child: switch (state.value) {
              _DiffLoading() => const Center(
                child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              _DiffError() => _Message(text: Locales.Editor.Diff.loadError, icon: Symbols.error_outline),
              _DiffLoaded(:final diff) => _DiffBody(diff: diff, layout: layout.value),
            },
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.ref, required this.layout, required this.onLayout});

  final DiffTabRef ref;
  final _DiffLayout layout;
  final ValueChanged<_DiffLayout> onLayout;

  @override
  Widget build(BuildContext context) {
    final dir = p.dirname(ref.path);
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 1)),
      ),
      child: Row(
        children: [
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  if (dir != '.' && dir.isNotEmpty)
                    TextSpan(
                      text: '$dir/',
                      style: AppTypography.navTab.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
                    ),
                  TextSpan(
                    text: p.basename(ref.path),
                    style: AppTypography.navTab.copyWith(color: AppColors.onSurface),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          if (ref.added > 0)
            Text('+${ref.added}', style: AppTypography.terminalCode.copyWith(fontSize: 12, color: AppColors.diffAdd)),
          if (ref.added > 0 && ref.deleted > 0) const SizedBox(width: 6),
          if (ref.deleted > 0)
            Text('−${ref.deleted}', style: AppTypography.terminalCode.copyWith(fontSize: 12, color: AppColors.diffDel)),
          const Spacer(),
          _LayoutToggle(layout: layout, onLayout: onLayout),
        ],
      ),
    );
  }
}

class _LayoutToggle extends StatelessWidget {
  const _LayoutToggle({required this.layout, required this.onLayout});

  final _DiffLayout layout;
  final ValueChanged<_DiffLayout> onLayout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleChip(
            keyName: 'diff_layout_unified',
            label: Locales.Editor.Diff.unified,
            isActive: layout == _DiffLayout.unified,
            onTap: () => onLayout(_DiffLayout.unified),
          ),
          _ToggleChip(
            keyName: 'diff_layout_split',
            label: Locales.Editor.Diff.split,
            isActive: layout == _DiffLayout.split,
            onTap: () => onLayout(_DiffLayout.split),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({required this.keyName, required this.label, required this.isActive, required this.onTap});

  final String keyName;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = isActive ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant;
    return Hoverable(
      onTap: onTap,
      builder: (context, hover) => Container(
        key: ValueKey(keyName),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: isActive ? AppColors.brandIndigo : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Text(label, style: AppTypography.navTab.copyWith(fontSize: 11, color: fg)),
      ),
    );
  }
}

class _DiffBody extends StatelessWidget {
  const _DiffBody({required this.diff, required this.layout});

  final FileDiff diff;
  final _DiffLayout layout;

  @override
  Widget build(BuildContext context) {
    if (diff.isBinary) {
      return _Message(text: Locales.Editor.Diff.binary, icon: Symbols.data_object);
    }
    if (diff.hunks.isEmpty) {
      return _Message(text: Locales.Editor.Diff.empty, icon: Symbols.check_circle);
    }
    return switch (layout) {
      _DiffLayout.unified => _UnifiedBody(diff: diff),
      _DiffLayout.split => _SplitBody(diff: diff),
    };
  }
}

const _gutterWidth = 44.0;
const _lineVPad = 1.0;

TextStyle get _codeStyle =>
    AppTypography.terminalCode.copyWith(fontSize: 12.5, color: AppColors.onSurface, height: 1.5);

TextStyle get _gutterStyle =>
    AppTypography.terminalCode.copyWith(fontSize: 11.5, color: AppColors.onSurfaceVariant.withValues(alpha: 0.4));

Color _bgFor(DiffLineType type) => switch (type) {
  DiffLineType.addition => AppColors.diffAdd.withValues(alpha: 0.14),
  DiffLineType.deletion => AppColors.diffDel.withValues(alpha: 0.14),
  _ => Colors.transparent,
};

String _signFor(DiffLineType type) => switch (type) {
  DiffLineType.addition => '+',
  DiffLineType.deletion => '−',
  _ => ' ',
};

class _UnifiedBody extends StatelessWidget {
  const _UnifiedBody({required this.diff});

  final FileDiff diff;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (final hunk in diff.hunks) {
      rows.add(_HunkHeaderRow(header: hunk.header));
      for (final line in hunk.lines) {
        rows.add(
          _UnifiedLineRow(
            oldNo: line.oldLineNo,
            newNo: line.newLineNo,
            sign: _signFor(line.type),
            content: line.content,
            bg: _bgFor(line.type),
          ),
        );
      }
    }
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicWidth(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
        ),
      ),
    );
  }
}

class _UnifiedLineRow extends StatelessWidget {
  const _UnifiedLineRow({
    required this.oldNo,
    required this.newNo,
    required this.sign,
    required this.content,
    required this.bg,
  });

  final int? oldNo;
  final int? newNo;
  final String sign;
  final String content;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: bg,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: _lineVPad),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: _gutterWidth,
              child: Text(oldNo?.toString() ?? '', textAlign: TextAlign.right, style: _gutterStyle),
            ),
            SizedBox(
              width: _gutterWidth,
              child: Text(newNo?.toString() ?? '', textAlign: TextAlign.right, style: _gutterStyle),
            ),
            const SizedBox(width: 10),
            Text(sign, style: _codeStyle),
            const SizedBox(width: 4),
            Text(content, style: _codeStyle),
            const SizedBox(width: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _HunkHeaderRow extends StatelessWidget {
  const _HunkHeaderRow({required this.header});

  final String header;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      child: Text(
        header.isEmpty ? '@@' : header,
        style: AppTypography.terminalCode.copyWith(fontSize: 11.5, color: AppColors.secondary),
      ),
    );
  }
}

/// Basic side-by-side layout: deletions on the left, additions on the right,
/// context on both. Consecutive del/add are stacked within their column.
class _SplitBody extends StatelessWidget {
  const _SplitBody({required this.diff});

  final FileDiff diff;

  @override
  Widget build(BuildContext context) {
    final left = <Widget>[];
    final right = <Widget>[];

    void pad(List<Widget> a, List<Widget> b) {
      while (a.length < b.length) {
        a.add(const _SplitLine(no: null, content: '', bg: Colors.transparent));
      }
    }

    for (final hunk in diff.hunks) {
      left.add(_HunkHeaderRow(header: hunk.header));
      right.add(_HunkHeaderRow(header: hunk.header));
      for (final line in hunk.lines) {
        switch (line.type) {
          case DiffLineType.context:
            pad(left, right);
            pad(right, left);
            left.add(_SplitLine(no: line.oldLineNo, content: line.content, bg: Colors.transparent));
            right.add(_SplitLine(no: line.newLineNo, content: line.content, bg: Colors.transparent));
          case DiffLineType.deletion:
            left.add(_SplitLine(no: line.oldLineNo, content: line.content, bg: _bgFor(DiffLineType.deletion)));
          case DiffLineType.addition:
            right.add(_SplitLine(no: line.newLineNo, content: line.content, bg: _bgFor(DiffLineType.addition)));
          case DiffLineType.hunkHeader:
            break;
        }
      }
      pad(left, right);
      pad(right, left);
    }

    return SingleChildScrollView(
      // A left border on the right column separates the panes without a
      // VerticalDivider, which would need a bounded height (this Row sits in an
      // unbounded-height scroll view).
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _SplitColumn(rows: left)),
          Expanded(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: AppColors.outlineVariant, width: 1)),
              ),
              child: _SplitColumn(rows: right),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitColumn extends StatelessWidget {
  const _SplitColumn({required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicWidth(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
      ),
    );
  }
}

class _SplitLine extends StatelessWidget {
  const _SplitLine({required this.no, required this.content, required this.bg});

  final int? no;
  final String content;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: bg,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: _lineVPad),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: _gutterWidth,
              child: Text(no?.toString() ?? '', textAlign: TextAlign.right, style: _gutterStyle),
            ),
            const SizedBox(width: 10),
            Text(content, style: _codeStyle),
            const SizedBox(width: AppSpacing.md),
          ],
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
          Icon(icon, size: 28, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 8),
          Text(
            text,
            style: AppTypography.bodyMain.copyWith(
              fontSize: 13,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
