// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_bloc/flutter_bloc.dart' as _i331;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:talker_flutter/talker_flutter.dart' as _i207;

import '../../features/app_logs/data/datasources/app_logs_database.dart'
    as _i126;
import '../../features/app_logs/data/datasources/talker_log_recorder.dart'
    as _i419;
import '../../features/app_logs/data/repositories/app_logs_repository_impl.dart'
    as _i413;
import '../../features/app_logs/domain/repositories/app_logs_repository.dart'
    as _i644;
import '../../features/app_logs/domain/usecases/delete_session.dart' as _i609;
import '../../features/app_logs/domain/usecases/end_app_session.dart' as _i847;
import '../../features/app_logs/domain/usecases/prune_old_sessions.dart'
    as _i894;
import '../../features/app_logs/domain/usecases/start_app_session.dart'
    as _i647;
import '../../features/app_logs/domain/usecases/watch_log_sessions.dart'
    as _i953;
import '../../features/app_logs/domain/usecases/watch_session_entries.dart'
    as _i41;
import '../../features/app_logs/presentation/cubit/app_log_detail_cubit.dart'
    as _i709;
import '../../features/app_logs/presentation/cubit/app_logs_cubit.dart'
    as _i148;
import '../../features/claude/data/datasources/claude_binary_resolver.dart'
    as _i1073;
import '../../features/claude/data/datasources/claude_history_datasource.dart'
    as _i278;
import '../../features/claude/data/datasources/mcp_list_datasource.dart'
    as _i340;
import '../../features/claude/data/datasources/sessions_database.dart'
    as _i1060;
import '../../features/claude/data/datasources/sessions_index_datasource.dart'
    as _i627;
import '../../features/claude/data/datasources/sidecar_client_datasource.dart'
    as _i330;
import '../../features/claude/data/datasources/sidecar_transport.dart' as _i583;
import '../../features/claude/data/repositories/chat_history_repository_impl.dart'
    as _i682;
import '../../features/claude/data/repositories/claude_repository_impl.dart'
    as _i1009;
import '../../features/claude/data/repositories/mcp_repository_impl.dart'
    as _i629;
import '../../features/claude/domain/repositories/chat_history_repository.dart'
    as _i875;
import '../../features/claude/domain/repositories/claude_repository.dart'
    as _i139;
import '../../features/claude/domain/repositories/mcp_repository.dart' as _i585;
import '../../features/claude/domain/usecases/authenticate_mcp_server.dart'
    as _i407;
import '../../features/claude/domain/usecases/delete_chat_session.dart'
    as _i927;
import '../../features/claude/domain/usecases/export_chat_session.dart'
    as _i691;
import '../../features/claude/domain/usecases/list_mcp_servers.dart' as _i977;
import '../../features/claude/domain/usecases/load_chat_history.dart' as _i1009;
import '../../features/claude/domain/usecases/load_session_messages.dart'
    as _i992;
import '../../features/claude/domain/usecases/refresh_sessions_index.dart'
    as _i374;
import '../../features/claude/domain/usecases/search_sessions.dart' as _i73;
import '../../features/claude/domain/usecases/send_prompt.dart' as _i338;
import '../../features/claude/domain/usecases/stop_run.dart' as _i328;
import '../../features/claude/domain/usecases/toggle_mcp_server.dart' as _i920;
import '../../features/claude/presentation/cubit/chat_history_cubit.dart'
    as _i285;
import '../../features/claude/presentation/cubit/claude_sessions_cubit.dart'
    as _i838;
import '../../features/editor/data/datasources/file_content_datasource.dart'
    as _i630;
import '../../features/editor/data/datasources/file_tabs_persistence_datasource.dart'
    as _i283;
import '../../features/editor/data/repositories/file_content_repository_impl.dart'
    as _i574;
import '../../features/editor/domain/repositories/file_content_repository.dart'
    as _i1043;
import '../../features/editor/domain/usecases/read_file.dart' as _i622;
import '../../features/editor/presentation/cubit/active_editor_cubit.dart'
    as _i207;
import '../../features/editor/presentation/cubit/editor_view_cubit.dart'
    as _i465;
import '../../features/editor/presentation/cubit/file_tabs_cubit.dart' as _i648;
import '../../features/explorer/data/datasources/file_system_datasource.dart'
    as _i12;
import '../../features/explorer/data/repositories/file_system_repository_impl.dart'
    as _i890;
import '../../features/explorer/domain/repositories/file_system_repository.dart'
    as _i150;
