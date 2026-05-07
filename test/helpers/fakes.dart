import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/slash_commands/domain/entities/slash_command.dart';
import 'package:g_claude/features/slash_commands/domain/entities/slash_command_source.dart';
import 'package:g_claude/features/workspace/domain/entities/workspace.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Factory for [Workspace] with sensible defaults so tests stay terse.
///
/// Override only the fields under test to keep the contract under test
/// front-and-center.
Workspace makeWorkspace({String? id, String? path, String? name, String? claudeMd, DateTime? openedAt}) {
  final resolvedPath = path ?? '/tmp/ws_${id ?? 'a'}';
  return Workspace(
    id: id ?? resolvedPath,
    path: resolvedPath,
    name: name ?? 'ws',
    claudeMd: claudeMd,
    openedAt: openedAt ?? DateTime.utc(2026, 1, 1),
  );
}

/// Factory for [SlashCommand] keyed by `trigger`. The `name` is derived by
/// stripping the leading `/`, matching the production parser convention.
SlashCommand makeSlashCommand(String trigger, {String description = ''}) {
  return SlashCommand(
    name: trigger.replaceFirst('/', ''),
    trigger: trigger,
    description: description,
    source: SlashCommandSource.user,
  );
}

/// Test [Talker] with logs disabled so the runner stdout stays clean.
Talker makeTestTalker() => Talker(settings: TalkerSettings(useConsoleLogs: false));

/// Creates a temp directory and registers a recursive teardown so the test
/// runner cleans up even when assertions fail.
Future<Directory> makeTmpDir(String prefix) async {
  final dir = await Directory.systemTemp.createTemp(prefix);
  addTearDown(() async {
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  });
  return dir;
}
