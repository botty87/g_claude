import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';

/// Shared building blocks for Clyde's dialogs (Glass Graphite, TURN 6 design):
/// a floating [GlassDialog] panel, a header with a tinted icon, pill buttons,
/// uppercase field labels + dark inset fields, a segmented control and
/// selectable option cards. Keeps every dialog visually uniform.

/// Modal scrim behind the dialog — rgba(8,8,13,.55).
const Color kGlassDialogBarrier = Color(0x8C08080D);

const Color _fieldFill = AppColors.surfaceContainerLowest; // ~#0E0D15
const Color _fieldFillActive = AppColors.brandIndigo;

/// The floating dialog panel: surfaceContainer fill, radius 16, glass border,
/// soft drop shadow. Pass the header/body/footer as [children] of the column.
class GlassDialog extends StatelessWidget {
  const GlassDialog({super.key, required this.width, required this.children});

  final double width;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: width,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(color: AppColors.glassBorder),
            boxShadow: const [
              BoxShadow(color: Color(0xB3000000), blurRadius: 50, spreadRadius: -20, offset: Offset(0, 30)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}

/// Dialog header: a tinted rounded icon, a title (+ optional [subtitle] widget),
/// and a × close affordance. [divider] draws the bottom hairline (used by the
/// close dialog; the new-worktree dialog omits it because a segmented control
/// follows).
class GlassDialogHeader extends StatelessWidget {
  const GlassDialogHeader({
    super.key,
    required this.icon,
    required this.iconTint,
    required this.title,
    this.subtitle,
    this.onClose,
    this.divider = false,
    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 0),
  });

  final IconData icon;
  final Color iconTint;
  final String title;
  final Widget? subtitle;
  final VoidCallback? onClose;
  final bool divider;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: divider
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: iconTint.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 18, color: iconTint),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMain.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimaryContainer,
                    letterSpacing: -0.2,
                  ),
                ),
                if (subtitle != null) ...[const SizedBox(height: 5), subtitle!],
              ],
            ),
          ),
          if (onClose != null)
            _HoverIcon(
              onTap: onClose!,
              child: const Icon(Symbols.close, size: 16, color: AppColors.outline),
            ),
        ],
      ),
    );
  }
}

/// A read-only worktree/branch chip for a dialog header (indigo dot + name,
/// mono branch beside it).
class GlassBranchChip extends StatelessWidget {
  const GlassBranchChip({super.key, required this.name, this.branch});

  final String name;
  final String? branch;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 22,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.brandIndigo.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(color: AppColors.brandIndigo, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                name,
                style: AppTypography.navTab.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        if (branch != null) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              branch!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.terminalCode.copyWith(fontSize: 11, height: 1.2, color: AppColors.outline),
            ),
          ),
        ],
      ],
    );
  }
}

/// Footer with a trailing text "cancel" and a filled primary/danger action.
class GlassDialogActions extends StatelessWidget {
  const GlassDialogActions({
    super.key,
    required this.cancelLabel,
    required this.onCancel,
    required this.confirmLabel,
    required this.onConfirm,
    this.confirmIcon,
    this.confirmBusy = false,
    this.destructive = false,
    this.confirmKey,
    this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 18),
  });

  final String cancelLabel;
  final VoidCallback? onCancel;
  final String confirmLabel;
  final VoidCallback? onConfirm;
  final IconData? confirmIcon;
  final bool confirmBusy;
  final bool destructive;
  final Key? confirmKey;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _GlassTextButton(label: cancelLabel, onTap: onCancel),
          const SizedBox(width: 10),
          GlassPillButton(
            key: confirmKey,
            label: confirmLabel,
            icon: confirmIcon,
            busy: confirmBusy,
            onTap: onConfirm,
            destructive: destructive,
          ),
        ],
      ),
    );
  }
}

/// Filled action button (indigo, or dark-red when [destructive]). Disabled when
/// [onTap] is null; shows a spinner when [busy].
class GlassPillButton extends StatelessWidget {
  const GlassPillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.busy = false,
    this.destructive = false,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool busy;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !busy;
    final bg = destructive ? AppColors.errorContainer : AppColors.brandIndigo;
    final fg = destructive ? AppColors.onErrorContainer : AppColors.onPrimaryContainer;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Hoverable(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onTap: enabled ? onTap : null,
        builder: (context, hover) => Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: hover && enabled ? Color.alphaBlend(AppColors.glassHover, bg) : bg,
            borderRadius: BorderRadius.circular(9),
          ),
          child: busy
              ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: fg))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[Icon(icon, size: 16, color: fg), const SizedBox(width: 8)],
                    Text(
                      label,
                      style: AppTypography.navTab.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: fg),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _GlassTextButton extends StatelessWidget {
  const _GlassTextButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: Hoverable(
        cursor: onTap == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
        onTap: onTap,
        builder: (context, hover) => Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: hover && onTap != null ? AppColors.glassHover : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            style: AppTypography.navTab.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// Uppercase field label (11px, 600, dim), matching TURN 6 form fields.
class GlassFieldLabel extends StatelessWidget {
  const GlassFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.sidebarLabel.copyWith(color: AppColors.outline, letterSpacing: 0.4),
      ),
    );
  }
}

