import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// 40px top chrome bar: brand · tabs · spacer · settings.
class TopHeader extends StatelessWidget {
  const TopHeader({super.key, required this.tabs, required this.activeTab, this.onTabSelected});

  final List<String> tabs;
  final String activeTab;
  final ValueChanged<String>? onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.toolbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
      ),
      child: Row(
        children: [
          Text('CLAUDE CODE', style: AppTypography.brand),
          const SizedBox(width: AppSpacing.lg),
          ...tabs.map((t) => _TabItem(label: t, isActive: t == activeTab, onTap: () => onTabSelected?.call(t))),
          const Spacer(),
          const _IconButton(icon: Symbols.settings),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({required this.label, required this.isActive, this.onTap});

  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.navTab.copyWith(
      color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
    );
    return InkWell(
      onTap: onTap,
      child: Container(
        height: AppSpacing.toolbarHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: isActive ? AppColors.glassActive : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: isActive ? AppColors.brandIndigo : Colors.transparent, width: 2),
          ),
        ),
        alignment: Alignment.center,
        child: Text(label, style: style),
      ),
    );
  }
}

class _IconButton extends StatefulWidget {
  const _IconButton({required this.icon});
  final IconData icon;

  @override
  State<_IconButton> createState() => _IconButtonState();
}

class _IconButtonState extends State<_IconButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: _hover ? AppColors.glassHover : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          widget.icon,
          size: 16,
          color: Colors.white.withValues(alpha: _hover ? 0.7 : 0.4),
        ),
      ),
    );
  }
}
