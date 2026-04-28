import 'package:flutter/material.dart';

class Hoverable extends StatefulWidget {
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
  State<Hoverable> createState() => _HoverableState();
}

class _HoverableState extends State<Hoverable> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.cursor,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: widget.onDoubleTap,
        child: widget.builder(context, _hover),
      ),
    );
  }
}
