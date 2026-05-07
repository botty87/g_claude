import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/file_node.dart';
import '../repositories/file_system_repository.dart';

@injectable
class ListDirectory {
  ListDirectory(this._repo);

  final FileSystemRepository _repo;

  Future<Either<Failure, List<FileNode>>> call({required String path}) => _repo.listDirectory(path: path);
}
