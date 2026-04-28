import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/file_node.dart';
import '../../domain/repositories/file_system_repository.dart';
import '../datasources/file_system_datasource.dart';

@LazySingleton(as: FileSystemRepository)
class FileSystemRepositoryImpl implements FileSystemRepository {
  FileSystemRepositoryImpl(this._dataSource);

  final FileSystemDataSource _dataSource;

  @override
  Future<Either<Failure, List<FileNode>>> listDirectory({required String path}) async {
    try {
      final nodes = await _dataSource.list(path);
      return Right(nodes);
    } on PathNotFoundException {
      return Left(NotFoundFailure(path));
    } on FileSystemException catch (e) {
      return Left(UnexpectedFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('$e'));
    }
  }
}
