import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../core/di/di.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../workspace/data/datasources/workspace_file_watcher.dart';
import '../../domain/entities/file_content.dart';
import '../../domain/usecases/read_file.dart';
import 'code_view.dart';

// ---------------------------------------------------------------------------
// Local state
// ---------------------------------------------------------------------------

sealed class _MdState {
  const _MdState();
}

class _MdLoading extends _MdState {
  const _MdLoading();
}

class _MdLoaded extends _MdState {
  const _MdLoaded(this.content);
  final FileContent content;
}

class _MdError extends _MdState {
  const _MdError(this.failure);
  final Failure failure;
}

// ---------------------------------------------------------------------------
// MarkdownView
// ---------------------------------------------------------------------------

class MarkdownView extends HookWidget {
  const MarkdownView({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final viewState = useState<_MdState>(const _MdLoading());
    final reloadTick = useState(0);
    final showRendered = useState(true);
    final talker = getIt<Talker>();

    useEffect(() {
      var cancelled = false;
      viewState.value = const _MdLoading();
      getIt<ReadFile>().call(path: path).then((either) {
        if (cancelled) return;
        either.fold(
          (f) => viewState.value = _MdError(f),
          (c) => viewState.value = _MdLoaded(c),
        );
      });
      return () => cancelled = true;
    }, [path]);

    useEffect(() {
      if (reloadTick.value == 0) return null;
      var cancelled = false;
      getIt<ReadFile>().call(path: path).then((either) {
        if (cancelled) return;
        either.fold(
          (f) {
            talker.debug('[md] reload FAILED $path: $f');
            viewState.value = _MdError(f);
          },
          (c) => viewState.value = _MdLoaded(c),
        );
      });
      return () => cancelled = true;
    }, [reloadTick.value]);

    useEffect(() {
      Timer? debounce;
      final sub = getIt<WorkspaceFileWatcher>().watchFile(path).listen((event) {
        if (event is FileSystemDeleteEvent) return;
        debounce?.cancel();
        debounce = Timer(const Duration(milliseconds: 150), () {
          reloadTick.value = reloadTick.value + 1;
        });
      });
      return () {
        debounce?.cancel();
        sub.cancel();
      };
    }, [path]);

    return switch (viewState.value) {
      _MdLoading() => const Center(
          child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      _MdError(:final failure) => _MdErrorView(failure: failure),
      _MdLoaded(:final content) => _MdContent(
          key: ValueKey('md-${content.path}'),
          content: content,
          showRendered: showRendered.value,
          onToggle: () => showRendered.value = !showRendered.value,
        ),
    };
  }
}

// ---------------------------------------------------------------------------
// Content view with toggle overlay
// ---------------------------------------------------------------------------

class _MdContent extends StatelessWidget {
  const _MdContent({
    super.key,
    required this.content,
    required this.showRendered,
    required this.onToggle,
  });

  final FileContent content;
  final bool showRendered;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (showRendered)
          _RenderedView(content: content)
        else
          CodeView(path: content.path),
        Positioned(
          top: 8,
          right: 12,
          child: _ToggleButton(
            showRendered: showRendered,
            onToggle: onToggle,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Rendered markdown
// ---------------------------------------------------------------------------

class _RenderedView extends StatelessWidget {
  const _RenderedView({required this.content});

  final FileContent content;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Markdown(
        data: content.content,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: AppTypography.bodyMain,
          code: AppTypography.terminalCode.copyWith(
            color: AppColors.primary,
            backgroundColor: AppColors.surfaceContainerHigh,
          ),
          codeblockDecoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(6),
          ),
          blockquoteDecoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: AppColors.outlineVariant, width: 3),
            ),
          ),
          h1: AppTypography.bodyMain.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
          h2: AppTypography.bodyMain.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
          h3: AppTypography.bodyMain.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
          horizontalRuleDecoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Toggle button (ghost, overlays top-right)
// ---------------------------------------------------------------------------

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({required this.showRendered, required this.onToggle});

  final bool showRendered;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final label = showRendered
        ? Locales.Editor.Markdown.toggleSource
        : Locales.Editor.Markdown.toggleRendered;

    return Tooltip(
      message: label,
      child: Material(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                Icon(
                  showRendered ? Symbols.code : Symbols.visibility,
                  size: 14,
                  color: AppColors.onSurfaceVariant,
                ),
                Text(
                  label,
                  style: AppTypography.navTab.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error view
// ---------------------------------------------------------------------------

class _MdErrorView extends StatelessWidget {
  const _MdErrorView({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Symbols.error_outline, color: AppColors.error, size: 32),
          const SizedBox(height: 8),
          Text(
            Locales.Editor.fileLoadError,
            style: AppTypography.bodyMain.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
