import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/file_node.dart';

abstract interface class FileSystemRepository {
  Future<Either<Failure, List<FileNode>>> listDirectory({required String path});
}
