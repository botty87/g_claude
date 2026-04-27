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
    gh.lazySingleton<_i331.BlocObserver>(
      () => blocObserverModule.blocObserver(gh<_i207.Talker>()),
    );
    return this;
  }
}

class _$RouterModule extends _i322.RouterModule {}

class _$TalkerModule extends _i185.TalkerModule {}

class _$BlocObserverModule extends _i596.BlocObserverModule {}
