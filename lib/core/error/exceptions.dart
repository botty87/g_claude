import 'package:flutter/foundation.dart';

@immutable
final class UnexpectedStateException implements Exception {
  final String message;

  const UnexpectedStateException({this.message = 'An unexpected state was encountered.'});
}

@immutable
final class ServerException implements Exception {
  final String message;
  const ServerException({required this.message});
}

final class NetworkException implements Exception {
  final String message;
  const NetworkException({required this.message});
}

@immutable
final class InvalidRouteException implements Exception {
  final String message;
  final String invalidPath;

  const InvalidRouteException({required this.message, required this.invalidPath});
}

@immutable
final class PreferencesStorageException implements Exception {
  final String message;
  final Object? cause;

  const PreferencesStorageException({required this.message, this.cause});
}

@immutable
final class SubprocessException implements Exception {
  final String message;
  final int? exitCode;
  const SubprocessException({required this.message, this.exitCode});
}

@immutable
final class ParsingException implements Exception {
  final String message;
  final Object? cause;
  const ParsingException({required this.message, this.cause});
}
