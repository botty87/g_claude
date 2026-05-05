import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/dictation_partial.dart';

abstract interface class DictationRepository {
  /// Lazily prepares the underlying engine. Returns `true` once ready.
  Future<Either<Failure, bool>> initialize();

  /// Whether microphone permission was granted by the user/OS.
  Future<Either<Failure, bool>> hasPermission();

  /// Stream of partial + final transcripts emitted while a session is active.
  Stream<DictationPartial> get partials;

  /// Begins a new listening session. The implementation may auto-stop after
  /// a period of silence.
  Future<Either<Failure, void>> startListening({
    required String localeId,
  });

  /// Stops listening and finalizes the current transcript.
  Future<Either<Failure, void>> stop();

  /// Cancels listening without producing a final transcript.
  Future<Either<Failure, void>> cancel();
}
