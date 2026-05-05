import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/dictation_repository.dart';

@injectable
class StartDictation {
  StartDictation(this._repo);

  final DictationRepository _repo;

  Future<Either<Failure, void>> call({required String localeId}) =>
      _repo.startListening(localeId: localeId);
}
