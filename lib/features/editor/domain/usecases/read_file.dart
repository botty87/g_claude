import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/file_content.dart';
import '../repositories/file_content_repository.dart';

@injectable
class ReadFile {
  ReadFile(this._repo);

  final FileContentRepository _repo;

  Future<Either<Failure, FileContent>> call({required String path}) => _repo.readFile(path: path);
}
