import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../../domain/entities/claude_permission_mode.dart';

class PermissionPicker extends StatelessWidget {
  const PermissionPicker({
    super.key,
    required this.current,
    required this.onSelected,
    this.enabled = true,
  });

  final ClaudePermissionMode current;
  final ValueChanged<ClaudePermissionMode> onSelected;
  final bool enabled;

  IconData _iconFor(ClaudePermissionMode m) {
    switch (m) {
      case ClaudePermissionMode.plan:
        return Symbols.visibility;
      case ClaudePermissionMode.acceptEdits:
        return Symbols.edit_note;
      case ClaudePermissionMode.bypassPermissions:
        return Symbols.bolt;
      case ClaudePermissionMode.defaultMode:
        return Symbols.shield;
    }
  }

  Color _colorFor(ClaudePermissionMode m) {
    switch (m) {
      case ClaudePermissionMode.plan:
        return AppColors.secondary;
      case ClaudePermissionMode.acceptEdits:
        return AppColors.primary;
      case ClaudePermissionMode.bypassPermissions:
        return AppColors.tertiary;
      case ClaudePermissionMode.defaultMode:
        return AppColors.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'claude.terminal.permission.tooltip'.tr(),
      child: Hoverable(
        key: const ValueKey('claude_permission_picker'),
        onTap: enabled ? () => _showMenu(context) : null,
        builder: (context, hover) {
          return Container(
            height: 24,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: hover ? AppColors.glassHover : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.outlineVariant,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_iconFor(current),
                    size: 12, color: _colorFor(current)),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  current.labelKey.tr(),
                  style: AppTypography.bodyMain.copyWith(
                    fontSize: 11,
                    color: enabled
                        ? AppColors.onSurface
                        : AppColors.outline,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(Symbols.expand_more,
                    size: 12, color: AppColors.onSurfaceVariant),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;
    final position = RelativeRect.fromLTRB(
      offset.dx,
      offset.dy + size.height + 4,
      offset.dx + size.width,
      offset.dy + size.height + 4,
    );

    showMenu<ClaudePermissionMode>(
      context: context,
      position: position,
      color: AppColors.surfaceContainerHigh,
      items: [
        for (final m in ClaudePermissionMode.values)
          PopupMenuItem<ClaudePermissionMode>(
            value: m,
            mouseCursor: SystemMouseCursors.click,
            child: Row(
              children: [
                Icon(
                  m == current ? Symbols.check : _iconFor(m),
                  size: 14,
                  color: m == current
                      ? AppColors.brandIndigo
                      : _colorFor(m),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  m.labelKey.tr(),
                  style: AppTypography.bodyMain.copyWith(
                    fontSize: 12,
                    fontWeight:
                        m == current ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
      ],
    ).then((value) {
      if (value != null && value != current) onSelected(value);
    });
  }
}
