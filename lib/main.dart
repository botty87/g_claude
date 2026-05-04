import 'dart:async';
import 'dart:io' show Platform;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide AppLifecycleListener;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'app.dart';
import 'core/di/di.dart';
import 'core/l10n/l10n.dart';
import 'core/macos/macos_paste_bridge.dart';
import 'core/marionette/marionette_log_bridge.dart';
import 'core/window/app_lifecycle_listener.dart';
import 'core/window/window_setup.dart';
import 'features/app_logs/data/datasources/talker_log_recorder.dart';
import 'features/app_logs/domain/repositories/app_logs_repository.dart';
import 'features/editor/domain/usecases/read_file.dart';
import 'features/editor/presentation/cubit/file_tabs_cubit.dart';
import 'features/explorer/presentation/cubit/explorer_cubit.dart';
import 'features/workspace/domain/entities/workspace.dart';
import 'features/workspace/presentation/cubit/workspaces_cubit.dart';

Future<void> main() async {
  // Single zone for the whole app: bindings AND runApp must share the same
  // zone, otherwise Flutter logs a "Zone mismatch". Talker is wired post-DI,
  // so the zone error handler reads it lazily from getIt at firing time.
  runZonedGuarded(_run, (error, stack) {
    if (getIt.isRegistered<Talker>()) {
      getIt<Talker>().handle(error, stack, 'Zone');
    }
  });
}

Future<void> _run() async {
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

  MacosPasteBridge.instance.start();

  await Future.wait([
    EasyLocalization.ensureInitialized(),
    setupWindow(),
    configureDependencies(),
  ]);

  final talker = getIt<Talker>();

  // Start the app-logs session BEFORE attaching subscribers so every Talker
  // event during startup is bound to a session row in the DB.
  final appLogsRepo = getIt<AppLogsRepository>();
  await appLogsRepo.startSession(platform: Platform.operatingSystem);
  await appLogsRepo.pruneOlderThan(const Duration(days: 30));
  getIt<TalkerLogRecorder>().start();
  await getIt<AppLifecycleListener>().attach();

  // Route uncaught Flutter / async / zone errors through Talker so the recorder
  // persists them with full stack trace.
  FlutterError.onError = (details) {
    talker.handle(details.exception, details.stack, 'FlutterError');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    talker.handle(error, stack, 'PlatformDispatcher');
    return true;
  };

  // Forward Talker stream to Marionette before Bloc.observer attaches so the
  // log bridge captures Bloc transitions emitted by TalkerBlocObserver too.
  if (marionetteEnabled && marionetteLogCollector != null) {
    MarionetteLogBridge(talker: talker, collector: marionetteLogCollector).start();
  }

  // Restore persisted state before BlocObserver attaches to avoid logging
  // restore emissions as user-driven transitions. Workspaces first — file tabs
  // filter against alive workspace ids on restore.
  final workspacesCubit = getIt<WorkspacesCubit>();
  final fileTabsCubit = getIt<FileTabsCubit>();
  await workspacesCubit.restore();
  await fileTabsCubit.restore();

  // Defer prewarm until after first frame so I/O does not contend with paint.
  // Throttled to _prewarmConcurrency so a heavy restore (many tabs × many
  // workspaces) does not flood the event loop with concurrent disk reads.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_prewarmPersistedTabs(
      workspaces: workspacesCubit,
      fileTabs: fileTabsCubit,
      explorer: getIt<ExplorerCubit>(),
      readFile: getIt<ReadFile>(),
    ));
  });

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
      supportedLocales: Locales.supportedLocales,
      path: 'assets/translations',
      fallbackLocale: Locales.fallbackLocale,
      useOnlyLangCode: true,
      child: App(),
    ),
  );
}

const _prewarmConcurrency = 4;

Future<void> _prewarmPersistedTabs({
  required WorkspacesCubit workspaces,
  required FileTabsCubit fileTabs,
  required ExplorerCubit explorer,
  required ReadFile readFile,
}) async {
  final reveals = <(WorkspaceId, String, String)>[];
  final reads = <String>{};
  for (final workspace in workspaces.state.workspacesOrEmpty) {
    final files = fileTabs.state.filesFor(workspace.id);
    if (files == null) continue;
    final activePath = files.activePath;
    if (activePath != null) {
      reveals.add((workspace.id, workspace.path, activePath));
    }
    reads.addAll(files.openPaths);
  }

  for (final (id, root, target) in reveals) {
    unawaited(explorer.prewarmReveal(id, root, target));
  }

  final queue = reads.toList();
  Future<void> worker() async {
    while (queue.isNotEmpty) {
      final path = queue.removeLast();
      await readFile(path: path);
    }
  }

  await Future.wait(
    List.generate(_prewarmConcurrency, (_) => worker()),
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
