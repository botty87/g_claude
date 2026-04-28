import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/workspace.dart';

abstract interface class WorkspaceRepository {
  Future<Either<Failure, Workspace>> openWorkspace({required String path});

  Future<Either<Failure, String?>> loadClaudeMd({required String path});

  Future<Either<Failure, void>> closeWorkspace({required WorkspaceId id});
}
