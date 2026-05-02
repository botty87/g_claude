import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';

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
      message: 'claude.terminal.mcp.tooltip'.tr(),
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
                const Icon(
                  Symbols.hub,
                  size: 14,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'claude.terminal.mcp.label'.tr(),
                  style: AppTypography.bodyMain.copyWith(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.expand_more,
                  size: 12,
                  color: AppColors.onSurfaceVariant,
                ),
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
          child: _McpOverlayContent(cubit: cubit, width: 360),
        ),
      ],
    );
  }
}

class _McpOverlayContent extends HookWidget {
  const _McpOverlayContent({required this.cubit, required this.width});

  final ClaudeSessionsCubit cubit;
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
                  'claude.terminal.mcp.title'.tr(),
                  style: AppTypography.bodyMain.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Symbols.refresh,
                    size: 16,
                    color: loading ? AppColors.outline : null,
                  ),
                  onPressed: loading ? null : refresh,
                  tooltip: 'claude.terminal.mcp.refresh'.tr(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 24,
                    height: 24,
                  ),
                  splashRadius: 12,
                ),
              ],
            ),
            const Divider(
              color: AppColors.outlineVariant,
              height: 16,
              thickness: 1,
            ),
            _buildBody(context, snapshot),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncSnapshot<List<McpServer>> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'claude.terminal.mcp.loading'.tr(),
            style: AppTypography.bodyMain.copyWith(
              fontSize: 11,
              color: AppColors.outline,
            ),
          ),
        ],
      );
    }

    if (snapshot.hasError) {
      return Text(
        'claude.terminal.mcp.error'.tr(),
        style: AppTypography.bodyMain.copyWith(color: AppColors.error),
      );
    }

    final data = snapshot.data;
    if (data == null || data.isEmpty) {
      return Text(
        'claude.terminal.mcp.empty'.tr(),
        style: AppTypography.bodyMain.copyWith(color: AppColors.outline),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 360),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: data.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
        itemBuilder: (_, i) => _McpServerTile(server: data[i]),
      ),
    );
  }
}

class _McpServerTile extends StatelessWidget {
  const _McpServerTile({required this.server});

  final McpServer server;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${server.name} — ${_statusLabel(server.status).tr()}',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _statusColor(server.status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  server.displayName,
                  style: AppTypography.bodyMain.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  server.commandOrUrl,
                  style: AppTypography.bodyMain.copyWith(
                    fontSize: 10,
                    color: AppColors.outline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
