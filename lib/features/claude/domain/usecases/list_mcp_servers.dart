import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/mcp_server.dart';
import '../repositories/mcp_repository.dart';

@injectable
class ListMcpServers {
  ListMcpServers(this._repo);
  final McpRepository _repo;

  Future<Either<Failure, List<McpServer>>> call() => _repo.listServers();
}