/// Dark inset field container (radius 9). [active] draws the indigo focus
/// border. Compose the row content ([child]) inside.
class GlassField extends StatelessWidget {
  const GlassField({super.key, required this.child, this.active = false, this.height = 40, this.padding});

  final Widget child;
  final bool active;
  final double height;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _fieldFill,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: active ? _fieldFillActive.withValues(alpha: 0.5) : AppColors.glassBorder),
      ),
      child: child,
    );
  }
}

/// Two-way segmented control used for the dialog's mode switch.
class GlassSegmented<T> extends StatelessWidget {
  const GlassSegmented({super.key, required this.value, required this.segments, required this.onChanged});

  final T value;
  final List<GlassSegment<T>> segments;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          for (final s in segments)
            Expanded(
              child: Hoverable(
                key: s.key,
                cursor: onChanged == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
                onTap: onChanged == null ? null : () => onChanged!(s.value),
                builder: (context, hover) {
                  final selected = s.value == value;
                  final fg = selected ? AppColors.onPrimaryContainer : AppColors.outline;
                  return Container(
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.brandIndigo : (hover ? AppColors.glassHover : Colors.transparent),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(s.icon, size: 15, color: fg),
                        const SizedBox(width: 7),
                        Text(
                          s.label,
                          style: AppTypography.navTab.copyWith(
                            fontSize: 12.5,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                            color: fg,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class GlassSegment<T> {
  const GlassSegment({required this.value, required this.label, required this.icon, this.key});

  final T value;
  final String label;
  final IconData icon;
  final Key? key;
}

/// A selectable option card (radio-like) with an icon, title, optional risk
/// badge and description. Used for the close-worktree choices.
class GlassOptionCard extends StatelessWidget {
  const GlassOptionCard({
    super.key,
    required this.selected,
    required this.onTap,
    required this.icon,
    required this.title,
    required this.description,
    this.badge,
    this.destructive = false,
    this.enabled = true,
  });

  final bool selected;
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String description;
  final GlassBadge? badge;
  final bool destructive;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = destructive ? AppColors.error : (selected ? AppColors.primary : AppColors.outline);
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Hoverable(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onTap: enabled ? onTap : null,
        builder: (context, hover) {
          final Color borderColor = selected
              ? AppColors.brandIndigo.withValues(alpha: 0.45)
              : (destructive
                    ? AppColors.error.withValues(alpha: hover ? 0.4 : 0.18)
                    : (hover ? AppColors.outlineVariant : AppColors.glassBorder));
          final Color bg = selected
              ? AppColors.brandIndigo.withValues(alpha: 0.10)
              : (hover ? AppColors.glassHover : Colors.transparent);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: selected ? AppColors.brandIndigo : AppColors.outlineVariant, width: 2),
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: AppColors.brandIndigo, shape: BoxShape.circle),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(icon, size: 16, color: iconColor),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              title,
                              style: AppTypography.navTab.copyWith(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                          if (badge != null) ...[const SizedBox(width: 8), badge!],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: AppTypography.navTab.copyWith(fontSize: 12, height: 1.5, color: AppColors.outline),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Compact pill toggle matching the TURN 6 design (36×20 track, 16 knob). Purely
/// presentational — wrap it in a tappable row (e.g. [Hoverable]) for the gesture.
class GlassSwitch extends StatelessWidget {
  const GlassSwitch({super.key, required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      width: 36,
      height: 20,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: value ? AppColors.brandIndigo : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: value ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Small pill badge (e.g. SICURO / DISTRUTTIVO) used inside option cards.
class GlassBadge extends StatelessWidget {
  const GlassBadge({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.brand.copyWith(fontSize: 9.5, letterSpacing: 0.4, color: color),
      ),
    );
  }
}

class _HoverIcon extends StatelessWidget {
  const _HoverIcon({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      onTap: onTap,
      builder: (context, hover) => Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: hover ? AppColors.glassHover : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Center(child: child),
      ),
    );
  }
}
