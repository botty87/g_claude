import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../domain/entities/chat_session_summary.dart';
import '../../domain/entities/claude_message.dart';
import '../../domain/repositories/chat_history_repository.dart';
import '../datasources/claude_history_datasource.dart';
import '../datasources/sessions_index_datasource.dart';

@LazySingleton(as: ChatHistoryRepository)
class ChatHistoryRepositoryImpl implements ChatHistoryRepository {
  ChatHistoryRepositoryImpl(this._index, this._history, this._talker);

  final SessionsIndexDataSource _index;
  final ClaudeHistoryDataSource _history;
  final Talker _talker;

  @override
  Future<Either<Failure, List<ChatSessionSummary>>> listSessions(
    WorkspaceId workspaceId,
  ) async {
    try {
      final rows = await _index.listForWorkspace(workspaceId);
      final summaries = rows
          .map(
            (r) => ChatSessionSummary(
              id: r.id,
              workspaceId: workspaceId,
              encodedPath: r.encodedPath,
              title: r.title,
              firstMessageAt: r.firstMessageAt,
              lastMessageAt: r.lastMessageAt,
              messageCount: r.messageCount,
            ),
          )
          .toList();
      return Right(summaries);
    } catch (e, st) {
      _talker.error('listSessions failed for $workspaceId', e, st);
      return Left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, List<ClaudeMessage>>> loadMessages({
    required String encodedPath,
    required String sessionId,
  }) async {
    try {
      final messages = await _history
          .readSession(encodedPath: encodedPath, sessionId: sessionId)
          .toList();
      return Right(messages);
    } on FileSystemException catch (e) {
      _talker.error('loadMessages: session file not found $sessionId', e);
      return Left(NotFoundFailure('Session file not found: ${e.path}'));
    } catch (e, st) {
      _talker.error('loadMessages failed for $sessionId', e, st);
      return Left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, void>> refreshIndex({
    required WorkspaceId workspaceId,
    required String workspaceCwd,
  }) async {
    try {
      await _index.refreshIndex(
        workspaceId: workspaceId,
        workspaceCwd: workspaceCwd,
      );
      return const Right(null);
    } catch (e, st) {
      _talker.error('refreshIndex failed for $workspaceId', e, st);
      return Left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSession({
    required String sessionId,
    required String encodedPath,
  }) async {
    try {
      await _history.deleteSession(
        encodedPath: encodedPath,
        sessionId: sessionId,
      );
      await _index.deleteRow(sessionId);
      return const Right(null);
    } on FileSystemException catch (e) {
      _talker.error('deleteSession: file not found $sessionId', e);
      return Left(NotFoundFailure('Session file not found: ${e.path}'));
    } catch (e, st) {
      _talker.error('deleteSession failed for $sessionId', e, st);
      return Left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, String>> exportSession({
    required String encodedPath,
    required String sessionId,
    required String destinationPath,
  }) async {
    try {
      final path = await _history.exportSessionMarkdown(
        encodedPath: encodedPath,
        sessionId: sessionId,
        destinationPath: destinationPath,
      );
      return Right(path);
    } on FileSystemException catch (e) {
      _talker.error('exportSession: file not found $sessionId', e);
      return Left(NotFoundFailure('Session file not found: ${e.path}'));
    } catch (e, st) {
      _talker.error('exportSession failed for $sessionId', e, st);
      return Left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, List<ChatSessionSummary>>> searchSessions(
    WorkspaceId workspaceId,
    String query,
  ) async {
    if (query.trim().isEmpty) return listSessions(workspaceId);
    try {
      final ids = await _index.searchIds(workspaceId, query);
      if (ids.isEmpty) return const Right([]);
      final rows = await _index.getByIds(ids, workspaceId);
      final summaries = rows
          .map(
            (r) => ChatSessionSummary(
              id: r.id,
              workspaceId: workspaceId,
              encodedPath: r.encodedPath,
              title: r.title,
              firstMessageAt: r.firstMessageAt,
              lastMessageAt: r.lastMessageAt,
              messageCount: r.messageCount,
            ),
          )
          .toList();
      return Right(summaries);
    } catch (e, st) {
      _talker.error('searchSessions failed for $workspaceId query=$query', e, st);
      return Left(UnexpectedFailure('$e'));
    }
  }
}
