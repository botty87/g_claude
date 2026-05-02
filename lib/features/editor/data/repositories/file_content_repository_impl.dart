import 'dart:collection';
import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/file_content.dart';
import '../../domain/repositories/file_content_repository.dart';
import '../datasources/file_content_datasource.dart';

class _CacheEntry {
  _CacheEntry(this.content, this.mtime);
  final FileContent content;
  final DateTime mtime;
}

@LazySingleton(as: FileContentRepository)
class FileContentRepositoryImpl implements FileContentRepository {
  FileContentRepositoryImpl(this._dataSource);

  final FileContentDataSource _dataSource;

  // Bounded LRU cache so revisiting a tab does not pay disk I/O.
  // Validated via mtime on every hit so external edits are picked up.
  static const _maxEntries = 30;
  static const _maxBytes = 10 * 1024 * 1024;
  final LinkedHashMap<String, _CacheEntry> _cache = LinkedHashMap();
  int _cachedBytes = 0;
  // Coalesce concurrent reads of the same path (prewarm + foreground).
  final Map<String, Future<Either<Failure, FileContent>>> _inFlight = {};

  @override
  Future<Either<Failure, FileContent>> readFile({required String path}) async {
    final cached = _cache[path];
    if (cached != null) {
      try {
        final mtime = await _dataSource.mtimeOf(path: path);
        if (mtime == null) {
          _evict(path);
          return Left(NotFoundFailure(path));
        }
        if (mtime == cached.mtime) {
          _cache.remove(path);
          _cache[path] = cached; // MRU
          return Right(cached.content);
        }
        _evict(path);
      } catch (_) {
        _evict(path);
      }
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
      _store(result.content, result.modified);
      return Right(result.content);
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

  void _store(FileContent content, DateTime mtime) {
    final existing = _cache.remove(content.path);
    if (existing != null) _cachedBytes -= existing.content.sizeBytes;
    _cache[content.path] = _CacheEntry(content, mtime);
    _cachedBytes += content.sizeBytes;
    while (_cache.length > _maxEntries || _cachedBytes > _maxBytes) {
      if (_cache.isEmpty) break;
      final firstKey = _cache.keys.first;
      final evicted = _cache.remove(firstKey);
      if (evicted != null) _cachedBytes -= evicted.content.sizeBytes;
    }
  }

  void _evict(String path) {
    final removed = _cache.remove(path);
    if (removed != null) _cachedBytes -= removed.content.sizeBytes;
  }
}
