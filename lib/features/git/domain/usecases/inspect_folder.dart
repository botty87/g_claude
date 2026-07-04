import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/git_folder_inspection.dart';
import '../repositories/git_repository.dart';

@injectable
class InspectFolder {
  InspectFolder(this._repository);
  final GitRepository _repository;

  Future<Either<Failure, GitFolderInspection>> call({required String path}) => _repository.inspect(path: path);
}
