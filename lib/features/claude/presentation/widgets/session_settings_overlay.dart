import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/claude_effort.dart';
import '../../domain/entities/claude_model.dart';
import '../../domain/entities/claude_permission_mode.dart';
import '../../domain/entities/claude_thinking_mode.dart';
import '../cubit/claude_sessions_cubit.dart';
import 'mcp_picker.dart';

/// The "tune" icon in the composer that replaces the old picker pill-row
/// (design turn5/5a): hover surfaces a read-only snippet of the current
/// session config; tap opens the editable "Impostazioni sessione" panel.
/// Both float above the icon. All state is read live from
/// [ClaudeSessionsCubit] — nothing is mirrored locally.
class SessionSettingsButton extends HookWidget {
  const SessionSettingsButton({super.key, required this.workspaceId, required this.enabled});

  final String workspaceId;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final panelCtrl = useMemoized(OverlayPortalController.new, const []);
    final snippetCtrl = useMemoized(OverlayPortalController.new, const []);
    // Track visibility ourselves: OverlayPortalController.hide() asserts if the
    // portal was never shown, so every hide() is guarded by these flags. All
    // show/hide happen in gesture handlers — never during build (that would
    // fire before the portal is mounted).
    final snippetShown = useState(false);
    final panelShown = useState(false);

    void hideSnippet() {
      if (snippetShown.value) {
        snippetCtrl.hide();
        snippetShown.value = false;
      }
    }

    void closePanel() {
      if (panelShown.value) {
        panelCtrl.hide();
        panelShown.value = false;
      }
    }

    void togglePanel() {
      if (!enabled) return;
      if (panelShown.value) {
        closePanel();
      } else {
        hideSnippet();
        panelCtrl.show();
        panelShown.value = true;
      }
    }

    // Highlight only while hovering or with the panel open; neutral at rest so
    // it doesn't read as permanently "selected".
    final active = snippetShown.value || panelShown.value;
    final icon = MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (!panelShown.value && !snippetShown.value) {
          snippetCtrl.show();
          snippetShown.value = true;
        }
      },
      onExit: (_) => hideSnippet(),
      child: GestureDetector(
        onTap: togglePanel,
        child: Container(
          key: const ValueKey('session_settings_button'),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: active ? AppColors.brandIndigo.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: active ? AppColors.brandIndigo.withValues(alpha: 0.4) : Colors.transparent),
          ),
          child: Icon(
            Symbols.tune,
            size: 16,
            color: enabled ? (active ? AppColors.primary : AppColors.outline) : AppColors.outlineVariant,
          ),
        ),
      ),
    );

    // Anchor overlays with OverlayPortal.overlayChildLayoutBuilder instead of a
    // CompositedTransformFollower: the follower establishes its paint transform
    // only at composite time, which the OverlayPortal cannot read during layout
    // — it throws "paint transform cannot be reliably computed" every frame
    // (silent under `flutter run`, but a debugger pauses on it → hard freeze on
    // the merged UI/platform thread). The layout builder hands us the button's
    // geometry directly.
    return OverlayPortal.overlayChildLayoutBuilder(
      controller: snippetCtrl,
      overlayChildBuilder: (context, info) => IgnorePointer(
        child: _anchoredAbove(info, child: _SettingsSnippet(workspaceId: workspaceId)),
      ),
      child: OverlayPortal.overlayChildLayoutBuilder(
        controller: panelCtrl,
        overlayChildBuilder: (context, info) => _anchoredAbove(
          info,
          barrier: GestureDetector(behavior: HitTestBehavior.opaque, onTap: closePanel),
          child: _SettingsPanel(workspaceId: workspaceId, enabled: enabled),
        ),
        child: Tooltip(message: Locales.Claude.Terminal.SessionSettings.title, child: icon),
      ),
    );
  }
}

