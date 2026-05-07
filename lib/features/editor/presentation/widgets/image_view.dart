import 'dart:io';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class ImageView extends StatelessWidget {
  const ImageView({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: InteractiveViewer(
        minScale: 0.1,
        maxScale: 8,
        child: Center(
          child: Image.file(
            File(path),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => _ErrorView(),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Symbols.broken_image, color: AppColors.error, size: 32),
        const SizedBox(height: 8),
        Text(Locales.Editor.Image.loadError, style: AppTypography.bodyMain.copyWith(color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}
