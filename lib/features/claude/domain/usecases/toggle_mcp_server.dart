import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/claude_repository.dart';

@injectable
class ToggleMcpServer {
  ToggleMcpServer(this._repo);
  final ClaudeRepository _repo;

  Future<Either<Failure, void>> call({
    required String serverName,
    required bool enabled,
  }) =>
      _repo.toggleMcpServer(serverName: serverName, enabled: enabled);
}
