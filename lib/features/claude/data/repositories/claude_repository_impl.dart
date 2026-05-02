import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/claude_event.dart';
import '../../domain/entities/claude_effort.dart';
import '../../domain/entities/claude_model.dart';
import '../../domain/entities/claude_permission_mode.dart';
import '../../domain/repositories/claude_repository.dart';
import '../datasources/claude_process_datasource.dart';

@LazySingleton(as: ClaudeRepository)
class ClaudeRepositoryImpl implements ClaudeRepository {
  ClaudeRepositoryImpl(this._datasource);

  final ClaudeProcessDataSource _datasource;

  @override
  Stream<Either<Failure, ClaudeEvent>> startRun({
    required String cwd,
    required String prompt,
    required ClaudePermissionMode mode,
    ClaudeModel? model,
    ClaudeEffort? effort,
    String? resumeSessionId,
  }) async* {
    try {
      final source = _datasource.startRun(
        cwd: cwd,
        prompt: prompt,
        mode: mode,
        model: model,
        effort: effort,
        resumeSessionId: resumeSessionId,
      );
      await for (final event in source) {
        yield Right(event);
      }
    } on ClaudeBinaryNotFoundException {
      yield const Left(SubprocessFailure(
        message: 'binary_not_found',
      ));
    } on ClaudeSpawnException catch (e) {
      yield Left(SubprocessFailure(message: e.message));
    } catch (e) {
      yield Left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<void> stop() => _datasource.stop();

  @override
  Future<Either<Failure, void>> toggleMcpServer({
    required String serverName,
    required bool enabled,
  }) async {
    try {
      await _datasource.sendControlRequest(
        subtype: 'mcp_toggle',
        payload: {'serverName': serverName, 'enabled': enabled},
      );
      return const Right(null);
    } on StateError catch (e) {
      return Left(SubprocessFailure(message: e.message));
    } on McpControlException catch (e) {
      return Left(SubprocessFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, String?>> authenticateMcpServer({
    required String serverName,
  }) async {
    try {
      final response = await _datasource.sendControlRequest(
        subtype: 'mcp_authenticate',
        payload: {'serverName': serverName},
      );
      final authUrl = response['authUrl'];
      return Right(authUrl is String ? authUrl : null);
    } on StateError catch (e) {
      return Left(SubprocessFailure(message: e.message));
    } on McpControlException catch (e) {
      return Left(SubprocessFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure('$e'));
    }
  }
}
