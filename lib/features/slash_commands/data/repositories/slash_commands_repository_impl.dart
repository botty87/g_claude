import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/frontmatter.dart';
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

      final discoverySkillSet = discovery.slashCommands.toSet();
      final results = await Future.wait([
        ...discovery.slashCommands.map(
          (name) => _buildCommand(
            name: name,
            isSkill: skillSet.contains(name),
            userByName: userByName,
            projectByName: projectByName,
            pluginByName: pluginByName,
          ),
        ),
        ...discovery.skills
            .where((s) => !discoverySkillSet.contains(s))
            .map(
              (s) => _buildCommand(
                name: s,
                isSkill: true,
                userByName: userByName,
                projectByName: projectByName,
                pluginByName: pluginByName,
              ),
            ),
      ]);

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
    final file = isSkill
        ? File(p.join(plugin.path, 'skills', subName, 'SKILL.md'))
        : File(p.join(plugin.path, 'commands', '${subName.replaceAll(':', p.separator)}.md'));
    final read = await _readFile(file);
    final fm = read != null ? parseFrontmatter(read) : null;
    return SlashCommand(
      name: name,
      trigger: trigger,
      description: fm?['description'] ?? subName,
      argumentHint: fm?['argument-hint'],
      source: isSkill ? SlashCommandSource.skill : SlashCommandSource.plugin,
      filePath: read != null ? file.path : null,
    );
  }

  Future<String?> _readFile(File file) async {
    try {
      return await file.readAsString();
    } catch (_) {
      return null;
    }
  }
}
