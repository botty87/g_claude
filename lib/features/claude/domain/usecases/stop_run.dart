import 'package:injectable/injectable.dart';

import '../repositories/claude_repository.dart';

@injectable
class StopRun {
  StopRun(this._repository);

  final ClaudeRepository _repository;

  Future<void> call() => _repository.stop();
}
