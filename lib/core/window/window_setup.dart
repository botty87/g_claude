import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// Initializes the desktop window: title, default size, min size, centering.
Future<void> setupWindow() async {
  await windowManager.ensureInitialized();

  const options = WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(900, 600),
    center: true,
    title: 'Claude Code GUI',
    titleBarStyle: TitleBarStyle.normal,
  );

  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
