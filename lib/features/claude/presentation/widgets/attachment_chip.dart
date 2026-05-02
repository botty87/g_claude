import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/chat_attachment.dart';

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

    return Tooltip(
      message: attachment.path,
      waitDuration: const Duration(milliseconds: 400),
      child: Container(
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
              attachment.kind == ChatAttachmentKind.directory
                  ? Symbols.folder
                  : Symbols.description,
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
      ),
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
      message: 'claude.terminal.input.attachments.removeTooltip'.tr(),
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
