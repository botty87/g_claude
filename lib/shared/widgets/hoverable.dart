import 'package:flutter/gestures.dart' show kDoubleTapTimeout;
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
    // Manual double-tap detection so onTap fires immediately. GestureDetector
    // with both onTap+onDoubleTap forces a kDoubleTapTimeout (~300ms) wait
    // before firing onTap to disambiguate, which is perceived as lag on
    // preview tabs (the only ones wiring onDoubleTap, for pin-on-double-click).
    final lastTap = useRef<DateTime?>(null);

    void handleTap() {
      if (onDoubleTap != null) {
        final now = DateTime.now();
        final last = lastTap.value;
        if (last != null && now.difference(last) <= kDoubleTapTimeout) {
          lastTap.value = null;
          onDoubleTap!.call();
          return;
        }
        lastTap.value = now;
      }
      onTap?.call();
    }

    return MouseRegion(
      cursor: cursor,
      onEnter: (_) => hover.value = true,
      onExit: (_) => hover.value = false,
      child: GestureDetector(
        onTap: (onTap == null && onDoubleTap == null) ? null : handleTap,
        child: builder(context, hover.value),
      ),
    );
  }
}
