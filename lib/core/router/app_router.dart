import 'package:auto_route/auto_route.dart';

import '../../features/shell/presentation/widgets/app_shell.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: AppShellRoute.page, initial: true, path: '/'),
  ];
}