/// Places [child] just above the OverlayPortal target, right edges aligned,
/// 8px gap. [info] carries the target's paint transform/size in overlay
/// coordinates. Optional [barrier] fills the overlay behind the child (tap to
/// dismiss).
Widget _anchoredAbove(OverlayChildLayoutInfo info, {required Widget child, Widget? barrier}) {
  final targetTopRight = MatrixUtils.transformPoint(info.childPaintTransform, Offset(info.childSize.width, 0));
  return Stack(
    children: [
      if (barrier != null) Positioned.fill(child: barrier),
      Positioned(
        right: info.overlaySize.width - targetTopRight.dx,
        bottom: info.overlaySize.height - (targetTopRight.dy - 8),
        child: child,
      ),
    ],
  );
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({required this.workspaceId, required this.enabled});

  final String workspaceId;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ClaudeSessionsCubit>();
    final model = context.select<ClaudeSessionsCubit, ClaudeModel>(
      (c) => c.state.sessionFor(workspaceId)?.model ?? ClaudeModel.defaultModel,
    );
    final effort = context.select<ClaudeSessionsCubit, ClaudeEffort>(
      (c) => c.state.sessionFor(workspaceId)?.effort ?? ClaudeEffort.defaultEffort,
    );
    final thinking = context.select<ClaudeSessionsCubit, ClaudeThinkingMode>(
      (c) => c.state.sessionFor(workspaceId)?.thinkingMode ?? ClaudeThinkingMode.defaultMode,
    );
    final permission = context.select<ClaudeSessionsCubit, ClaudePermissionMode>(
      (c) => c.state.sessionFor(workspaceId)?.permissionMode ?? ClaudePermissionMode.defaultChoice,
    );

    return Material(
      color: Colors.transparent,
      child: Container(
        key: const ValueKey('session_settings_panel'),
        width: 360,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 40, offset: Offset(0, 18))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Symbols.tune, size: 15, color: AppColors.onSurface),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  Locales.Claude.Terminal.SessionSettings.title,
                  style: AppTypography.bodyMain.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _SectionLabel(Locales.Claude.Terminal.Model.label),
            const SizedBox(height: AppSpacing.xs),
            _SegmentedRow<ClaudeModel>(
              values: ClaudeModel.values,
              current: model,
              enabled: enabled,
              labelFor: (m) => m.labelKey.tr(),
              onSelected: (m) => cubit.setModel(workspaceId, m),
            ),
            const SizedBox(height: AppSpacing.md),
            _SectionLabel(Locales.Claude.Terminal.Effort.label),
            const SizedBox(height: AppSpacing.xs),
            _SegmentedRow<ClaudeEffort>(
              values: ClaudeEffort.values,
              current: effort,
              enabled: enabled,
              labelFor: _effortShort,
              tooltipFor: (e) => e.labelKey.tr(),
              onSelected: (e) => cubit.setEffort(workspaceId, e),
            ),
            const SizedBox(height: AppSpacing.md),
            _ReasoningToggle(
              value: thinking == ClaudeThinkingMode.on,
              enabled: enabled,
              onChanged: (on) => cubit.setThinking(workspaceId, on ? ClaudeThinkingMode.on : ClaudeThinkingMode.off),
            ),
            const SizedBox(height: AppSpacing.md),
            _SectionLabel(Locales.Claude.Terminal.Permission.label),
            const SizedBox(height: AppSpacing.xs),
            _SegmentedRow<ClaudePermissionMode>(
              values: ClaudePermissionMode.values,
              current: permission,
              enabled: enabled,
              labelFor: _permissionShort,
              tooltipFor: (m) => m.labelKey.tr(),
              onSelected: (m) => cubit.setPermissionMode(workspaceId, m),
            ),
            const SizedBox(height: AppSpacing.md),
            _McpSection(workspaceId: workspaceId),
          ],
        ),
      ),
    );
  }
}

/// Inline, expandable MCP section: a header row (label + active count + chevron)
/// that reveals the [McpServerList] in place — no popup covering the panel.
class _McpSection extends HookWidget {
  const _McpSection({required this.workspaceId});

