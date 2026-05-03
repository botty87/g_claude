import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/di.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/claude/presentation/cubit/chat_history_cubit.dart';
import 'features/claude/presentation/cubit/claude_sessions_cubit.dart';
import 'features/editor/presentation/cubit/file_tabs_cubit.dart';
import 'features/explorer/presentation/cubit/explorer_cubit.dart';
import 'features/shell/presentation/cubit/shell_cubit.dart';
import 'features/workspace/presentation/cubit/workspaces_cubit.dart';

class App extends StatelessWidget {
  App({super.key});

  final _router = getIt<AppRouter>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WorkspacesCubit>.value(value: getIt<WorkspacesCubit>()),
        BlocProvider<ShellCubit>.value(value: getIt<ShellCubit>()),
        BlocProvider<ExplorerCubit>.value(value: getIt<ExplorerCubit>()),
        BlocProvider<FileTabsCubit>.value(value: getIt<FileTabsCubit>()),
        BlocProvider<ClaudeSessionsCubit>.value(
          value: getIt<ClaudeSessionsCubit>(),
        ),
        BlocProvider<ChatHistoryCubit>.value(
          value: getIt<ChatHistoryCubit>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Clyde',
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        routerConfig: _router.config(),
      ),
    );
  }
}
