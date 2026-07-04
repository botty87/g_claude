import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/claude_repository.dart';

@injectable
class AuthenticateMcpServer {
  AuthenticateMcpServer(this._repo);
  final ClaudeRepository _repo;

  Future<Either<Failure, String?>> call({required String cwd, required String serverName}) =>
      _repo.authenticateMcpServer(cwd: cwd, serverName: serverName);
}
