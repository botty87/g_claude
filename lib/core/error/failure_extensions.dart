import 'failures.dart';

extension FailureMessageX on Failure {
  String toUserMessage() => switch (this) {
    ServerFailure(:final message) => message,
    NetworkFailure(:final message) => message,
    NotFoundFailure(:final message) => message,
    UnexpectedFailure(:final message) => message,
    ValidationFailure(:final message) => message,
    PreferencesFailure(:final message) => message,
    SubprocessFailure(:final message) => message,
    ParsingFailure(:final message) => message,
    CacheFailure() => 'Cache error',
    _ => 'Unknown error occurred',
  };
}
