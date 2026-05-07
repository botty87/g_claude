import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/chat_attachment.dart';
import 'attachment_chip.dart';

class AttachmentChipRow extends StatelessWidget {
  const AttachmentChipRow({super.key, required this.attachments, required this.onRemove});

  final List<ChatAttachment> attachments;
  final ValueChanged<ChatAttachment> onRemove;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainer,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs,
        children: [
          for (final attachment in attachments)
            AttachmentChip(
              key: ValueKey(
                'attachment_chip_${attachment.path.hashCode}_${attachment.startLine ?? 0}_${attachment.endLine ?? 0}',
              ),
              attachment: attachment,
              onRemove: () => onRemove(attachment),
            ),
        ],
      ),
    );
  }
}