import '../../features/explorer/domain/usecases/list_directory.dart' as _i308;
import '../../features/explorer/presentation/cubit/explorer_cubit.dart'
    as _i188;
import '../../features/git/data/datasources/git_worktree_datasource.dart'
    as _i203;
import '../../features/git/data/repositories/git_repository_impl.dart' as _i633;
import '../../features/git/domain/repositories/git_repository.dart' as _i241;
import '../../features/git/domain/usecases/delete_branch.dart' as _i933;
import '../../features/git/domain/usecases/detect_git_repo.dart' as _i76;
import '../../features/git/domain/usecases/list_worktrees.dart' as _i795;
import '../../features/git/domain/usecases/remove_worktree.dart' as _i98;
import '../../features/shell/presentation/cubit/shell_cubit.dart' as _i68;
import '../../features/slash_commands/data/datasources/commands_discovery_datasource.dart'
    as _i986;
import '../../features/slash_commands/data/datasources/slash_commands_fs_datasource.dart'
    as _i143;
import '../../features/slash_commands/data/repositories/slash_commands_repository_impl.dart'
    as _i773;
import '../../features/slash_commands/domain/repositories/slash_commands_repository.dart'
    as _i266;
import '../../features/slash_commands/domain/usecases/filter_slash_commands.dart'
    as _i679;
import '../../features/slash_commands/domain/usecases/load_slash_commands.dart'
    as _i676;
import '../../features/slash_commands/presentation/cubit/slash_commands_cubit.dart'
    as _i742;
import '../../features/terminal/data/datasources/pty_datasource.dart' as _i216;
import '../../features/terminal/data/datasources/pty_datasource_impl.dart'
    as _i96;
import '../../features/terminal/presentation/cubit/terminal_sessions_cubit.dart'
    as _i916;
import '../../features/workspace/data/datasources/workspace_file_watcher.dart'
    as _i167;
import '../../features/workspace/data/datasources/workspace_local_datasource.dart'
    as _i735;
import '../../features/workspace/data/datasources/workspaces_persistence_datasource.dart'
    as _i420;
import '../../features/workspace/data/repositories/workspace_repository_impl.dart'
    as _i824;
import '../../features/workspace/domain/repositories/workspace_repository.dart'
    as _i268;
import '../../features/workspace/domain/usecases/load_claude_md.dart' as _i268;
import '../../features/workspace/domain/usecases/open_workspace.dart' as _i305;
import '../../features/workspace/presentation/cubit/workspaces_cubit.dart'
    as _i179;
