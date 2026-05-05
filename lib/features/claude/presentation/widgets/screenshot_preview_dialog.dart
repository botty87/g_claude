import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class ScreenshotPreviewDialog extends StatelessWidget {
  const ScreenshotPreviewDialog({
    super.key,
    required this.imagePath,
    this.viewOnly = false,
  });

  final String imagePath;
  final bool viewOnly;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                Locales.Claude.Terminal.Input.Attachments.screenshotPreviewTitle,
                style: AppTypography.bodyMain.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                    cacheWidth: 1720,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: viewOnly
                    ? [
                        FilledButton(
                          style: FilledButton.styleFrom(
                            enabledMouseCursor: SystemMouseCursors.click,
                          ),
                          onPressed: () =>
                              Navigator.of(context).pop(false),
                          child: Text(
                            Locales.Claude.Terminal.Input.Attachments
                                .screenshotPreviewClose,
                          ),
                        ),
                      ]
                    : [
                        TextButton(
                          style: TextButton.styleFrom(
                            enabledMouseCursor: SystemMouseCursors.click,
                          ),
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            Locales.Claude.Terminal.Input.Attachments.screenshotPreviewDiscard,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            enabledMouseCursor: SystemMouseCursors.click,
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(
                            Locales.Claude.Terminal.Input.Attachments.screenshotPreviewAttach,
                          ),
                        ),
                      ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
