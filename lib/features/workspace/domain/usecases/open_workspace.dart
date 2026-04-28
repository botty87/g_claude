import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/workspace.dart';
import '../repositories/workspace_repository.dart';

@injectable
class OpenWorkspace {
  OpenWorkspace(this._repository);

  final WorkspaceRepository _repository;

  Future<Either<Failure, Workspace>> call({required String path}) =>
      _repository.openWorkspace(path: path);
}
