import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/claude_event.dart';
import '../entities/claude_effort.dart';
import '../entities/claude_model.dart';
import '../entities/claude_permission_mode.dart';

abstract interface class ClaudeRepository {
  /// Spawns `claude -p` and emits normalized events as they stream from
  /// stdout. The stream completes when the subprocess exits.
  Stream<Either<Failure, ClaudeEvent>> startRun({
    required String cwd,
    required String prompt,
    required ClaudePermissionMode mode,
    ClaudeModel? model,
    ClaudeEffort? effort,
    String? resumeSessionId,
  });

  /// Terminates the current run if any (best-effort).
  Future<void> stop();
}
