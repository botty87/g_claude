import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Bridges Cmd+V keystrokes intercepted by [MainFlutterWindow] (macOS) to
/// Flutter's [PasteTextIntent]. Workaround for synthetic CGEventPost paste
/// events being dropped by the Flutter macOS embedder
/// (flutter/flutter#107296 and friends).
class MacosPasteBridge {
  MacosPasteBridge._();
  static final instance = MacosPasteBridge._();

  static const _channel = MethodChannel('clyde/macos_paste');

  void start() {
    if (!Platform.isMacOS) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method != 'paste') return;
      final ctx = FocusManager.instance.primaryFocus?.context;
      if (ctx == null) return;
      Actions.maybeInvoke<PasteTextIntent>(
        ctx,
        const PasteTextIntent(SelectionChangedCause.keyboard),
      );
    });
  }
}
