import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:re_highlight/re_highlight.dart';
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
import 'package:re_highlight/styles/atom-one-dark.dart' as hl_theme;

import '../../../../core/di/di.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/file_content.dart';
import '../../domain/usecases/read_file.dart';

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
// Shared highlight instance with all supported languages registered once
// ---------------------------------------------------------------------------

final _hl = Highlight()
  ..registerLanguage('dart', langDart)
  ..registerLanguage('json', langJson)
  ..registerLanguage('yaml', langYaml)
  ..registerLanguage('markdown', langMarkdown)
  ..registerLanguage('xml', langXml)
  ..registerLanguage('css', langCss)
  ..registerLanguage('javascript', langJavascript)
  ..registerLanguage('typescript', langTypescript)
  ..registerLanguage('python', langPython)
  ..registerLanguage('go', langGo)
  ..registerLanguage('rust', langRust)
  ..registerLanguage('swift', langSwift)
  ..registerLanguage('kotlin', langKotlin)
  ..registerLanguage('java', langJava)
  ..registerLanguage('bash', langBash)
  ..registerLanguage('ini', langIni);

// ---------------------------------------------------------------------------
// CodeView
// ---------------------------------------------------------------------------

class CodeView extends StatefulWidget {
  const CodeView({super.key, required this.path});

  final String path;

  @override
  State<CodeView> createState() => _CodeViewState();
}

class _CodeViewState extends State<CodeView> {
  _ViewState _state = const _Loading();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(CodeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      setState(() => _state = const _Loading());
      _load();
    }
  }

  void _load() {
    getIt<ReadFile>().call(path: widget.path).then((either) {
      if (!mounted) return;
      setState(() {
        _state = either.fold(_Error.new, _Loaded.new);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (_state) {
      _Loading() => const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      _Error(:final failure) => _ErrorView(failure: failure),
      _Loaded(:final content) => _HighlightedView(content: content),
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
    final msg = failure is ValidationFailure
        ? _mapValidationMessage((failure as ValidationFailure).message)
        : 'editor.fileLoadError'.tr();

    final caption = failure is ValidationFailure ? null : (failure as dynamic).message as String?;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Symbols.error_outline, color: AppColors.error, size: 32),
          const SizedBox(height: 8),
          Text(msg,
              style: AppTypography.bodyMain
                  .copyWith(color: AppColors.onSurfaceVariant)),
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
    if (msg.contains('file too large')) return 'editor.fileTooLarge'.tr();
    if (msg.contains('binary')) return 'editor.binaryFile'.tr();
    return 'editor.fileLoadError'.tr();
  }
}

// ---------------------------------------------------------------------------
// Highlighted view
// ---------------------------------------------------------------------------

class _HighlightedView extends StatelessWidget {
  const _HighlightedView({required this.content});

  final FileContent content;

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppTypography.terminalCode
        .copyWith(color: AppColors.onSurface);

    TextSpan span;
    try {
      final lang = content.language;
      final result = lang != null
          ? _hl.highlight(
              code: content.content,
              language: lang,
              ignoreIllegals: true,
            )
          : null;

      if (result != null) {
        final renderer = TextSpanRenderer(baseStyle, hl_theme.atomOneDarkTheme);
        result.render(renderer);
        span = renderer.span ??
            TextSpan(text: content.content, style: baseStyle);
      } else {
        span = TextSpan(text: content.content, style: baseStyle);
      }
    } catch (_) {
      span = TextSpan(text: content.content, style: baseStyle);
    }

    return Container(
      color: AppColors.surface,
      child: Scrollbar(
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText.rich(span),
            ),
          ),
        ),
      ),
    );
  }
}
