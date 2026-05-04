import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:re_editor/re_editor.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:re_highlight/languages/dart.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/languages/markdown.dart';
import 'package:re_highlight/languages/xml.dart';
import 'package:re_highlight/languages/css.dart';
import 'package:re_highlight/languages/javascript.dart';
import 'package:re_highlight/languages/typescript.dart';
import 'package:re_highlight/languages/python.dart';
import 'package:re_highlight/languages/go.dart';
import 'package:re_highlight/languages/rust.dart';
import 'package:re_highlight/languages/swift.dart';
import 'package:re_highlight/languages/kotlin.dart';
import 'package:re_highlight/languages/java.dart';
import 'package:re_highlight/languages/bash.dart';
import 'package:re_highlight/languages/ini.dart';
import 'package:re_highlight/styles/github-dark.dart' as hl_theme;

import '../../../../core/di/di.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/error/failure_extensions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../workspace/data/datasources/workspace_file_watcher.dart';
import '../../domain/entities/file_content.dart';
import '../../domain/usecases/read_file.dart';
import 'code_find_panel.dart';

// ---------------------------------------------------------------------------
// Local state hierarchy (no freezed — kept inline, private)
// ---------------------------------------------------------------------------

sealed class _ViewState {
  const _ViewState();
}

class _Loading extends _ViewState {
  const _Loading();
}

class _Loaded extends _ViewState {
  const _Loaded(this.content);
  final FileContent content;
}

class _Error extends _ViewState {
  const _Error(this.failure);
  final Failure failure;
}

// ---------------------------------------------------------------------------
// Language registry — re_highlight Mode keyed by FileContent.language string
// ---------------------------------------------------------------------------

final Map<String, CodeHighlightThemeMode> _languageModes = {
  'dart': CodeHighlightThemeMode(mode: langDart),
  'json': CodeHighlightThemeMode(mode: langJson),
  'yaml': CodeHighlightThemeMode(mode: langYaml),
  'markdown': CodeHighlightThemeMode(mode: langMarkdown),
  'xml': CodeHighlightThemeMode(mode: langXml),
  'css': CodeHighlightThemeMode(mode: langCss),
  'javascript': CodeHighlightThemeMode(mode: langJavascript),
  'typescript': CodeHighlightThemeMode(mode: langTypescript),
  'python': CodeHighlightThemeMode(mode: langPython),
  'go': CodeHighlightThemeMode(mode: langGo),
  'rust': CodeHighlightThemeMode(mode: langRust),
  'swift': CodeHighlightThemeMode(mode: langSwift),
  'kotlin': CodeHighlightThemeMode(mode: langKotlin),
  'java': CodeHighlightThemeMode(mode: langJava),
  'bash': CodeHighlightThemeMode(mode: langBash),
  'ini': CodeHighlightThemeMode(mode: langIni),
};

// ---------------------------------------------------------------------------
// CodeView
// ---------------------------------------------------------------------------

class CodeView extends HookWidget {
  const CodeView({
    super.key,
    required this.path,
  });

  final String path;

  @override
  Widget build(BuildContext context) {
    final state = useState<_ViewState>(const _Loading());
    final reloadTick = useState(0);
    final talker = getIt<Talker>();

    useEffect(() {
      var cancelled = false;
      state.value = const _Loading();
      getIt<ReadFile>().call(path: path).then((either) {
        if (cancelled) return;
        either.fold(
          (failure) {
            talker.debug('[cv] initial FAILED $path: $failure');
            state.value = _Error(failure);
          },
          (content) => state.value = _Loaded(content),
        );
      });
      return () => cancelled = true;
    }, [path]);

    // Soft reload on watcher fire: keep the previous _Loaded visible during
    // the re-read so the editor does not flash to a spinner on every save.
    useEffect(() {
      if (reloadTick.value == 0) return null;
      var cancelled = false;
      getIt<ReadFile>().call(path: path).then((either) {
        if (cancelled) return;
        either.fold(
          (failure) {
            talker.debug('[cv] reload FAILED $path: $failure');
            state.value = _Error(failure);
          },
          (content) => state.value = _Loaded(content),
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

    return switch (state.value) {
      _Loading() => const Center(
        child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      _Error(:final failure) => _ErrorView(failure: failure),
      // Key by path only: changing the key on every save would unmount the
      // editor and lose cursor position / scroll / selection. The inner
      // controller swap is handled via useMemoized on content.content.
      _Loaded(:final content) => _HighlightedView(
        key: ValueKey('hv-${content.path}'),
        content: content,
      ),
    };
  }
}

// ---------------------------------------------------------------------------
// Error view
// ---------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    final f = failure;
    final String msg;
    final String? caption;
    if (f is ValidationFailure) {
      msg = _mapValidationMessage(f.message);
      caption = null;
    } else {
      msg = Locales.Editor.fileLoadError;
      caption = f.toUserMessage();
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Symbols.error_outline, color: AppColors.error, size: 32),
          const SizedBox(height: 8),
          Text(msg, style: AppTypography.bodyMain.copyWith(color: AppColors.onSurfaceVariant)),
          if (caption != null)
            Text(
              caption,
              style: AppTypography.bodyMain.copyWith(
                fontSize: 11,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
    );
  }

  String _mapValidationMessage(String msg) {
    if (msg.contains('file too large')) return Locales.Editor.fileTooLarge;
    if (msg.contains('binary')) return Locales.Editor.binaryFile;
    return Locales.Editor.fileLoadError;
  }
}

// ---------------------------------------------------------------------------
// Highlighted view — read-only re_editor with line numbers
// ---------------------------------------------------------------------------

class _HighlightedView extends HookWidget {
  const _HighlightedView({super.key, required this.content});

  final FileContent content;

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(
      () => CodeLineEditingController.fromText(content.content),
      [content.path],
    );
    useEffect(() => controller.dispose, [controller]);

    useEffect(() {
      if (controller.text != content.content) {
        controller.text = content.content;
      }
      return null;
    }, [content.content]);

    final findController = useMemoized(() => CodeFindController(controller), [controller]);
    useEffect(() => findController.dispose, [findController]);

    final lang = content.language;
    final languageMode = lang != null ? _languageModes[lang] : null;

    final baseStyle = AppTypography.terminalCode.copyWith(color: AppColors.onSurface);

    return Container(
      color: AppColors.surface,
      child: CodeEditor(
        controller: controller,
        findController: findController,
        readOnly: true,
        style: CodeEditorStyle(
          backgroundColor: AppColors.surface,
          textColor: AppColors.onSurface,
          fontFamily: baseStyle.fontFamily,
          fontSize: baseStyle.fontSize,
          codeTheme: languageMode == null
              ? null
              : CodeHighlightTheme(
                  languages: {lang!: languageMode},
                  theme: hl_theme.githubDarkTheme,
                ),
        ),
        indicatorBuilder: (context, editingController, chunkController, notifier) {
          return Row(
            children: [
              DefaultCodeLineNumber(
                controller: editingController,
                notifier: notifier,
                textStyle: baseStyle.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
              ),
              DefaultCodeChunkIndicator(width: 16, controller: chunkController, notifier: notifier),
            ],
          );
        },
        findBuilder: (context, controller, readOnly) => CodeFindPanel(controller: controller),
        scrollbarBuilder: (context, child, details) => Scrollbar(
          controller: details.controller,
          child: child,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
    );
  }
}
