import 'package:flutter/widgets.dart';

/// Computes a [RelativeRect] anchored just below a widget's [RenderBox].
/// Used by header pickers to position popup menus.
RelativeRect relativeRectBelow(RenderBox box, {double gap = 4}) {
  final offset = box.localToGlobal(Offset.zero);
  final size = box.size;
  return RelativeRect.fromLTRB(
    offset.dx,
    offset.dy + size.height + gap,
    offset.dx + size.width,
    offset.dy + size.height + gap,
  );
}
