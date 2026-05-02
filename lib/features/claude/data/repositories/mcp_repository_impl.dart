import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/mcp_server.dart';
import '../../domain/repositories/mcp_repository.dart';
import '../datasources/mcp_list_datasource.dart';

@LazySingleton(as: McpRepository)
class McpRepositoryImpl implements McpRepository {
  McpRepositoryImpl(this._ds);
  final McpListDataSource _ds;

  @override
  Future<Either<Failure, List<McpServer>>> listServers() async {
    try {
      final servers = await _ds.list();
      return Right(servers);
    } on McpListException catch (e) {
      return Left(SubprocessFailure(message: e.message));
    } on ProcessException catch (e) {
      return Left(SubprocessFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure('$e'));
    }
  }
}
