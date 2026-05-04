import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import '../../../features/app_logs/data/datasources/app_logs_database.dart';

@module
abstract class AppLogsDatabaseModule {
  @preResolve
  @lazySingleton
  Future<AppLogsDatabase> appLogsDatabase() async {
    final dir = await getApplicationSupportDirectory();
    return AppLogsDatabase.openInDirectory(dir);
  }
}