  final String workspaceId;

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);
    final disabledCount = context.select<ClaudeSessionsCubit, int>(
      (c) => c.state.sessionFor(workspaceId)?.disabledMcpServers.length ?? 0,
    );
    final total = context.select<ClaudeSessionsCubit, int>((c) => c.state.mcpServers.length);
    final countText = total == 0
        ? ''
        : Locales.Claude.Terminal.Mcp.activeCount(count: '${(total - disabledCount).clamp(0, total)}');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            key: const ValueKey('session_settings_mcp_header'),
            behavior: HitTestBehavior.opaque,
            onTap: () => expanded.value = !expanded.value,
            child: Container(
              height: 36,
              padding: const EdgeInsets.only(left: 11, right: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                children: [
                  const Icon(Symbols.hub, size: 14, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    Locales.Claude.Terminal.Mcp.label,
                    style: AppTypography.bodyMain.copyWith(fontSize: 11.5, color: AppColors.onSurfaceVariant),
                  ),
                  const Spacer(),
                  if (countText.isNotEmpty)
                    Text(countText, style: AppTypography.bodyMain.copyWith(fontSize: 11, color: AppColors.outline)),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 150),
                    turns: expanded.value ? 0.5 : 0,
                    child: const Icon(Symbols.expand_more, size: 18, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: expanded.value
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: McpServerList(workspaceId: workspaceId, maxHeight: 200),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _SettingsSnippet extends StatelessWidget {
  const _SettingsSnippet({required this.workspaceId});

  final String workspaceId;

  @override
  Widget build(BuildContext context) {
    final model = context.select<ClaudeSessionsCubit, ClaudeModel>(
      (c) => c.state.sessionFor(workspaceId)?.model ?? ClaudeModel.defaultModel,
    );
    final effort = context.select<ClaudeSessionsCubit, ClaudeEffort>(
      (c) => c.state.sessionFor(workspaceId)?.effort ?? ClaudeEffort.defaultEffort,
    );
    final thinking = context.select<ClaudeSessionsCubit, ClaudeThinkingMode>(
      (c) => c.state.sessionFor(workspaceId)?.thinkingMode ?? ClaudeThinkingMode.defaultMode,
    );
    final permission = context.select<ClaudeSessionsCubit, ClaudePermissionMode>(
      (c) => c.state.sessionFor(workspaceId)?.permissionMode ?? ClaudePermissionMode.defaultChoice,
    );
    final disabledCount = context.select<ClaudeSessionsCubit, int>(
      (c) => c.state.sessionFor(workspaceId)?.disabledMcpServers.length ?? 0,
    );
    final total = context.select<ClaudeSessionsCubit, int>((c) => c.state.mcpServers.length);
    final mcpValue = total == 0
        ? '—'
        : Locales.Claude.Terminal.Mcp.activeCount(count: '${(total - disabledCount).clamp(0, total)}');

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 216,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: const [BoxShadow(color: Color(0xCC000000), blurRadius: 44, offset: Offset(0, 18))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Symbols.smart_toy, size: 14, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  model.labelKey.tr(),
                  style: AppTypography.bodyMain.copyWith(fontWeight: FontWeight.w600, fontSize: 12.5),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _SnippetRow(label: Locales.Claude.Terminal.Effort.label, value: effort.labelKey.tr()),
            _SnippetRow(label: Locales.Claude.Terminal.Thinking.label, value: thinking.labelKey.tr()),
            _SnippetRow(label: Locales.Claude.Terminal.Permission.label, value: permission.labelKey.tr()),
            _SnippetRow(label: Locales.Claude.Terminal.Mcp.label, value: mcpValue),
            const SizedBox(height: AppSpacing.xs),
            const Divider(color: AppColors.outlineVariant, height: AppSpacing.md, thickness: 1),
            Text(
              Locales.Claude.Terminal.SessionSettings.editHint,
              style: AppTypography.bodyMain.copyWith(fontSize: 10, color: AppColors.outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _SnippetRow extends StatelessWidget {
  const _SnippetRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMain.copyWith(fontSize: 11, color: AppColors.outline)),
          Text(value, style: AppTypography.bodyMain.copyWith(fontSize: 11, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTypography.bodyMain.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

String _effortShort(ClaudeEffort e) => switch (e) {
  ClaudeEffort.low => Locales.Claude.Effort.Short.low,
  ClaudeEffort.medium => Locales.Claude.Effort.Short.medium,
  ClaudeEffort.high => Locales.Claude.Effort.Short.high,
  ClaudeEffort.xhigh => Locales.Claude.Effort.Short.xhigh,
  ClaudeEffort.max => Locales.Claude.Effort.Short.max,
};

String _permissionShort(ClaudePermissionMode m) => switch (m) {
  ClaudePermissionMode.plan => Locales.Claude.Permission.Short.plan,
  ClaudePermissionMode.acceptEdits => Locales.Claude.Permission.Short.acceptEdits,
  ClaudePermissionMode.auto => Locales.Claude.Permission.Short.auto,
  ClaudePermissionMode.bypassPermissions => Locales.Claude.Permission.Short.bypassPermissions,
  ClaudePermissionMode.defaultMode => Locales.Claude.Permission.Short.default$,
};

class _SegmentedRow<T> extends StatelessWidget {
  const _SegmentedRow({
    required this.values,
    required this.current,
    required this.enabled,
    required this.labelFor,
    required this.onSelected,
    this.tooltipFor,
  });

  final List<T> values;
  final T current;
  final bool enabled;
  final String Function(T) labelFor;
  final String Function(T)? tooltipFor;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.sm)),
      child: Row(
        children: values.map((v) {
          final selected = v == current;
          final label = labelFor(v);
          return Expanded(
            child: MouseRegion(
              cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
              child: GestureDetector(
                onTap: enabled ? () => onSelected(v) : null,
                child: Tooltip(
                  message: tooltipFor?.call(v) ?? label,
                  waitDuration: const Duration(milliseconds: 400),
                  child: Container(
                    key: ValueKey('session_settings_seg_${v.toString()}'),
                    height: 24,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.brandIndigo : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMain.copyWith(
                        fontSize: 10.5,
                        color: selected
                            ? AppColors.onPrimaryContainer
                            : (enabled ? AppColors.onSurfaceVariant : AppColors.outline),
                        fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ReasoningToggle extends StatelessWidget {
  const _ReasoningToggle({required this.value, required this.enabled, required this.onChanged});

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Container(
        height: 36,
        padding: const EdgeInsets.only(left: 11, right: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Locales.Claude.Terminal.Thinking.label,
              style: AppTypography.bodyMain.copyWith(fontSize: 11.5, color: AppColors.onSurfaceVariant),
            ),
            MouseRegion(
              cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
              child: GestureDetector(
                key: const ValueKey('session_settings_reasoning_toggle'),
                onTap: enabled ? () => onChanged(!value) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  width: 38,
                  height: 21,
                  decoration: BoxDecoration(
                    color: value ? AppColors.brandIndigo : AppColors.outline.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Stack(
                    children: [
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOut,
                        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: SizedBox(
                            width: 17,
                            height: 17,
                            child: DecoratedBox(
                              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
