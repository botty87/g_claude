import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../claude/data/datasources/claude_binary_resolver.dart';
import '../../../claude/domain/entities/claude_event.dart';
import '../../domain/entities/slash_command.dart';
import '../../domain/entities/slash_command_source.dart';
import '../../domain/repositories/slash_commands_repository.dart';
import '../datasources/commands_discovery_datasource.dart';
import '../datasources/slash_commands_fs_datasource.dart';

@LazySingleton(as: SlashCommandsRepository)
class SlashCommandsRepositoryImpl implements SlashCommandsRepository {
  SlashCommandsRepositoryImpl(
    this._fs,
    this._discovery,
    this._binary,
  );

  final SlashCommandsFsDataSource _fs;
  final CommandsDiscoveryDataSource _discovery;
  final ClaudeBinaryResolver _binary;

  @override
  Future<Either<Failure, List<SlashCommand>>> loadAll({
    required String? workspaceCwd,
  }) async {
    try {
      final binary = await _binary.resolve();
      final cwd = workspaceCwd ?? Directory.current.path;

      final discovery = binary != null
          ? await _discovery.discover(binary: binary, cwd: cwd)
          : CommandsDiscoveryResult.empty;

      final userByName = {
        for (final c in await _fs.loadUserCommands()) c.name: c,
      };
      final projectByName = workspaceCwd != null
          ? {for (final c in await _fs.loadProjectCommands(workspaceCwd)) c.name: c}
          : const <String, SlashCommand>{};

      final pluginByName = {for (final p in discovery.plugins) p.name: p};
      final skillSet = discovery.skills.toSet();

      final results = <SlashCommand>[];

      // Authoritative trigger list from CLI init.
      for (final name in discovery.slashCommands) {
        final cmd = await _buildCommand(
          name: name,
          isSkill: skillSet.contains(name),
          userByName: userByName,
          projectByName: projectByName,
          pluginByName: pluginByName,
        );
        results.add(cmd);
      }

      // Include skills not appearing in slash_commands (defensive).
      for (final s in discovery.skills) {
        if (discovery.slashCommands.contains(s)) continue;
        final cmd = await _buildCommand(
          name: s,
          isSkill: true,
          userByName: userByName,
          projectByName: projectByName,
          pluginByName: pluginByName,
        );
        results.add(cmd);
      }

      // Include any user/project FS commands that the CLI didn't surface
      // (e.g., binary unavailable / discovery failed).
      final coveredNames = results.map((c) => c.name).toSet();
      for (final entry in projectByName.entries) {
        if (!coveredNames.contains(entry.key)) results.add(entry.value);
      }
      for (final entry in userByName.entries) {
        if (!coveredNames.contains(entry.key)) results.add(entry.value);
      }

      return Right(results);
    } catch (e) {
      return Left(UnexpectedFailure('$e'));
    }
  }

  Future<SlashCommand> _buildCommand({
    required String name,
    required bool isSkill,
    required Map<String, SlashCommand> userByName,
    required Map<String, SlashCommand> projectByName,
    required Map<String, ClaudePluginInfo> pluginByName,
  }) async {
    final trigger = '/$name';

    final fromProject = projectByName[name];
    if (fromProject != null) return fromProject;
    final fromUser = userByName[name];
    if (fromUser != null) return fromUser;

    final colon = name.indexOf(':');
    if (colon > 0) {
      final prefix = name.substring(0, colon);
      final sub = name.substring(colon + 1);
      final plugin = pluginByName[prefix];
      if (plugin != null) {
        final enriched = await _enrichFromPlugin(
          plugin: plugin,
          subName: sub,
          isSkill: isSkill,
          name: name,
        );
        if (enriched != null) return enriched;
      }
    }

    return SlashCommand(
      name: name,
      trigger: trigger,
      description: name,
      source: isSkill ? SlashCommandSource.skill : SlashCommandSource.cliBuiltin,
    );
  }

  Future<SlashCommand?> _enrichFromPlugin({
    required ClaudePluginInfo plugin,
    required String subName,
    required bool isSkill,
    required String name,
  }) async {
    final trigger = '/$name';
    if (isSkill) {
      final skillFile = File(p.join(plugin.path, 'skills', subName, 'SKILL.md'));
      final fm = await _readFrontmatter(skillFile);
      return SlashCommand(
        name: name,
        trigger: trigger,
        description: fm?['description'] ?? subName,
        argumentHint: fm?['argument-hint'],
        source: SlashCommandSource.skill,
        filePath: skillFile.existsSync() ? skillFile.path : null,
      );
    }

    final relPath = subName.replaceAll(':', p.separator);
    final cmdFile = File(p.join(plugin.path, 'commands', '$relPath.md'));
    final fm = await _readFrontmatter(cmdFile);
    return SlashCommand(
      name: name,
      trigger: trigger,
      description: fm?['description'] ?? subName,
      argumentHint: fm?['argument-hint'],
      source: SlashCommandSource.plugin,
      filePath: cmdFile.existsSync() ? cmdFile.path : null,
    );
  }

  Future<Map<String, String>?> _readFrontmatter(File file) async {
    if (!file.existsSync()) return null;
    try {
      final content = await file.readAsString();
      if (!content.startsWith('---\n')) return null;
      final end = content.indexOf('\n---\n', 4);
      if (end == -1) return null;
      final block = content.substring(4, end);
      final result = <String, String>{};
      for (final line in block.split('\n')) {
        final colon = line.indexOf(':');
        if (colon == -1) continue;
        final key = line.substring(0, colon).trim();
        var value = line.substring(colon + 1).trim();
        if (value.startsWith('"') && value.endsWith('"')) {
          value = value.substring(1, value.length - 1);
        } else if (value.startsWith("'") && value.endsWith("'")) {
          value = value.substring(1, value.length - 1);
        }
        if (key.isNotEmpty) result[key] = value;
      }
      return result;
    } catch (_) {
      return null;
    }
  }
}
