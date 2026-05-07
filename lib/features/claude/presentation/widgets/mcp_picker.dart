import 'dart:async';

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
import '../../../../core/utils/menu_position.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../../domain/entities/mcp_server.dart';
import '../cubit/claude_sessions_cubit.dart';

class McpPicker extends StatelessWidget {
  const McpPicker({super.key, required this.workspaceId});

  final String workspaceId;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: Locales.Claude.Terminal.Mcp.tooltip,
      child: Hoverable(
        key: const ValueKey('mcp_picker'),
        onTap: () => _openMenu(context),
        builder: (context, hover) {
          return Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              color: hover ? AppColors.glassHover : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.outlineVariant, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Symbols.hub, size: 14, color: AppColors.onSurfaceVariant),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  Locales.Claude.Terminal.Mcp.label,
                  style: AppTypography.bodyMain.copyWith(fontSize: 11, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.expand_more, size: 12, color: AppColors.onSurfaceVariant),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openMenu(BuildContext context) {
    final cubit = context.read<ClaudeSessionsCubit>();
    unawaited(cubit.ensureMcpServers());

    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    showMenu<void>(
      context: context,
      position: relativeRectBelow(box),
      color: Colors.transparent,
      elevation: 8,
      items: [
        PopupMenuItem<void>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: _McpOverlayContent(cubit: cubit, workspaceId: workspaceId, width: 360),
        ),
      ],
    );
  }
}

class _McpOverlayContent extends HookWidget {
  const _McpOverlayContent({required this.cubit, required this.workspaceId, required this.width});

  final ClaudeSessionsCubit cubit;
  final String workspaceId;
  final double width;

  @override
  Widget build(BuildContext context) {
    final future = useState<Future<List<McpServer>>>(cubit.ensureMcpServers());
    final snapshot = useFuture(future.value);
    final loading = snapshot.connectionState == ConnectionState.waiting;

    void refresh() {
      if (loading) return;
      future.value = cubit.ensureMcpServers(force: true);
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  Locales.Claude.Terminal.Mcp.title,
                  style: AppTypography.bodyMain.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Symbols.refresh, size: 16, color: loading ? AppColors.outline : null),
                  onPressed: loading ? null : refresh,
                  tooltip: Locales.Claude.Terminal.Mcp.refresh,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(width: 24, height: 24),
                  splashRadius: 12,
                ),
              ],
            ),
            const Divider(color: AppColors.outlineVariant, height: 16, thickness: 1),
            _buildBody(context, snapshot),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AsyncSnapshot<List<McpServer>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Row(
        children: [
          const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: AppSpacing.sm),
          Text(
            Locales.Claude.Terminal.Mcp.loading,
            style: AppTypography.bodyMain.copyWith(fontSize: 11, color: AppColors.outline),
          ),
        ],
      );
    }

    if (snapshot.hasError) {
      return Text(Locales.Claude.Terminal.Mcp.error, style: AppTypography.bodyMain.copyWith(color: AppColors.error));
    }

    final data = snapshot.data;
    if (data == null || data.isEmpty) {
      return Text(Locales.Claude.Terminal.Mcp.empty, style: AppTypography.bodyMain.copyWith(color: AppColors.outline));
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 360),
      child: BlocBuilder<ClaudeSessionsCubit, ClaudeSessionsState>(
        buildWhen: (a, b) {
          final sa = a.sessionFor(workspaceId);
          final sb = b.sessionFor(workspaceId);
          return sa?.disabledMcpServers != sb?.disabledMcpServers || sa?.runStatus != sb?.runStatus;
        },
        builder: (context, sessionsState) {
          final session = sessionsState.sessionFor(workspaceId);
          final disabled = session?.disabledMcpServers ?? const <String>{};
          final canAuth = cubit.isSessionActive(workspaceId);
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: data.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
              itemBuilder: (_, i) {
                final server = data[i];
                final isDisabled = disabled.contains(server.name);
                return _McpServerTile(
                  server: server,
                  isDisabled: isDisabled,
                  canAuth: canAuth,
                  onToggle: (enabled) => cubit.toggleMcpServer(workspaceId, server.name, enabled),
                  onAuth: () => cubit.authenticateMcpServer(workspaceId, server.name),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _McpServerTile extends StatelessWidget {
  const _McpServerTile({
    required this.server,
    required this.isDisabled,
    required this.canAuth,
    required this.onToggle,
    required this.onAuth,
  });

  final McpServer server;
  final bool isDisabled;
  final bool canAuth;
  final ValueChanged<bool> onToggle;
  final VoidCallback onAuth;

  @override
  Widget build(BuildContext context) {
    final dotColor = isDisabled ? AppColors.outline : _statusColor(server.status);
    final nameColor = isDisabled ? AppColors.outline : AppColors.onSurfaceVariant;
    final tooltipParts = <String>[
      server.name,
      _statusLabel(server.status).tr(),
      if (isDisabled) Locales.Claude.Terminal.Mcp.disabledLabel,
    ];
    return Tooltip(
      message: tooltipParts.join(' — '),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  server.displayName,
                  style: AppTypography.bodyMain.copyWith(fontWeight: FontWeight.w600, fontSize: 12, color: nameColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  server.commandOrUrl,
                  style: AppTypography.bodyMain.copyWith(fontSize: 10, color: AppColors.outline),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (server.status == McpServerStatus.needsAuth && !isDisabled) ...[
            const SizedBox(width: AppSpacing.xs),
            _McpAuthButton(canAuth: canAuth, onTap: onAuth),
          ],
          const SizedBox(width: AppSpacing.sm),
          _McpToggle(value: !isDisabled, onChanged: onToggle),
        ],
      ),
    );
  }
}

class _McpAuthButton extends HookWidget {
  const _McpAuthButton({required this.canAuth, required this.onTap});

  final bool canAuth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hovered = useState(false);
    final tooltip = canAuth ? Locales.Claude.Terminal.Mcp.authenticate : Locales.Claude.Terminal.Mcp.toggleNoSession;
    return Tooltip(
      message: tooltip,
      child: Opacity(
        opacity: canAuth ? 1.0 : 0.4,
        child: MouseRegion(
          cursor: canAuth ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onEnter: canAuth ? (_) => hovered.value = true : null,
          onExit: canAuth ? (_) => hovered.value = false : null,
          child: GestureDetector(
            onTap: canAuth ? onTap : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: hovered.value ? const Color(0xFFFFCC00).withValues(alpha: 0.20) : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(color: const Color(0xFFFFCC00).withValues(alpha: 0.6)),
              ),
              child: const Icon(Symbols.key, size: 12, color: Color(0xFFFFCC00)),
            ),
          ),
        ),
      ),
    );
  }
}

