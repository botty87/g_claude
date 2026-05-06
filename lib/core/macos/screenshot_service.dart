import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../error/failures.dart';
import '../utils/either.dart';

enum ScreenshotCaptureMode { fullScreen, region, window }

@lazySingleton
class ScreenshotService {
  ScreenshotService(this._talker);

  final Talker _talker;

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

      final result = await Process.run('screencapture', args);

      if (result.exitCode != 0) {
        _talker.warning(
          'screencapture exit ${result.exitCode}: ${result.stderr}',
        );
        return const Left(ScreenshotCancelledFailure());
      }
      if (!await File(pngPath).exists()) {
        return const Left(ScreenshotCancelledFailure());
      }

      return Right(await _compressToJpeg(pngPath, id, tmpDir));
    } catch (e, st) {
      _talker.error('Screenshot capture failed', e, st);
      return Left(UnexpectedFailure('$e'));
    }
  }

  Future<void> discard(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (e) {
      _talker.debug('discard tmp screenshot failed: $path ($e)');
    }
  }

  Future<String> _compressToJpeg(
    String pngPath,
    int id,
    Directory tmpDir,
  ) async {
    final jpegPath = '${tmpDir.path}/screenshot_${id}_c.jpg';

    final result = await Process.run('sips', [
      '-Z', '1920',
      '-s', 'formatOptions', '75',
      '-s', 'format', 'jpeg',
      pngPath,
      '--out', jpegPath,
    ]);
    if (result.exitCode != 0) {
      _talker.warning('sips exit ${result.exitCode}: ${result.stderr}');
    }

    unawaited(discard(pngPath));
    return jpegPath;
  }
}
