import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../theme/app_colors.dart';

/// Initializes the desktop window: title, default size, min size, centering.
///
/// The native title bar is hidden so the dark app surface extends edge-to-edge;
/// the macOS traffic lights stay visible and float over the custom title strip
/// rendered by the shell.
Future<void> setupWindow() async {
  await windowManager.ensureInitialized();

  const options = WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(500, 400),
    center: true,
    title: 'Clyde',
    backgroundColor: AppColors.surfaceContainerLowest,
    titleBarStyle: TitleBarStyle.hidden,
  );

  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.setBackgroundColor(AppColors.surfaceContainerLowest);
    await windowManager.show();
    await windowManager.focus();
  });
}
