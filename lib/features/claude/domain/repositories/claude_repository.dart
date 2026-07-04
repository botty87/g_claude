import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/claude_effort.dart';
import '../entities/claude_event.dart';
import '../entities/claude_message.dart';
import '../entities/claude_model.dart';
import '../entities/claude_permission_mode.dart';

abstract interface class ClaudeRepository {
  /// Starts a run via the sidecar and streams normalized events until the
  /// session completes (sessionDead). sid = cwd = workspaceId.
  Stream<Either<Failure, ClaudeEvent>> startRun({
    required String cwd,
    required String prompt,
    required ClaudePermissionMode mode,
    ClaudeModel? model,
    ClaudeEffort? effort,
    bool thinking = true,
    String? resumeSessionId,
    List<String> imagePaths = const [],
    Set<String> disabledMcp = const {},
  });

  /// Interrupts the running session identified by [sid].
  Future<void> stop({required String sid});

  /// Toggles an MCP server. Not yet implemented via sidecar protocol.
  Future<Either<Failure, void>> toggleMcpServer({required String serverName, required bool enabled});

  /// Starts the OAuth flow for a `needs-auth` MCP server, resolving with the
  /// browser `authUrl` to open (null if none). [cwd] is the workspace path the
  /// ephemeral auth query runs in.
  Future<Either<Failure, String?>> authenticateMcpServer({required String cwd, required String serverName});

  /// Sends answers for an `AskUserQuestion` interactive card.
  void answerQuestion({required String sid, required String toolUseId, required Map<String, String> answers});

  /// Responds to a `permissionRequest` card.
  void respondPermission({required String sid, required String toolUseId, required ClaudePermissionDecision decision});

  /// Responds to a `planProposed` card.
  void respondPlan({required String sid, required String toolUseId, required bool approve, ClaudePermissionMode? mode});

  /// Changes the permission mode at runtime for a running session.
  void setMode({required String sid, required ClaudePermissionMode mode});
}
