import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import '../../../features/claude/data/datasources/sessions_database.dart';

@module
abstract class DatabaseModule {
  @preResolve
  @lazySingleton
  Future<SessionsDatabase> sessionsDatabase() async {
    final dir = await getApplicationSupportDirectory();
    return SessionsDatabase.openInDirectory(dir);
  }
}
