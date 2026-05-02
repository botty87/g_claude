import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/mcp_server.dart';

abstract class McpRepository {
  Future<Either<Failure, List<McpServer>>> listServers();
}
