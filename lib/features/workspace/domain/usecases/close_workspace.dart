import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/workspace.dart';
import '../repositories/workspace_repository.dart';

@injectable
class CloseWorkspace {
  CloseWorkspace(this._repository);

  final WorkspaceRepository _repository;

  Future<Either<Failure, void>> call({required WorkspaceId id}) =>
      _repository.closeWorkspace(id: id);
}
