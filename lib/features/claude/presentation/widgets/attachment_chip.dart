import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/chat_attachment.dart';
import 'screenshot_preview_dialog.dart';

class AttachmentChip extends StatelessWidget {
  const AttachmentChip({
    super.key,
    required this.attachment,
    required this.onRemove,
  });

  final ChatAttachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    const color = AppColors.tertiary;
    final isImage = attachment.kind == ChatAttachmentKind.imageCapture;

    final chip = Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      padding: const EdgeInsets.only(
        left: AppSpacing.sm,
        right: AppSpacing.xs,
        top: 2,
        bottom: 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            switch (attachment.kind) {
              ChatAttachmentKind.directory => Symbols.folder,
              ChatAttachmentKind.fileRange => Symbols.code,
              ChatAttachmentKind.imageCapture => Symbols.add_a_photo,
              ChatAttachmentKind.file => Symbols.description,
            },
            size: 12,
            color: color,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            attachment.displayName,
            style: AppTypography.terminalCode.copyWith(
              fontSize: 12,
              color: color,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          _RemoveButton(color: color, onTap: onRemove),
        ],
      ),
    );

    final interactive = isImage
        ? MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => showDialog<void>(
                context: context,
                builder: (_) => ScreenshotPreviewDialog(
                  imagePath: attachment.path,
                  viewOnly: true,
                ),
              ),
              child: chip,
            ),
          )
        : chip;

    return Tooltip(
      message: attachment.path,
      waitDuration: const Duration(milliseconds: 400),
      child: interactive,
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.color, required this.onTap});

  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: Locales.Claude.Terminal.Input.Attachments.removeTooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(Symbols.close, size: 12, color: color),
          ),
        ),
      ),
    );
  }
}
