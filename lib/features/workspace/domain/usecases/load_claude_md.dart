import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/workspace_repository.dart';

@injectable
class LoadClaudeMd {
  LoadClaudeMd(this._repository);

  final WorkspaceRepository _repository;

  Future<Either<Failure, String?>> call({required String path}) => _repository.loadClaudeMd(path: path);
}