class _McpToggle extends HookWidget {
  const _McpToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  static const _trackW = 30.0;
  static const _trackH = 16.0;
  static const _dotSize = 12.0;
  static const _dotPad = (_trackH - _dotSize) / 2;

  @override
  Widget build(BuildContext context) {
    final hovered = useState(false);
    final enabled = onChanged != null;

    final trackColor = _resolveTrackColor(hovered.value);

    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: enabled ? (_) => hovered.value = true : null,
        onExit: enabled ? (_) => hovered.value = false : null,
        child: GestureDetector(
          onTap: enabled ? () => onChanged!(!value) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            width: _trackW,
            height: _trackH,
            decoration: BoxDecoration(color: trackColor, borderRadius: BorderRadius.circular(8)),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _dotPad),
                    child: Container(
                      width: _dotSize,
                      height: _dotSize,
                      decoration: BoxDecoration(
                        color: value ? Colors.white : AppColors.outline,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _resolveTrackColor(bool hovered) {
    if (value) {
      // ON: primary, hover brightens slightly
      return hovered ? AppColors.primary : AppColors.primary.withValues(alpha: 0.85);
    } else {
      // OFF: dim outline, hover becomes slightly more visible
      return hovered ? AppColors.outline.withValues(alpha: 0.6) : AppColors.outline.withValues(alpha: 0.4);
    }
  }
}

Color _statusColor(McpServerStatus s) {
  switch (s) {
    case McpServerStatus.connected:
      return const Color(0xFF34C759);
    case McpServerStatus.failed:
      return const Color(0xFFFF3B30);
    case McpServerStatus.needsAuth:
      return const Color(0xFFFFCC00);
    case McpServerStatus.unknown:
      return AppColors.outline;
  }
}

String _statusLabel(McpServerStatus s) {
  switch (s) {
    case McpServerStatus.connected:
      return 'claude.terminal.mcp.status.connected';
    case McpServerStatus.failed:
      return 'claude.terminal.mcp.status.failed';
    case McpServerStatus.needsAuth:
      return 'claude.terminal.mcp.status.needsAuth';
    case McpServerStatus.unknown:
      return 'claude.terminal.mcp.status.unknown';
  }
}
