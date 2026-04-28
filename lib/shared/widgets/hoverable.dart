import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Hoverable extends HookWidget {
  const Hoverable({
    super.key,
    required this.builder,
    this.cursor = SystemMouseCursors.click,
    this.onTap,
    this.onDoubleTap,
  });

  final Widget Function(BuildContext context, bool hover) builder;
  final MouseCursor cursor;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  @override
  Widget build(BuildContext context) {
    final hover = useState(false);
    return MouseRegion(
      cursor: cursor,
      onEnter: (_) => hover.value = true,
      onExit: (_) => hover.value = false,
      child: GestureDetector(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        child: builder(context, hover.value),
      ),
    );
  }
}
