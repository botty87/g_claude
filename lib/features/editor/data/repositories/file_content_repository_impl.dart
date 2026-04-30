import 'dart:collection';
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

  // Bounded LRU cache. Avoids re-reading files on tab switches: switching
  // away from a file and back used to cost a fresh disk read. With this
  // cache the second visit hits memory instantly.
  static const _maxEntries = 30;
  static const _maxBytes = 10 * 1024 * 1024; // 10 MB
  final LinkedHashMap<String, FileContent> _cache = LinkedHashMap();
  int _cachedBytes = 0;
  // Coalesce concurrent reads of the same path so prewarm + foreground read
  // do not duplicate I/O.
  final Map<String, Future<Either<Failure, FileContent>>> _inFlight = {};

  @override
  Future<Either<Failure, FileContent>> readFile({required String path}) {
    final cached = _cache.remove(path);
    if (cached != null) {
      _cache[path] = cached; // re-insert to move it to MRU position
      return Future.value(Right(cached));
    }
    final pending = _inFlight[path];
    if (pending != null) return pending;
    final future = _readUncached(path);
    _inFlight[path] = future;
    future.whenComplete(() => _inFlight.remove(path));
    return future;
  }

  Future<Either<Failure, FileContent>> _readUncached(String path) async {
    try {
      final result = await _dataSource.readFile(path: path);
      _store(result);
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

  void _store(FileContent content) {
    _cache[content.path] = content;
    _cachedBytes += content.sizeBytes;
    while (_cache.length > _maxEntries || _cachedBytes > _maxBytes) {
      if (_cache.isEmpty) break;
      final firstKey = _cache.keys.first;
      final evicted = _cache.remove(firstKey);
      if (evicted != null) _cachedBytes -= evicted.sizeBytes;
    }
  }
}
