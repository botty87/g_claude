import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/mcp_server.dart';
import '../cubit/claude_sessions_cubit.dart';

/// Reusable, container-less list of MCP servers with per-server enable toggle
/// and auth button, plus a refresh control. Meant to be embedded (e.g. the
/// inline expandable section of the session-settings panel); the host provides
/// the surrounding surface. Scrolls within [maxHeight].
class McpServerList extends HookWidget {
  const McpServerList({super.key, required this.workspaceId, this.maxHeight = 240});

  final String workspaceId;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ClaudeSessionsCubit>();
    // Memoize so the load fires exactly once on mount — NOT on every rebuild.
    // (Embedded in the composer's OverlayPortal, this widget rebuilds far more
    // often than the old popup did; calling ensureMcpServers() in a useState
    // initializer would re-spawn a sidecar round-trip on each build.)
    final future = useState<Future<List<McpServer>>>(useMemoized(() => cubit.ensureMcpServers(), const []));
    // Seed with the warm cache so the list renders at full size on the FIRST
    // frame (no loading-row flicker). Otherwise the size changes over two
    // consecutive frames (loading → loaded), which makes the parent AnimatedSize
    // treat the expansion as "unstable" and snap instead of animating.
    final snapshot = useFuture(
      future.value,
      // Only seed when the cache is warm; an empty list would make `hasData`
      // true and render the "empty" body instead of the loading row on mount.
      initialData: cubit.cachedMcpServers.isNotEmpty ? cubit.cachedMcpServers : null,
    );
    // Header state (refresh button enable + re-entrancy guard + icon color)
    // tracks a load in flight regardless of retained data — the `initialData`
    // seed keeps `hasData` true across a forced refresh, so `&& !hasData` here
    // would leave the guard dead and let taps spawn concurrent round-trips.
    // The flicker-free body rendering keeps its own `waiting && !hasData`.
    final loading = snapshot.connectionState == ConnectionState.waiting;

    void refresh() {
      if (loading) return;
      future.value = cubit.ensureMcpServers(force: true);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              Locales.Claude.Terminal.Mcp.title,
              style: AppTypography.bodyMain.copyWith(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Symbols.refresh, size: 16, color: loading ? AppColors.outline : null),
              onPressed: loading ? null : refresh,
              tooltip: Locales.Claude.Terminal.Mcp.refresh,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 22, height: 22),
              splashRadius: 12,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        _mcpBody(context, snapshot, cubit, workspaceId, maxHeight),
      ],
    );
  }
}

Widget _mcpBody(
  BuildContext context,
  AsyncSnapshot<List<McpServer>> snapshot,
  ClaudeSessionsCubit cubit,
  String workspaceId,
  double maxHeight,
) {
  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
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
    constraints: BoxConstraints(maxHeight: maxHeight),
    child: BlocBuilder<ClaudeSessionsCubit, ClaudeSessionsState>(
      buildWhen: (a, b) =>
          a.sessionFor(workspaceId)?.disabledMcpServers != b.sessionFor(workspaceId)?.disabledMcpServers ||
          a.mcpAuthInFlight != b.mcpAuthInFlight,
      builder: (context, sessionsState) {
        final session = sessionsState.sessionFor(workspaceId);
        final disabled = session?.disabledMcpServers ?? const <String>{};
        final authInFlight = sessionsState.mcpAuthInFlight;
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
                authPending: authInFlight.contains(server.name),
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

class _McpServerTile extends StatelessWidget {
  const _McpServerTile({
    required this.server,
    required this.isDisabled,
    required this.authPending,
    required this.onToggle,
    required this.onAuth,
  });

  final McpServer server;
  final bool isDisabled;
  final bool authPending;
  final ValueChanged<bool> onToggle;
  final VoidCallback onAuth;

  @override
  Widget build(BuildContext context) {
    final dotColor = isDisabled ? AppColors.outline : _statusColor(server.status);
    final nameColor = isDisabled ? AppColors.outline : AppColors.onSurfaceVariant;
    return Row(
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
          _McpAuthButton(pending: authPending, onTap: onAuth),
        ],
        const SizedBox(width: AppSpacing.sm),
        _McpToggle(value: !isDisabled, onChanged: onToggle),
      ],
    );
  }
}

class _McpAuthButton extends HookWidget {
  const _McpAuthButton({required this.pending, required this.onTap});

  /// True while an OAuth flow is in flight for this server: the button shows a
  /// spinner and ignores taps so a second flow can't be spawned.
  final bool pending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hovered = useState(false);
    const gold = Color(0xFFFFCC00);
    return Tooltip(
      message: Locales.Claude.Terminal.Mcp.authenticate,
      child: MouseRegion(
        cursor: pending ? SystemMouseCursors.basic : SystemMouseCursors.click,
        onEnter: pending ? null : (_) => hovered.value = true,
        onExit: pending ? null : (_) => hovered.value = false,
        child: GestureDetector(
          onTap: pending ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: hovered.value && !pending ? gold.withValues(alpha: 0.20) : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(color: gold.withValues(alpha: 0.6)),
            ),
            child: pending
                ? const Padding(
                    padding: EdgeInsets.all(5),
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: gold),
                  )
                : const Icon(Symbols.key, size: 12, color: gold),
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
