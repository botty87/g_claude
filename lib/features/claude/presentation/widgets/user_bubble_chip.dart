import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/chat_attachment.dart';

class BubbleSlashChip extends StatelessWidget {
  const BubbleSlashChip({super.key, required this.trigger});

  final String trigger;

  @override
  Widget build(BuildContext context) {
    const color = AppColors.primary;
    return _ChipShell(color: color, icon: Symbols.bolt, label: trigger);
  }
}

class BubbleAttachmentChip extends StatelessWidget {
  const BubbleAttachmentChip({super.key, required this.attachment});

  final ChatAttachment attachment;

  @override
  Widget build(BuildContext context) {
    const color = AppColors.tertiary;
    final icon = switch (attachment.kind) {
      ChatAttachmentKind.directory => Symbols.folder,
      ChatAttachmentKind.fileRange => Symbols.code,
      ChatAttachmentKind.imageCapture => Symbols.add_a_photo,
      ChatAttachmentKind.file => Symbols.description,
    };
    return Tooltip(
      message: attachment.path,
      waitDuration: const Duration(milliseconds: 400),
      child: _ChipShell(color: color, icon: icon, label: attachment.displayName),
    );
  }
}

class _ChipShell extends StatelessWidget {
  const _ChipShell({required this.color, required this.icon, required this.label});

  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTypography.terminalCode.copyWith(fontSize: 10.5, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
