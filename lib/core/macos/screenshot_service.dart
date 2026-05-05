import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import '../error/failures.dart';
import '../utils/either.dart';

enum ScreenshotCaptureMode { fullScreen, region, window }

@lazySingleton
class ScreenshotService {
  Future<Either<Failure, String>> capture(
    ScreenshotCaptureMode mode, {
    int? displayIndex,
  }) async {
    try {
      final tmpDir = await getTemporaryDirectory();
      final id = DateTime.now().millisecondsSinceEpoch;
      final pngPath = '${tmpDir.path}/screenshot_$id.png';

      final args = switch (mode) {
        ScreenshotCaptureMode.fullScreen => [
            if (displayIndex != null) ...['-D', '$displayIndex'],
            '-t', 'png', pngPath,
          ],
        ScreenshotCaptureMode.region => ['-i', '-t', 'png', pngPath],
        ScreenshotCaptureMode.window => ['-i', '-w', '-t', 'png', pngPath],
      };

      await Process.run('screencapture', args);

      if (!File(pngPath).existsSync()) {
        return const Left(SubprocessFailure(message: 'screenshot_cancelled'));
      }

      final jpegPath = await _compressToJpeg(pngPath);
      return Right(jpegPath);
    } catch (e) {
      return Left(UnexpectedFailure('$e'));
    }
  }

  Future<String> _compressToJpeg(String pngPath) async {
    final tmpDir = await getTemporaryDirectory();
    final id = DateTime.now().millisecondsSinceEpoch;
    final jpegPath = '${tmpDir.path}/screenshot_${id}_c.jpg';

    // Resample so the longer side is at most 1920px (proportional).
    await Process.run('sips', ['-Z', '1920', pngPath]);

    // Convert to JPEG at 75% quality.
    await Process.run('sips', [
      '-s', 'formatOptions', '75',
      '-s', 'format', 'jpeg',
      pngPath,
      '--out', jpegPath,
    ]);

    try {
      await File(pngPath).delete();
    } catch (_) {}

    return jpegPath;
  }
}
