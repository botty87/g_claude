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
import 'package:talker_flutter/talker_flutter.dart' as _i207;

import '../../features/explorer/data/datasources/file_system_datasource.dart'
    as _i12;
import '../../features/explorer/data/repositories/file_system_repository_impl.dart'
    as _i890;
import '../../features/explorer/domain/repositories/file_system_repository.dart'
    as _i150;
import '../../features/explorer/domain/usecases/list_directory.dart' as _i308;
import '../../features/explorer/presentation/cubit/explorer_cubit.dart'
    as _i188;
import '../../features/shell/presentation/cubit/shell_cubit.dart' as _i68;
import '../../features/workspace/data/datasources/workspace_local_datasource.dart'
    as _i735;
import '../../features/workspace/data/repositories/workspace_repository_impl.dart'
    as _i824;
import '../../features/workspace/domain/repositories/workspace_repository.dart'
    as _i268;
import '../../features/workspace/domain/usecases/load_claude_md.dart' as _i268;
import '../../features/workspace/domain/usecases/open_workspace.dart' as _i305;
import '../../features/workspace/presentation/cubit/workspaces_cubit.dart'
    as _i179;
import '../router/app_router.dart' as _i81;
import 'modules/bloc_observer_module.dart' as _i596;
import 'modules/router_module.dart' as _i322;
import 'modules/talker_module.dart' as _i185;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final routerModule = _$RouterModule();
    final talkerModule = _$TalkerModule();
    final blocObserverModule = _$BlocObserverModule();
    gh.lazySingleton<_i81.AppRouter>(() => routerModule.router);
    gh.lazySingleton<_i207.Talker>(() => talkerModule.talker);
    gh.lazySingleton<_i68.ShellCubit>(() => _i68.ShellCubit());
    gh.lazySingleton<_i735.WorkspaceLocalDataSource>(
      () => _i735.WorkspaceLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i331.BlocObserver>(
      () => blocObserverModule.blocObserver(gh<_i207.Talker>()),
    );
    gh.lazySingleton<_i12.FileSystemDataSource>(
      () => _i12.FileSystemDataSourceImpl(),
    );
    gh.lazySingleton<_i268.WorkspaceRepository>(
      () => _i824.WorkspaceRepositoryImpl(gh<_i735.WorkspaceLocalDataSource>()),
    );
    gh.factory<_i268.LoadClaudeMd>(
      () => _i268.LoadClaudeMd(gh<_i268.WorkspaceRepository>()),
    );
    gh.factory<_i305.OpenWorkspace>(
      () => _i305.OpenWorkspace(gh<_i268.WorkspaceRepository>()),
    );
    gh.lazySingleton<_i150.FileSystemRepository>(
      () => _i890.FileSystemRepositoryImpl(gh<_i12.FileSystemDataSource>()),
    );
    gh.lazySingleton<_i179.WorkspacesCubit>(
      () =>
          _i179.WorkspacesCubit(gh<_i305.OpenWorkspace>(), gh<_i207.Talker>()),
    );
    gh.factory<_i308.ListDirectory>(
      () => _i308.ListDirectory(gh<_i150.FileSystemRepository>()),
    );
    gh.lazySingleton<_i188.ExplorerCubit>(
      () => _i188.ExplorerCubit(
        gh<_i308.ListDirectory>(),
        gh<_i179.WorkspacesCubit>(),
        gh<_i207.Talker>(),
      )..init(),
    );
    return this;
  }
}

class _$RouterModule extends _i322.RouterModule {}

class _$TalkerModule extends _i185.TalkerModule {}

class _$BlocObserverModule extends _i596.BlocObserverModule {}
