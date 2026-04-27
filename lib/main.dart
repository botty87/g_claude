import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'app.dart';
import 'core/di/di.dart';
import 'core/marionette/marionette_log_bridge.dart';
import 'core/window/window_setup.dart';

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

  runApp(App());
}
