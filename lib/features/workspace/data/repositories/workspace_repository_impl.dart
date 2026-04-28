import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/workspace.dart';
import '../../domain/repositories/workspace_repository.dart';
import '../datasources/workspace_local_datasource.dart';

@LazySingleton(as: WorkspaceRepository)
class WorkspaceRepositoryImpl implements WorkspaceRepository {
  WorkspaceRepositoryImpl(this._localDataSource);

  final WorkspaceLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, Workspace>> openWorkspace({required String path}) async {
    final normalized = p.normalize(p.absolute(path));

    try {
      await _localDataSource.ensureDirectoryExists(normalized);
    } on FileSystemException catch (e) {
      if (e.message.contains('not exist')) {
        return Left(NotFoundFailure(e.message));
      }
      if (e.message.contains('not a directory')) {
        return Left(ValidationFailure(e.message));
      }
      return Left(UnexpectedFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to access path: $e'));
    }

    String? claudeMd;
    try {
      claudeMd = await _localDataSource.readClaudeMd(normalized);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to read CLAUDE.md: $e'));
    }

    final workspace = Workspace(
      id: normalized,
      path: normalized,
      name: p.basename(normalized),
      claudeMd: claudeMd,
      openedAt: DateTime.now(),
    );

    return Right(workspace);
  }

  @override
  Future<Either<Failure, String?>> loadClaudeMd({required String path}) async {
    try {
      final content = await _localDataSource.readClaudeMd(p.normalize(p.absolute(path)));
      return Right(content);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to read CLAUDE.md: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> closeWorkspace({required WorkspaceId id}) async {
    return const Right(null);
  }
}
