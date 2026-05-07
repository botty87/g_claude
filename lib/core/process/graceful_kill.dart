import 'dart:io';

/// Politely terminate a child process: SIGTERM, wait up to [graceTimeout],
/// then SIGKILL if it is still alive. Both `dart:io` `Process` and
/// `flutter_pty` `Pty` expose the same `kill(ProcessSignal)` and
/// `exitCode: Future<int>` shape, so the helper takes the bare callable
/// pieces instead of a typed handle.
Future<void> gracefulKill({
  required void Function(ProcessSignal) kill,
  required Future<int> exitCode,
  Duration graceTimeout = const Duration(seconds: 2),
}) async {
  kill(ProcessSignal.sigterm);
  try {
    await exitCode.timeout(
      graceTimeout,
      onTimeout: () {
        kill(ProcessSignal.sigkill);
        return -1;
      },
    );
  } catch (_) {
    // Process may already be gone; ignore.
  }
}
