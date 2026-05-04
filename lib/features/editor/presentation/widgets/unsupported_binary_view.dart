import 'dart:io';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' as p;
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../core/di/di.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class UnsupportedBinaryView extends StatelessWidget {
  const UnsupportedBinaryView({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final filename = p.basename(path);
    final ext = p.extension(path).toLowerCase();
    final size = _fileSizeLabel(path);

    return Container(
      color: AppColors.surface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.sm,
          children: [
            Icon(
              _iconFor(ext),
              size: 48,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            Text(
              filename,
              style: AppTypography.bodyMain.copyWith(color: AppColors.onSurface),
              textAlign: TextAlign.center,
            ),
            if (size != null)
              Text(
                size,
                style: AppTypography.bodyMain.copyWith(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              Locales.Editor.Unsupported.title,
              style: AppTypography.bodyMain.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xs),
            FilledButton.tonal(
              onPressed: () => _revealInFinder(path),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 6,
                children: [
                  const Icon(Symbols.folder_open, size: 16),
                  Text(Locales.Editor.Unsupported.revealInFinder),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _fileSizeLabel(String path) {
    try {
      final bytes = File(path).statSync().size;
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return null;
    }
  }

  IconData _iconFor(String ext) {
    return switch (ext) {
      '.zip' || '.gz' || '.tar' || '.bz2' || '.7z' || '.rar' => Symbols.folder_zip,
      '.mp3' || '.flac' || '.wav' => Symbols.audio_file,
      '.mp4' || '.mov' || '.avi' || '.mkv' => Symbols.video_file,
      '.db' || '.sqlite' || '.sqlite3' => Symbols.database,
      '.ttf' || '.otf' || '.woff' || '.woff2' => Symbols.font_download,
      _ => Symbols.insert_drive_file,
    };
  }

  void _revealInFinder(String path) {
    Process.run('open', ['-R', path]).catchError((Object e) {
      getIt<Talker>().error('UnsupportedBinaryView: reveal in Finder failed', e);
      return ProcessResult(0, 1, '', e.toString());
    });
  }
}
