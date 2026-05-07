import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../core/utils/frontmatter.dart';
import '../../domain/entities/slash_command.dart';
import '../../domain/entities/slash_command_source.dart';

@lazySingleton
class SlashCommandsFsDataSource {
  SlashCommandsFsDataSource(this._talker);
  final Talker _talker;

  Future<List<SlashCommand>> loadUserCommands() async {
    final home = Platform.environment['HOME'];
    if (home == null) return const [];
    final dir = Directory(p.join(home, '.claude', 'commands'));
    return _scanCommandsDir(dir, SlashCommandSource.user);
  }

  Future<List<SlashCommand>> loadProjectCommands(String cwd) async {
    final dir = Directory(p.join(cwd, '.claude', 'commands'));
    return _scanCommandsDir(dir, SlashCommandSource.project);
  }

  Future<List<SlashCommand>> _scanCommandsDir(Directory dir, SlashCommandSource source) async {
    final results = <SlashCommand>[];
    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is! File) continue;
        if (!entity.path.endsWith('.md')) continue;
        try {
          final cmd = await _parseCommandFile(entity, dir.path, source);
          if (cmd != null) results.add(cmd);
        } catch (e) {
          _talker.warning('slash_commands: failed to parse ${entity.path}: $e');
        }
      }
    } on FileSystemException {
      return const [];
    }
    return results;
  }

  Future<SlashCommand?> _parseCommandFile(File file, String commandsDir, SlashCommandSource source) async {
    final rel = p.withoutExtension(p.relative(file.path, from: commandsDir));
    final name = rel.replaceAll(p.separator, ':');
    final trigger = '/$name';

    String content;
    try {
      content = await file.readAsString();
    } catch (e) {
      _talker.warning('slash_commands: cannot read ${file.path}: $e');
      return null;
    }

    final frontmatter = parseFrontmatter(content);
    final description = frontmatter['description'] ?? name;
    final argumentHint = frontmatter['argument-hint'];
    final allowedToolsRaw = frontmatter['allowed-tools'];
    final allowedTools = allowedToolsRaw != null
        ? allowedToolsRaw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList()
        : const <String>[];

    return SlashCommand(
      name: name,
      trigger: trigger,
      description: description,
      argumentHint: argumentHint,
      source: source,
      filePath: file.path,
      allowedTools: allowedTools,
    );
  }
}
