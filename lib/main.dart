import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'app.dart';
import 'core/di/di.dart';
import 'core/marionette/marionette_log_bridge.dart';
import 'core/window/window_setup.dart';
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

  await setupWindow();
  await configureDependencies();

  // Forward Talker stream to Marionette before Bloc.observer attaches so the
  // log bridge captures Bloc transitions emitted by TalkerBlocObserver too.
  if (marionetteEnabled && marionetteLogCollector != null) {
    MarionetteLogBridge(talker: getIt<Talker>(), collector: marionetteLogCollector).start();
  }

  Bloc.observer = getIt<BlocObserver>();

  if (marionetteEnabled) {
    registerMarionetteExtension(
      name: 'openWorkspace',
      description: 'Test-only: opens a workspace by absolute path, bypassing the native picker.',
      callback: (params) async {
        final path = params['path'];
        if (path == null || path.isEmpty) {
          return const MarionetteExtensionResult.invalidParams('Missing "path"');
        }
        await getIt<WorkspacesCubit>().openPath(path);
        return const MarionetteExtensionResult.success({'ok': true});
      },
    );
    registerMarionetteExtension(
      name: 'closeWorkspace',
      description: 'Test-only: closes a workspace by id (absolute path).',
      callback: (params) async {
        final id = params['id'];
        if (id == null || id.isEmpty) {
          return const MarionetteExtensionResult.invalidParams('Missing "id"');
        }
        await getIt<WorkspacesCubit>().closeWorkspace(id);
        return const MarionetteExtensionResult.success({'ok': true});
      },
    );
    registerMarionetteExtension(
      name: 'setActiveWorkspace',
      description: 'Test-only: sets the active workspace by id.',
      callback: (params) async {
        final id = params['id'];
        if (id == null || id.isEmpty) {
          return const MarionetteExtensionResult.invalidParams('Missing "id"');
        }
        getIt<WorkspacesCubit>().setActive(id);
        return const MarionetteExtensionResult.success({'ok': true});
      },
    );
  }

  runApp(App());
}
