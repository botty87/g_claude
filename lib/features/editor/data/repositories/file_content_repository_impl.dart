import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/file_content.dart';
import '../../domain/repositories/file_content_repository.dart';
import '../datasources/file_content_datasource.dart';

@LazySingleton(as: FileContentRepository)
class FileContentRepositoryImpl implements FileContentRepository {
  FileContentRepositoryImpl(this._dataSource);

  final FileContentDataSource _dataSource;

  @override
  Future<Either<Failure, FileContent>> readFile({required String path}) async {
    try {
      final result = await _dataSource.readFile(path: path);
      return Right(result);
    } on PathNotFoundException {
      return Left(NotFoundFailure(path));
    } on FileTooLargeException catch (e) {
      return Left(ValidationFailure('file too large: ${e.sizeBytes} bytes'));
    } on BinaryFileException {
      return Left(ValidationFailure('binary file'));
    } on FileSystemException catch (e) {
      return Left(UnexpectedFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('$e'));
    }
  }
}
