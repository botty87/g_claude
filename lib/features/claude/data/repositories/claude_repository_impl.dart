import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/claude_effort.dart';
import '../../domain/entities/claude_event.dart';
import '../../domain/entities/claude_message.dart';
import '../../domain/entities/claude_model.dart';
import '../../domain/entities/claude_permission_mode.dart';
import '../../domain/repositories/claude_repository.dart';
import '../datasources/sidecar_client_datasource.dart';

@LazySingleton(as: ClaudeRepository)
class ClaudeRepositoryImpl implements ClaudeRepository {
  ClaudeRepositoryImpl(this._datasource);

  final SidecarClientDataSource _datasource;

  @override
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
  }) async* {
    try {
      final source = _datasource.startRun(
        cwd: cwd,
        prompt: prompt,
        mode: mode,
        model: model,
        effort: effort,
        thinking: thinking,
        resumeSessionId: resumeSessionId,
        imagePaths: imagePaths,
        disabledMcp: disabledMcp,
      );
      await for (final event in source) {
        yield Right(event);
      }
    } catch (e) {
      yield Left(UnexpectedFailure('$e'));
    }
  }

  @override
  Future<void> stop({required String sid}) async {
    await _datasource.stop(sid: sid);
  }

  // MCP toggle/auth are not yet implemented via the sidecar protocol.
  // They will be wired in a future phase when the sidecar exposes mcpToggle/mcpAuth events.
  @override
  Future<Either<Failure, void>> toggleMcpServer({required String serverName, required bool enabled}) async =>
      const Left(NotImplementedFailure('mcp_toggle not yet implemented in sidecar protocol'));

  @override
  Future<Either<Failure, String?>> authenticateMcpServer({required String serverName}) async =>
      const Left(NotImplementedFailure('mcp_auth not yet implemented in sidecar protocol'));

  @override
  void answerQuestion({required String sid, required String toolUseId, required Map<String, String> answers}) {
    _datasource.answerQuestion(sid: sid, toolUseID: toolUseId, answers: answers);
  }

  @override
  void respondPermission({required String sid, required String toolUseId, required ClaudePermissionDecision decision}) {
    final allow = decision == ClaudePermissionDecision.allowOnce || decision == ClaudePermissionDecision.allowAlways;
    final remember = decision == ClaudePermissionDecision.allowAlways;
    _datasource.respondPermission(sid: sid, toolUseID: toolUseId, allow: allow, remember: remember);
  }

  @override
  void respondPlan({
    required String sid,
    required String toolUseId,
    required bool approve,
    ClaudePermissionMode? mode,
  }) {
    _datasource.answerPlan(sid: sid, toolUseID: toolUseId, approve: approve, mode: mode);
  }

  @override
  void setMode({required String sid, required ClaudePermissionMode mode}) {
    _datasource.setMode(sid: sid, mode: mode);
  }
}
