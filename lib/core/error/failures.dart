abstract class Failure {
  const Failure();
}

class ServerFailure extends Failure {
  final String message;
  const ServerFailure({required this.message});
}

class NetworkFailure extends Failure {
  final String message;
  const NetworkFailure(this.message);
}

class CacheFailure extends Failure {
  const CacheFailure();
}

class ValidationFailure extends Failure {
  final String message;
  const ValidationFailure(this.message);
}

class UnexpectedFailure extends Failure {
  final String message;
  const UnexpectedFailure(this.message);
}

class NotFoundFailure extends Failure {
  final String message;
  const NotFoundFailure(this.message);
}

class PreferencesFailure extends Failure {
  final String message;
  const PreferencesFailure(this.message);
}

/// `claude -p` subprocess failed to spawn, exited with non-zero, or was killed.
class SubprocessFailure extends Failure {
  final String message;
  final int? exitCode;
  const SubprocessFailure({required this.message, this.exitCode});
}

class ScreenshotCancelledFailure extends Failure {
  const ScreenshotCancelledFailure();
}

/// NDJSON line from `claude` stdout could not be decoded into a known event.
class ParsingFailure extends Failure {
  final String message;
  const ParsingFailure(this.message);
}

/// A feature or method is not yet implemented.
class NotImplementedFailure extends Failure {
  final String message;
  const NotImplementedFailure(this.message);
}
