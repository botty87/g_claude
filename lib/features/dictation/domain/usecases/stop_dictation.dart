import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/dictation_repository.dart';

@injectable
class StopDictation {
  StopDictation(this._repo);

  final DictationRepository _repo;

  Future<Either<Failure, void>> call() => _repo.stop();
}
