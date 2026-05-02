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
}
