import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'app.dart';
import 'core/di/di.dart';
import 'core/marionette/marionette_log_bridge.dart';
import 'core/window/window_setup.dart';
import 'features/editor/domain/usecases/read_file.dart';
import 'features/editor/presentation/cubit/file_tabs_cubit.dart';
import 'features/explorer/presentation/cubit/explorer_cubit.dart';
import 'features/workspace/presentation/cubit/workspaces_cubit.dart';

Future<void> main() async {
  // Marionette debug-only AI agent driver. Tree-shaken in release; skipped
  // under flutter_test where TestWidgetsFlutterBinding owns the binding.
  const inFlutterTest = bool.hasEnvironment('FLUTTER_TEST');
  const marionetteEnabled = kDebugMode && !inFlutterTest;

  PrintLogCollector? marionetteLogCollector;
  if (marionetteEnabled) {
    marionetteLogCollector = PrintLogCollector();
    MarionetteBinding.ensureInitialized(MarionetteConfiguration(logCollector: marionetteLogCollector));
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }

  await Future.wait([
    EasyLocalization.ensureInitialized(),
    setupWindow(),
    configureDependencies(),
  ]);

  // Forward Talker stream to Marionette before Bloc.observer attaches so the
  // log bridge captures Bloc transitions emitted by TalkerBlocObserver too.
  if (marionetteEnabled && marionetteLogCollector != null) {
    MarionetteLogBridge(talker: getIt<Talker>(), collector: marionetteLogCollector).start();
  }

  // Restore persisted state before BlocObserver attaches to avoid logging
  // restore emissions as user-driven transitions. Workspaces first — file tabs
  // filter against alive workspace ids on restore.
  final workspacesCubit = getIt<WorkspacesCubit>();
  final fileTabsCubit = getIt<FileTabsCubit>();
  await workspacesCubit.restore();
  await fileTabsCubit.restore();

  // Pre-warm explorer trees and file contents for each workspace's open tabs
  // so the first click after restart does not pay disk I/O. Fire-and-forget.
  final explorerCubit = getIt<ExplorerCubit>();
  final readFile = getIt<ReadFile>();
  for (final workspace in workspacesCubit.state.workspacesOrEmpty) {
    final files = fileTabsCubit.state.filesFor(workspace.id);
    if (files == null) continue;
    final activePath = files.activePath;
    if (activePath != null) {
      unawaited(explorerCubit.prewarmReveal(workspace.id, workspace.path, activePath));
    }
    for (final path in files.openPaths) {
      unawaited(readFile(path: path));
    }
  }

  Bloc.observer = getIt<BlocObserver>();

  if (marionetteEnabled) {
    _registerWorkspaceCubitExtension(
      name: 'openWorkspace',
      description: 'Test-only: opens a workspace by absolute path, bypassing the native picker.',
      paramKey: 'path',
      handler: (cubit, value) => cubit.openPath(value),
    );
    _registerWorkspaceCubitExtension(
      name: 'closeWorkspace',
      description: 'Test-only: closes a workspace by id (absolute path).',
      paramKey: 'id',
      handler: (cubit, value) async => cubit.closeWorkspace(value),
    );
    _registerWorkspaceCubitExtension(
      name: 'setActiveWorkspace',
      description: 'Test-only: sets the active workspace by id.',
      paramKey: 'id',
      handler: (cubit, value) async => cubit.setActive(value),
    );
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('it')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      useOnlyLangCode: true,
      child: App(),
    ),
  );
}

void _registerWorkspaceCubitExtension({
  required String name,
  required String description,
  required String paramKey,
  required Future<void> Function(WorkspacesCubit cubit, String value) handler,
}) {
  registerMarionetteExtension(
    name: name,
    description: description,
    callback: (params) async {
      final value = params[paramKey];
      if (value == null || value.isEmpty) {
        return MarionetteExtensionResult.invalidParams('Missing "$paramKey"');
      }
      await handler(getIt<WorkspacesCubit>(), value);
      return const MarionetteExtensionResult.success({'ok': true});
    },
  );
}
