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

  /// Toggles an MCP server on the active subprocess via control_request.
  /// Throws [StateError] if no subprocess is running.
  Future<Either<Failure, void>> toggleMcpServer({
    required String serverName,
    required bool enabled,
  });

  /// Starts the OAuth flow for an MCP server. Returns the authUrl to open in
  /// the user's browser.
  Future<Either<Failure, String?>> authenticateMcpServer({
    required String serverName,
  });
}
