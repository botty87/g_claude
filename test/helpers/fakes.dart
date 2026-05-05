import 'package:g_claude/features/workspace/domain/entities/workspace.dart';

/// Factory for [Workspace] with sensible defaults so tests stay terse.
///
/// Override only the fields under test to keep the contract under test
/// front-and-center.
Workspace makeWorkspace({
  String? id,
  String? path,
  String? name,
  String? claudeMd,
  DateTime? openedAt,
}) {
  final resolvedPath = path ?? '/tmp/ws_${id ?? 'a'}';
  return Workspace(
    id: id ?? resolvedPath,
    path: resolvedPath,
    name: name ?? 'ws',
    claudeMd: claudeMd,
    openedAt: openedAt ?? DateTime.utc(2026, 1, 1),
  );
}
