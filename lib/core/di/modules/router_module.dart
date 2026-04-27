import 'package:injectable/injectable.dart';

import '../../router/app_router.dart';

@module
abstract class RouterModule {
  @lazySingleton
  AppRouter get router => AppRouter();
}
