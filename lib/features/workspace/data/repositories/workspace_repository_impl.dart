import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/workspace.dart';
import '../../domain/repositories/workspace_repository.dart';
import '../datasources/workspace_local_datasource.dart';

@LazySingleton(as: WorkspaceRepository)
class WorkspaceRepositoryImpl implements WorkspaceRepository {
  WorkspaceRepositoryImpl(this._localDataSource);

  final WorkspaceLocalDataSource _localDataSource;

  String _normalize(String path) => p.normalize(p.absolute(path));

  @override
  Future<Either<Failure, Workspace>> openWorkspace({required String path}) async {
    final normalized = _normalize(path);

    try {
      await _localDataSource.ensureDirectoryExists(normalized);
      final claudeMd = await _localDataSource.readClaudeMd(normalized);
      return Right(Workspace(
        id: normalized,
        path: normalized,
        name: p.basename(normalized),
        claudeMd: claudeMd,
        openedAt: DateTime.now(),
      ));
    } on WorkspaceNotFoundException catch (e) {
      return Left(NotFoundFailure('Directory does not exist: ${e.path}'));
    } on WorkspaceNotADirectoryException catch (e) {
      return Left(ValidationFailure('Path is not a directory: ${e.path}'));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to open workspace: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> loadClaudeMd({required String path}) async {
    try {
      final content = await _localDataSource.readClaudeMd(_normalize(path));
      return Right(content);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to read CLAUDE.md: $e'));
    }
  }
}