import '../macos/screenshot_service.dart' as _i656;
import '../persistence/key_value_store.dart' as _i494;
import '../router/app_router.dart' as _i81;
import '../window/app_lifecycle_listener.dart' as _i851;
import 'modules/app_logs_database_module.dart' as _i436;
import 'modules/bloc_observer_module.dart' as _i596;
import 'modules/database_module.dart' as _i664;
import 'modules/preferences_module.dart' as _i329;
import 'modules/router_module.dart' as _i322;
import 'modules/talker_module.dart' as _i185;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final preferencesModule = _$PreferencesModule();
    final appLogsDatabaseModule = _$AppLogsDatabaseModule();
    final databaseModule = _$DatabaseModule();
    final routerModule = _$RouterModule();
    final talkerModule = _$TalkerModule();
    final blocObserverModule = _$BlocObserverModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => preferencesModule.sharedPreferences,
      preResolve: true,
    );
    gh.factory<_i679.FilterSlashCommands>(() => _i679.FilterSlashCommands());
    await gh.lazySingletonAsync<_i126.AppLogsDatabase>(
      () => appLogsDatabaseModule.appLogsDatabase(),
      preResolve: true,
    );
    await gh.lazySingletonAsync<_i1060.SessionsDatabase>(
      () => databaseModule.sessionsDatabase(),
      preResolve: true,
    );
    gh.lazySingleton<_i81.AppRouter>(() => routerModule.router);
    gh.lazySingleton<_i207.Talker>(() => talkerModule.talker);
    gh.lazySingleton<_i207.ActiveEditorCubit>(() => _i207.ActiveEditorCubit());
    gh.lazySingleton<_i68.ShellCubit>(() => _i68.ShellCubit());
    gh.lazySingleton<_i644.AppLogsRepository>(
      () => _i413.AppLogsRepositoryImpl(gh<_i126.AppLogsDatabase>()),
    );
    gh.lazySingleton<_i216.PtyDataSource>(
      () => _i96.PtyDataSourceImpl(gh<_i207.Talker>()),
    );
    gh.lazySingleton<_i735.WorkspaceLocalDataSource>(
      () => _i735.WorkspaceLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i167.WorkspaceFileWatcher>(
      () => _i167.WorkspaceFileWatcherImpl(gh<_i207.Talker>()),
    );
    gh.lazySingleton<_i419.TalkerLogRecorder>(
      () => _i419.TalkerLogRecorder(
        gh<_i207.Talker>(),
        gh<_i644.AppLogsRepository>(),
      ),
    );
    gh.lazySingleton<_i851.AppLifecycleListener>(
      () => _i851.AppLifecycleListener(
        gh<_i419.TalkerLogRecorder>(),
        gh<_i644.AppLogsRepository>(),
        gh<_i207.Talker>(),
      ),
    );
    gh.lazySingleton<_i630.FileContentDataSource>(
      () => _i630.FileContentDataSourceImpl(),
    );
    gh.lazySingleton<_i656.ScreenshotService>(
      () => _i656.ScreenshotService(gh<_i207.Talker>()),
    );
    gh.lazySingleton<_i1073.ClaudeBinaryResolver>(
      () => _i1073.ClaudeBinaryResolver(gh<_i207.Talker>()),
    );
    gh.lazySingleton<_i203.GitWorktreeDataSource>(
      () => _i203.GitWorktreeDataSource(gh<_i207.Talker>()),
    );
    gh.lazySingleton<_i986.CommandsDiscoveryDataSource>(
      () => _i986.CommandsDiscoveryDataSource(gh<_i207.Talker>()),
    );
    gh.lazySingleton<_i143.SlashCommandsFsDataSource>(
      () => _i143.SlashCommandsFsDataSource(gh<_i207.Talker>()),
    );
    gh.lazySingleton<_i331.BlocObserver>(
      () => blocObserverModule.blocObserver(gh<_i207.Talker>()),
    );
    gh.lazySingleton<_i266.SlashCommandsRepository>(
      () => _i773.SlashCommandsRepositoryImpl(
        gh<_i143.SlashCommandsFsDataSource>(),
        gh<_i986.CommandsDiscoveryDataSource>(),
        gh<_i1073.ClaudeBinaryResolver>(),
      ),
    );
    gh.factory<_i676.LoadSlashCommands>(
      () => _i676.LoadSlashCommands(gh<_i266.SlashCommandsRepository>()),
    );
    gh.lazySingleton<_i278.ClaudeHistoryDataSource>(
      () => _i278.ClaudeHistoryDataSourceImpl(gh<_i207.Talker>()),
    );
    gh.lazySingleton<_i12.FileSystemDataSource>(
      () => _i12.FileSystemDataSourceImpl(),
    );
    gh.lazySingleton<_i494.KeyValueStore>(
      () => _i494.SharedPreferencesKeyValueStore(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i1043.FileContentRepository>(
      () => _i574.FileContentRepositoryImpl(gh<_i630.FileContentDataSource>()),
    );
    gh.factory<_i622.ReadFile>(
      () => _i622.ReadFile(gh<_i1043.FileContentRepository>()),
    );
    gh.lazySingleton<_i627.SessionsIndexDataSource>(
      () => _i627.SessionsIndexDataSourceImpl(
        gh<_i1060.SessionsDatabase>(),
        gh<_i278.ClaudeHistoryDataSource>(),
      ),
    );
    gh.factory<_i609.DeleteSession>(
      () => _i609.DeleteSession(gh<_i644.AppLogsRepository>()),
    );
    gh.factory<_i847.EndAppSession>(
      () => _i847.EndAppSession(gh<_i644.AppLogsRepository>()),
    );
    gh.factory<_i894.PruneOldSessions>(
      () => _i894.PruneOldSessions(gh<_i644.AppLogsRepository>()),
    );
    gh.factory<_i647.StartAppSession>(
      () => _i647.StartAppSession(gh<_i644.AppLogsRepository>()),
    );
    gh.factory<_i953.WatchLogSessions>(
      () => _i953.WatchLogSessions(gh<_i644.AppLogsRepository>()),
    );
    gh.factory<_i41.WatchSessionEntries>(
      () => _i41.WatchSessionEntries(gh<_i644.AppLogsRepository>()),
    );
    gh.lazySingleton<_i340.McpListDataSource>(
      () => _i340.McpListDataSource(
        gh<_i207.Talker>(),
        gh<_i1073.ClaudeBinaryResolver>(),
      ),
    );
    gh.lazySingleton<_i583.SidecarTransport>(
      () => _i583.StdioSidecarTransport(
        gh<_i207.Talker>(),
        gh<_i1073.ClaudeBinaryResolver>(),
      ),
    );
    gh.lazySingleton<_i283.FileTabsPersistenceDataSource>(
      () => _i283.FileTabsPersistenceDataSourceImpl(
        gh<_i494.KeyValueStore>(),
        gh<_i207.Talker>(),
      ),
    );
    gh.lazySingleton<_i150.FileSystemRepository>(
      () => _i890.FileSystemRepositoryImpl(gh<_i12.FileSystemDataSource>()),
    );
    gh.lazySingleton<_i241.GitRepository>(
      () => _i633.GitRepositoryImpl(gh<_i203.GitWorktreeDataSource>()),
    );
    gh.factory<_i742.SlashCommandsCubit>(
      () => _i742.SlashCommandsCubit(
        gh<_i676.LoadSlashCommands>(),
        gh<_i679.FilterSlashCommands>(),
        gh<_i207.Talker>(),
      ),
    );
    gh.lazySingleton<_i585.McpRepository>(
      () => _i629.McpRepositoryImpl(gh<_i340.McpListDataSource>()),
    );
    gh.lazySingleton<_i420.WorkspacesPersistenceDataSource>(
      () => _i420.WorkspacesPersistenceDataSourceImpl(
        gh<_i494.KeyValueStore>(),
        gh<_i207.Talker>(),
      ),
    );
    gh.lazySingleton<_i268.WorkspaceRepository>(
      () => _i824.WorkspaceRepositoryImpl(
        gh<_i735.WorkspaceLocalDataSource>(),
        gh<_i241.GitRepository>(),
      ),
    );
    gh.lazySingleton<_i875.ChatHistoryRepository>(
      () => _i682.ChatHistoryRepositoryImpl(
        gh<_i627.SessionsIndexDataSource>(),
        gh<_i278.ClaudeHistoryDataSource>(),
        gh<_i207.Talker>(),
      ),
    );
    gh.factory<_i933.DeleteBranch>(
      () => _i933.DeleteBranch(gh<_i241.GitRepository>()),
    );
    gh.factory<_i76.DetectGitRepo>(
      () => _i76.DetectGitRepo(gh<_i241.GitRepository>()),
    );
    gh.factory<_i795.ListWorktrees>(
      () => _i795.ListWorktrees(gh<_i241.GitRepository>()),
    );
    gh.factory<_i98.RemoveWorktree>(
      () => _i98.RemoveWorktree(gh<_i241.GitRepository>()),
    );
    gh.factory<_i927.DeleteChatSession>(
      () => _i927.DeleteChatSession(gh<_i875.ChatHistoryRepository>()),
    );
    gh.factory<_i691.ExportChatSession>(
      () => _i691.ExportChatSession(gh<_i875.ChatHistoryRepository>()),
    );
    gh.factory<_i1009.LoadChatHistory>(
      () => _i1009.LoadChatHistory(gh<_i875.ChatHistoryRepository>()),
    );
    gh.factory<_i992.LoadSessionMessages>(
      () => _i992.LoadSessionMessages(gh<_i875.ChatHistoryRepository>()),
    );
    gh.factory<_i374.RefreshSessionsIndex>(
      () => _i374.RefreshSessionsIndex(gh<_i875.ChatHistoryRepository>()),
    );
    gh.factory<_i73.SearchSessions>(
      () => _i73.SearchSessions(gh<_i875.ChatHistoryRepository>()),
    );
    gh.lazySingleton<_i148.AppLogsCubit>(
      () => _i148.AppLogsCubit(
        gh<_i953.WatchLogSessions>(),
        gh<_i609.DeleteSession>(),
        gh<_i644.AppLogsRepository>(),
      )..init(),
    );
    gh.lazySingleton<_i330.SidecarClientDataSource>(
      () => _i330.SidecarClientDataSource(
        gh<_i583.SidecarTransport>(),
        gh<_i207.Talker>(),
      ),
    );
    gh.factory<_i977.ListMcpServers>(
      () => _i977.ListMcpServers(gh<_i585.McpRepository>()),
    );
    gh.factory<_i268.LoadClaudeMd>(
      () => _i268.LoadClaudeMd(gh<_i268.WorkspaceRepository>()),
    );
    gh.factory<_i305.OpenWorkspace>(
      () => _i305.OpenWorkspace(gh<_i268.WorkspaceRepository>()),
    );
    gh.factory<_i308.ListDirectory>(
      () => _i308.ListDirectory(gh<_i150.FileSystemRepository>()),
    );
    gh.lazySingleton<_i179.WorkspacesCubit>(
      () => _i179.WorkspacesCubit(
        gh<_i305.OpenWorkspace>(),
        gh<_i795.ListWorktrees>(),
        gh<_i98.RemoveWorktree>(),
        gh<_i933.DeleteBranch>(),
        gh<_i420.WorkspacesPersistenceDataSource>(),
        gh<_i167.WorkspaceFileWatcher>(),
        gh<_i207.Talker>(),
      )..init(),
    );
    gh.lazySingleton<_i285.ChatHistoryCubit>(
      () => _i285.ChatHistoryCubit(
        gh<_i1009.LoadChatHistory>(),
        gh<_i992.LoadSessionMessages>(),
        gh<_i374.RefreshSessionsIndex>(),
        gh<_i927.DeleteChatSession>(),
        gh<_i691.ExportChatSession>(),
        gh<_i73.SearchSessions>(),
        gh<_i278.ClaudeHistoryDataSource>(),
        gh<_i179.WorkspacesCubit>(),
        gh<_i207.Talker>(),
      )..init(),
    );
    gh.lazySingleton<_i139.ClaudeRepository>(
      () => _i1009.ClaudeRepositoryImpl(gh<_i330.SidecarClientDataSource>()),
    );
    gh.lazySingleton<_i709.AppLogDetailCubit>(
      () => _i709.AppLogDetailCubit(
        gh<_i41.WatchSessionEntries>(),
        gh<_i148.AppLogsCubit>(),
      )..init(),
    );
    gh.lazySingleton<_i916.TerminalSessionsCubit>(
      () => _i916.TerminalSessionsCubit(
        gh<_i216.PtyDataSource>(),
        gh<_i179.WorkspacesCubit>(),
        gh<_i207.Talker>(),
      )..init(),
    );
    gh.lazySingleton<_i465.EditorViewCubit>(
      () => _i465.EditorViewCubit(gh<_i179.WorkspacesCubit>())..init(),
    );
    gh.factory<_i338.SendPrompt>(
      () => _i338.SendPrompt(gh<_i139.ClaudeRepository>()),
    );
    gh.factory<_i328.StopRun>(
      () => _i328.StopRun(gh<_i139.ClaudeRepository>()),
    );
    gh.lazySingleton<_i648.FileTabsCubit>(
      () => _i648.FileTabsCubit(
        gh<_i179.WorkspacesCubit>(),
        gh<_i283.FileTabsPersistenceDataSource>(),
        gh<_i167.WorkspaceFileWatcher>(),
        gh<_i207.Talker>(),
      )..init(),
    );
    gh.factory<_i407.AuthenticateMcpServer>(
      () => _i407.AuthenticateMcpServer(gh<_i139.ClaudeRepository>()),
    );
    gh.factory<_i920.ToggleMcpServer>(
      () => _i920.ToggleMcpServer(gh<_i139.ClaudeRepository>()),
    );
    gh.lazySingleton<_i838.ClaudeSessionsCubit>(
      () => _i838.ClaudeSessionsCubit(
        gh<_i338.SendPrompt>(),
        gh<_i328.StopRun>(),
        gh<_i977.ListMcpServers>(),
        gh<_i407.AuthenticateMcpServer>(),
        gh<_i992.LoadSessionMessages>(),
        gh<_i278.ClaudeHistoryDataSource>(),
        gh<_i179.WorkspacesCubit>(),
        gh<_i139.ClaudeRepository>(),
        gh<_i460.SharedPreferences>(),
        gh<_i207.Talker>(),
      )..init(),
    );
    gh.lazySingleton<_i188.ExplorerCubit>(
      () => _i188.ExplorerCubit(
        gh<_i308.ListDirectory>(),
        gh<_i622.ReadFile>(),
        gh<_i179.WorkspacesCubit>(),
        gh<_i648.FileTabsCubit>(),
        gh<_i167.WorkspaceFileWatcher>(),
        gh<_i207.Talker>(),
      )..init(),
    );
    return this;
  }
}

class _$PreferencesModule extends _i329.PreferencesModule {}

class _$AppLogsDatabaseModule extends _i436.AppLogsDatabaseModule {}

class _$DatabaseModule extends _i664.DatabaseModule {}

class _$RouterModule extends _i322.RouterModule {}

class _$TalkerModule extends _i185.TalkerModule {}

class _$BlocObserverModule extends _i596.BlocObserverModule {}
