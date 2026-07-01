import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/claude_event.dart';
import '../entities/claude_effort.dart';
import '../entities/claude_model.dart';
import '../entities/claude_permission_mode.dart';
import '../repositories/claude_repository.dart';

class SendPromptParams extends Equatable {
  const SendPromptParams({
    required this.cwd,
    required this.prompt,
    required this.mode,
    this.model,
    this.effort,
    this.thinking = true,
    this.resumeSessionId,
    this.imagePaths = const [],
  });

  final String cwd;
  final String prompt;
  final ClaudePermissionMode mode;
  final ClaudeModel? model;
  final ClaudeEffort? effort;
  final bool thinking;
  final String? resumeSessionId;
  final List<String> imagePaths;

  @override
  List<Object?> get props => [cwd, prompt, mode, model, effort, thinking, resumeSessionId, imagePaths];
}

@injectable
class SendPrompt implements StreamUseCase<ClaudeEvent, SendPromptParams> {
  SendPrompt(this._repository);

  final ClaudeRepository _repository;

  @override
  Stream<Either<Failure, ClaudeEvent>> call(SendPromptParams params) {
    return _repository.startRun(
      cwd: params.cwd,
      prompt: params.prompt,
      mode: params.mode,
      model: params.model,
      effort: params.effort,
      thinking: params.thinking,
      resumeSessionId: params.resumeSessionId,
      imagePaths: params.imagePaths,
    );
  }
}
