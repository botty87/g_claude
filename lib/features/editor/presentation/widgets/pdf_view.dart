import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class PdfView extends StatelessWidget {
  const PdfView({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: PdfViewer.file(
        path,
        params: PdfViewerParams(
          backgroundColor: AppColors.surfaceContainerLowest,
          errorBannerBuilder: (context, error, stackTrace, documentRef) =>
              _ErrorView(),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Symbols.error_outline, color: AppColors.error, size: 32),
          const SizedBox(height: 8),
          Text(
            Locales.Editor.Pdf.loadError,
            style: AppTypography.bodyMain.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
