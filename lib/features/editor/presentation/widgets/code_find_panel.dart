import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:re_editor/re_editor.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Read-only find panel for [CodeEditor]. Renders nothing when [controller.value]
/// is `null` (panel closed). Activated via Cmd+F / Ctrl+F by re_editor's
/// built-in shortcut wiring.
class CodeFindPanel extends StatelessWidget implements PreferredSizeWidget {
  const CodeFindPanel({super.key, required this.controller});

  final CodeFindController controller;

  static const double _panelHeight = 36;
  static const double _panelWidth = 360;

  @override
  Size get preferredSize => Size(
        double.infinity,
        controller.value == null ? 0 : _panelHeight + 8,
      );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => _buildPanel(context),
    );
  }

  Widget _buildPanel(BuildContext context) {
    final value = controller.value;
    if (value == null) {
      return const SizedBox.shrink();
    }
    final result = value.result;
    final resultText = result == null
        ? 'editor.find.noResults'.tr()
        : '${result.index + 1} / ${result.matches.length}';
    final inputStyle = AppTypography.bodyMain.copyWith(
      fontSize: 13,
      color: AppColors.onSurface,
    );

    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 4),
      child: Align(
        alignment: Alignment.topRight,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          color: AppColors.surfaceContainerLow,
          child: Container(
            width: _panelWidth,
            height: _panelHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(color: AppColors.outlineVariant, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.findInputController,
                    focusNode: controller.findInputFocusNode,
                    autofocus: true,
                    maxLines: 1,
                    style: inputStyle,
                    decoration: InputDecoration(
                      hintText: 'editor.find.hint'.tr(),
                      hintStyle: inputStyle.copyWith(
                        color:
                            AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      isCollapsed: true,
                      border: InputBorder.none,
                    ),
                  ),
                ),
                _ToggleButton(
                  text: 'Aa',
                  active: value.option.caseSensitive,
                  tooltip: 'editor.find.caseSensitive'.tr(),
                  onTap: controller.toggleCaseSensitive,
                ),
                _ToggleButton(
                  text: '.*',
                  active: value.option.regex,
                  tooltip: 'editor.find.regex'.tr(),
                  onTap: controller.toggleRegex,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  resultText,
                  style: AppTypography.bodyMain.copyWith(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                _IconButton(
                  icon: Symbols.keyboard_arrow_up,
                  tooltip: 'editor.find.previous'.tr(),
                  onTap: result == null ? null : controller.previousMatch,
                ),
                _IconButton(
                  icon: Symbols.keyboard_arrow_down,
                  tooltip: 'editor.find.next'.tr(),
                  onTap: result == null ? null : controller.nextMatch,
                ),
                _IconButton(
                  icon: Symbols.close,
                  tooltip: 'editor.find.close'.tr(),
                  onTap: controller.close,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.text,
    required this.active,
    required this.tooltip,
    required this.onTap,
  });

  final String text;
  final bool active;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.brandIndigo.withValues(alpha: 0.2) : null,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Text(
            text,
            style: AppTypography.bodyMain.copyWith(
              fontSize: 11,
              color: active ? AppColors.brandIndigo : AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 16,
            color: disabled
                ? AppColors.onSurfaceVariant.withValues(alpha: 0.3)
                : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
