import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// 240px-wide left sidebar. PROJECT label + primary nav + open editors + footer.
class SideNavBar extends StatelessWidget {
  const SideNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.sidebarWidth,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: AppColors.glassBorder)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.lg),
            const _ProjectHeader(),
            const SizedBox(height: AppSpacing.md),
            const _NavItem(icon: Symbols.folder, label: 'Explorer', isActive: true),
            const _NavItem(icon: Symbols.search, label: 'Search'),
            const _NavItem(icon: Symbols.account_tree, label: 'Git'),
            const _NavItem(icon: Symbols.bug_report, label: 'Debug'),
            const SizedBox(height: AppSpacing.xl),
            _SectionLabel(text: 'OPEN EDITORS'),
            const _FileItem(label: 'main.py', icon: Symbols.description, iconColor: Color(0xFFFFE066), isActive: true),
            const _FileItem(label: 'utils.py', icon: Symbols.terminal, iconColor: Color(0xFF87CEFF)),
            const _FileItem(label: 'config.json', icon: Symbols.description, iconColor: Color(0xFFAAAAAA)),
            const Spacer(),
            const _NavItem(icon: Symbols.settings, label: 'Settings'),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _ProjectHeader extends StatelessWidget {
  const _ProjectHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROJECT',
            style: AppTypography.sidebarLabel.copyWith(color: Colors.white.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'graphite-workspace',
            style: AppTypography.bodyMain.copyWith(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xs),
      child: Text(
        text,
        style: AppTypography.sidebarLabel.copyWith(
          fontSize: 9,
          color: Colors.white.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({required this.icon, required this.label, this.isActive = false});

  final IconData icon;
  final String label;
  final bool isActive;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final showHighlight = widget.isActive || _hover;
    final textColor = widget.isActive
        ? Colors.white
        : Colors.white.withValues(alpha: _hover ? 0.8 : 0.4);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 8),
        decoration: BoxDecoration(
          color: showHighlight ? AppColors.glassHover : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: widget.isActive ? AppColors.brandIndigo : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(widget.icon, size: 16, color: textColor),
            const SizedBox(width: AppSpacing.md),
            Text(
              widget.label,
              style: AppTypography.bodyMain.copyWith(fontSize: 13, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _FileItem extends StatefulWidget {
  const _FileItem({
    required this.label,
    required this.icon,
    required this.iconColor,
    this.isActive = false,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final bool isActive;

  @override
  State<_FileItem> createState() => _FileItemState();
}

class _FileItemState extends State<_FileItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final showHighlight = widget.isActive || _hover;
    final textColor = widget.isActive
        ? Colors.white
        : Colors.white.withValues(alpha: 0.6);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: showHighlight ? AppColors.glassHover : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 14, color: widget.iconColor),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.label,
                  style: AppTypography.sidebarLabel.copyWith(color: textColor, letterSpacing: 0),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
