import 'dart:io' show Platform;

import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/app_log_session.dart';
import '../repositories/app_logs_repository.dart';

@injectable
class StartAppSession {
  StartAppSession(this._repo);
  final AppLogsRepository _repo;

  Future<Either<Failure, AppLogSession>> call() =>
      _repo.startSession(platform: Platform.operatingSystem);
}
