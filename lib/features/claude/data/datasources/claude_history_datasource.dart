import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:talker_flutter/talker_flutter.dart';

import '../../domain/entities/claude_message.dart';

class JsonlSessionMeta {
  const JsonlSessionMeta({
    required this.id,
    required this.encodedPath,
    required this.title,
    required this.firstMessageAt,
    required this.lastMessageAt,
    required this.messageCount,
    required this.fileSize,
    required this.fileMtime,
  });

  final String id;
  final String encodedPath;
  final String title;
  final DateTime firstMessageAt;
  final DateTime lastMessageAt;
  final int messageCount;
  final int fileSize;
  final DateTime fileMtime;
}

abstract interface class ClaudeHistoryDataSource {
  String encodeCwd(String cwd);
  Future<List<JsonlSessionMeta>> scanWorkspace(String cwd);
  Stream<ClaudeMessage> readSession({required String encodedPath, required String sessionId});
  Future<void> deleteSession({required String encodedPath, required String sessionId});
  Future<String> exportSessionMarkdown({
    required String encodedPath,
    required String sessionId,
    required String destinationPath,
  });
}

@LazySingleton(as: ClaudeHistoryDataSource)
class ClaudeHistoryDataSourceImpl implements ClaudeHistoryDataSource {
  ClaudeHistoryDataSourceImpl(this._talker);

  final Talker _talker;

  static final _nonAlphanumeric = RegExp(r'[^a-zA-Z0-9]');

  Directory get _projectsDir {
    final home = Platform.environment['HOME'] ?? '';
    if (home.isEmpty) {
      _talker.warning('HOME env var not set; .claude/projects path resolution will fail');
    }
    return Directory(p.join(home, '.claude', 'projects'));
  }

  @override
  String encodeCwd(String cwd) => cwd.replaceAll(_nonAlphanumeric, '-');

  @override
  Future<List<JsonlSessionMeta>> scanWorkspace(String cwd) async {
    try {
      final encoded = encodeCwd(cwd);
      final dir = Directory(p.join(_projectsDir.path, encoded));
      if (!dir.existsSync()) return [];

      final metas = <JsonlSessionMeta>[];

      await for (final entity in dir.list()) {
        if (entity is! File) continue;
        if (!entity.path.endsWith('.jsonl')) continue;

        try {
          final stat = await entity.stat();
          final fileMtime = stat.modified;
          final fileSize = stat.size;
          final sessionId = p.basenameWithoutExtension(entity.path);

          String title = '(empty)';
          DateTime? firstMessageAt;
          DateTime? lastMessageAt;
          int messageCount = 0;

          final lines = entity.openRead().transform(utf8.decoder).transform(const LineSplitter());

          await for (final line in lines) {
            if (line.trim().isEmpty) continue;
            Map<String, dynamic> entry;
            try {
              final decoded = jsonDecode(line);
              if (decoded is! Map<String, dynamic>) continue;
              entry = decoded;
            } catch (_) {
              continue;
            }

            final type = entry['type'] as String?;
            final isSidechain = entry['isSidechain'] == true;

            if (type == 'queue-operation' || type == 'summary' || type == 'system') continue;

            final rawTs = entry['timestamp'] as String?;
            final ts = rawTs != null ? DateTime.tryParse(rawTs) : null;

            if (ts != null) {
              firstMessageAt ??= ts;
              lastMessageAt = ts;
            }

            if (isSidechain) continue;

            if (type == 'user' || type == 'assistant') {
              messageCount++;
            }

            if (type == 'user' && title == '(empty)') {
              final message = entry['message'];
              if (message is Map<String, dynamic>) {
                final content = message['content'];
                if (content is String && !content.startsWith('/')) {
                  title = content.length > 80 ? content.substring(0, 80) : content;
                }
              }
            }
          }

          metas.add(JsonlSessionMeta(
            id: sessionId,
            encodedPath: encoded,
            title: title,
            firstMessageAt: firstMessageAt ?? fileMtime,
            lastMessageAt: lastMessageAt ?? fileMtime,
            messageCount: messageCount,
            fileSize: fileSize,
            fileMtime: fileMtime,
          ));
        } catch (e, st) {
          _talker.error('Failed to scan session file ${entity.path}', e, st);
        }
      }

      metas.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
      return metas;
    } catch (e, st) {
      _talker.error('scanWorkspace failed for $cwd', e, st);
      rethrow;
    }
  }

