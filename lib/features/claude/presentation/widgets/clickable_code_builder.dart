import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

import 'clickable_code_resolver.dart';

typedef PathTapHandler = void Function(String absPath);

/// Markdown element builder for the inline `code` tag that turns spans
/// resolving to a workspace file into a clickable widget. Block code
/// (rendered inside `<pre>`, multi-line content) falls back to the default
/// inline rendering by returning `null`.
class ClickableCodeBuilder extends MarkdownElementBuilder {
  ClickableCodeBuilder({required this.cwd, required this.basenameIndex, required this.onTapPath});

  final String cwd;
  final Map<String, List<String>> basenameIndex;
  final PathTapHandler onTapPath;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final content = element.textContent;
    if (content.contains('\n')) return null;

    final resolved = resolveCodePath(content: content, cwd: cwd, basenameIndex: basenameIndex);
    if (resolved == null) return null;

    return _ClickableInlineCode(label: content, style: preferredStyle, onTap: () => onTapPath(resolved));
  }
}

class _ClickableInlineCode extends HookWidget {
  const _ClickableInlineCode({required this.label, required this.onTap, this.style});

  final String label;
  final TextStyle? style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hovered = useState(false);
    final base = style ?? const TextStyle();
    final effective = base.copyWith(
      decoration: hovered.value ? TextDecoration.underline : null,
      decorationColor: base.color,
    );
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => hovered.value = true,
      onExit: (_) => hovered.value = false,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Text.rich(TextSpan(text: label, style: effective)),
      ),
    );
  }
}
