import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/dictation_partial.dart';
import '../../domain/repositories/dictation_repository.dart';
import '../datasources/dictation_data_source.dart';

@LazySingleton(as: DictationRepository)
class DictationRepositoryImpl implements DictationRepository {
  DictationRepositoryImpl(this._ds);

  final DictationDataSource _ds;

  @override
  Stream<DictationPartial> get partials => _ds.partials;

  @override
  Future<Either<Failure, bool>> initialize() async {
    try {
      final ok = await _ds.initialize();
      return Right(ok);
    } catch (e) {
      return Left(DictationBackendFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasPermission() async {
    try {
      return Right(await _ds.hasPermission());
    } catch (e) {
      return Left(DictationBackendFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, void>> startListening({
    required String localeId,
  }) async {
    try {
      final permitted = await _ds.hasPermission();
      if (!permitted) {
        return const Left(MicrophonePermissionFailure());
      }
      await _ds.startListening(localeId: localeId);
      return const Right(null);
    } catch (e) {
      return Left(DictationBackendFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, void>> stop() async {
    try {
      await _ds.stop();
      return const Right(null);
    } catch (e) {
      return Left(DictationBackendFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancel() async {
    try {
      await _ds.cancel();
      return const Right(null);
    } catch (e) {
      return Left(DictationBackendFailure('$e'));
    }
  }
}