  @override
  Stream<ClaudeMessage> readSession({required String encodedPath, required String sessionId}) async* {
    final file = File(p.join(_projectsDir.path, encodedPath, '$sessionId.jsonl'));
    final pendingTools = <String, ClaudeMessageTool>{};

    try {
      final lines = file.openRead().transform(utf8.decoder).transform(const LineSplitter());

      await for (final line in lines) {
        if (line.trim().isEmpty) continue;

        Map<String, dynamic> entry;
        try {
          final decoded = jsonDecode(line);
          if (decoded is! Map<String, dynamic>) continue;
          entry = decoded;
        } catch (e) {
          _talker.warning('readSession: could not parse line in $sessionId: $e');
          continue;
        }

        final type = entry['type'] as String?;
        if (type == 'queue-operation' || type == 'summary' || type == 'system') continue;

        final isSidechain = entry['isSidechain'] == true;
        if (isSidechain) continue;

        final rawTs = entry['timestamp'] as String?;
        final ts = rawTs != null ? (DateTime.tryParse(rawTs) ?? DateTime.now()) : DateTime.now();
        final uuid = entry['uuid'] as String?;

        if (type == 'user') {
          final message = entry['message'];
          if (message is! Map<String, dynamic>) continue;

          final content = message['content'];

          if (content is String) {
            yield ClaudeMessage.user(
              id: uuid ?? 'u-${ts.millisecondsSinceEpoch}',
              text: content,
              createdAt: ts,
            );
          } else if (content is List) {
            for (final block in content) {
              if (block is! Map<String, dynamic>) continue;
              if (block['type'] != 'tool_result') continue;

              final toolUseId = block['tool_use_id'] as String?;
              if (toolUseId == null) continue;

              final pending = pendingTools.remove(toolUseId);
              if (pending == null) continue;

              final rawContent = block['content'];
              final String output;
              if (rawContent is String) {
                output = rawContent;
              } else if (rawContent != null) {
                output = jsonEncode(rawContent);
              } else {
                output = '';
              }

              final isError = block['is_error'] == true;
              yield pending.copyWith(
                status: isError ? ClaudeToolStatus.error : ClaudeToolStatus.completed,
                output: output,
                isError: isError,
              );
            }
          }
        } else if (type == 'assistant') {
          final message = entry['message'];
          if (message is! Map<String, dynamic>) continue;

          final content = message['content'];
          if (content is! List) continue;

          final messageId = message['id'] as String? ?? uuid ?? 'a-${ts.millisecondsSinceEpoch}';

          final textBuf = StringBuffer();
          for (final block in content) {
            if (block is! Map<String, dynamic>) continue;
            if (block['type'] == 'text') {
              textBuf.write(block['text'] as String? ?? '');
            }
          }

          final text = textBuf.toString();
          if (text.isNotEmpty) {
            yield ClaudeMessage.assistant(
              id: messageId,
              text: text,
              isStreaming: false,
              createdAt: ts,
            );
          }

          for (final block in content) {
            if (block is! Map<String, dynamic>) continue;
            if (block['type'] != 'tool_use') continue;

            final toolId = block['id'] as String?;
            if (toolId == null) continue;
            final toolName = block['name'] as String? ?? '';
            final input = block['input'];
            final inputMap = input is Map<String, dynamic> ? input : null;

            final toolMsg = ClaudeMessage.tool(
              id: 't-$toolId',
              toolName: toolName,
              status: ClaudeToolStatus.running,
              toolUseId: toolId,
              input: inputMap,
              createdAt: ts,
            ) as ClaudeMessageTool;

            pendingTools[toolId] = toolMsg;
            yield toolMsg;
          }
        }
      }

      for (final orphan in pendingTools.values) {
        yield orphan.copyWith(status: ClaudeToolStatus.error, isError: true);
      }
    } catch (e, st) {
      _talker.error('readSession failed for $sessionId', e, st);
      rethrow;
    }
  }

  @override
  Future<void> deleteSession({required String encodedPath, required String sessionId}) async {
    final file = File(p.join(_projectsDir.path, encodedPath, '$sessionId.jsonl'));
    if (!file.existsSync()) {
      throw FileSystemException('Session file not found', file.path);
    }
    await file.delete();
  }

  @override
  Future<String> exportSessionMarkdown({
    required String encodedPath,
    required String sessionId,
    required String destinationPath,
  }) async {
    final buf = StringBuffer();
    buf.writeln('# Session $sessionId');
    buf.writeln();

    await for (final msg in readSession(encodedPath: encodedPath, sessionId: sessionId)) {
      switch (msg) {
        case ClaudeMessageUser():
          buf.writeln('## User');
          buf.writeln('_${msg.createdAt.toIso8601String()}_');
          buf.writeln();
          buf.writeln(msg.text);
          buf.writeln();

        case ClaudeMessageAssistant():
          buf.writeln('## Assistant');
          buf.writeln('_${msg.createdAt.toIso8601String()}_');
          buf.writeln();
          buf.writeln(msg.text);
          buf.writeln();

        case ClaudeMessageTool():
          buf.writeln('### Tool: ${msg.toolName}');
          buf.writeln('_${msg.createdAt.toIso8601String()}_');
          buf.writeln();
          if (msg.input != null) {
            buf.writeln('```json');
            buf.writeln(const JsonEncoder.withIndent('  ').convert(msg.input));
            buf.writeln('```');
            buf.writeln();
          }
          if (msg.output != null && msg.output!.isNotEmpty) {
            buf.writeln('```');
            buf.writeln(msg.output);
            buf.writeln('```');
            buf.writeln();
          }

        case ClaudeMessageSystem():
          buf.writeln('## System');
          buf.writeln('_${msg.createdAt.toIso8601String()}_');
          buf.writeln();
          buf.writeln(msg.text);
          buf.writeln();
      }
    }

    final destFile = File(destinationPath);
    await Directory(p.dirname(destinationPath)).create(recursive: true);
    await destFile.writeAsString(buf.toString());
    return destinationPath;
  }
}
