import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/file_content.dart';

abstract interface class FileContentRepository {
  Future<Either<Failure, FileContent>> readFile({required String path});
}
