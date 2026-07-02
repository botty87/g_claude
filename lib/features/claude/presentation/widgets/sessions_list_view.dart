import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../../domain/entities/chat_session_summary.dart';
import '../cubit/chat_history_cubit.dart';
import '../cubit/claude_sessions_cubit.dart';

class SessionsListView extends HookWidget {
  const SessionsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final active = context.select<WorkspacesCubit, Workspace?>((c) => c.state.activeWorkspace);
    if (active == null) {
      return const SizedBox.shrink();
    }

    final searchController = useTextEditingController();
    final query = useState('');
    useEffect(() {
      void l() => query.value = searchController.text;
      searchController.addListener(l);
      return () => searchController.removeListener(l);
    }, [searchController]);

    useEffect(() {
      context.read<ChatHistoryCubit>().setQuery(active.id, query.value);
      return null;
    }, [query.value, active.id]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SessionsHeader(onRefresh: () => context.read<ChatHistoryCubit>().refresh(active.id, active.path)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: Locales.Sessions.List.search,
              prefixIcon: const Icon(Symbols.search, size: 16),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.sm)),
            ),
            style: AppTypography.bodyMain.copyWith(fontSize: 12),
          ),
        ),
        Expanded(
          child: BlocBuilder<ChatHistoryCubit, ChatHistoryState>(
            buildWhen: (p, c) => p.byWorkspace[active.id] != c.byWorkspace[active.id],
            builder: (context, state) {
              final h = state.historyFor(active.id);
              if (h == null || h.status == HistoryStatus.loading && h.sessions.isEmpty) {
                return const Center(
                  child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              final list = h.query.trim().isEmpty ? h.sessions : (h.searchResults ?? const <ChatSessionSummary>[]);
              if (h.searchLoading && list.isEmpty) {
                return const Center(
                  child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    Locales.Sessions.List.empty,
                    style: AppTypography.bodyMain.copyWith(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final s = list[i];
                  final isSelected = h.selectedId == s.id;
                  return _SessionRow(
                    key: ValueKey<String>('session_row_${s.id}'),
                    summary: s,
                    isSelected: isSelected,
                    workspaceId: active.id,
                  );
                },
              );
            },
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.outlineVariant, width: 1)),
          ),
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: TextButton.icon(
            key: const ValueKey<String>('sessions_new_chat'),
            onPressed: () {
              context.read<ClaudeSessionsCubit>().openNewSession(active.id);
              context.read<ChatHistoryCubit>().clearSelection(active.id);
            },
            icon: const Icon(Symbols.add, size: 16),
            label: Text(Locales.Sessions.List.newChat),
          ),
        ),
      ],
    );
  }
}

class _SessionsHeader extends StatelessWidget {
  const _SessionsHeader({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      child: Row(
        children: [
          Text(
            Locales.Sessions.List.headerLabel,
            style: AppTypography.sidebarLabel.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const Spacer(),
          Tooltip(
            message: Locales.Sessions.List.refresh,
            child: _HeaderIconButton(icon: Symbols.refresh, onTap: onRefresh),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      onTap: onTap,
      builder: (context, hover) {
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: hover ? AppColors.glassHover : Colors.transparent,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Icon(icon, size: 14, color: hover ? AppColors.onSurface : AppColors.onSurfaceVariant),
        );
      },
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({super.key, required this.summary, required this.isSelected, required this.workspaceId});

  final ChatSessionSummary summary;
  final bool isSelected;
  final String workspaceId;

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      onTap: () => context.read<ChatHistoryCubit>().selectSession(workspaceId, summary.id),
      builder: (context, hover) {
        Color? bg;
        if (isSelected) {
          bg = AppColors.surfaceContainer;
        } else if (hover) {
          bg = AppColors.glassHover;
        }

        return Container(
          constraints: const BoxConstraints(minHeight: 44),
          color: bg,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      summary.title.isEmpty ? Locales.Sessions.List.untitled : summary.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMain.copyWith(fontSize: 12, color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _relativeDate(summary.lastMessageAt),
                      style: AppTypography.bodyMain.copyWith(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Text(
                  '${summary.messageCount}',
                  style: AppTypography.bodyMain.copyWith(fontSize: 10, color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _relativeDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return Locales.Sessions.List.RelativeDate.now;
    if (diff.inMinutes < 60) {
      return Locales.Sessions.List.RelativeDate.minutesAgo(n: '${diff.inMinutes}');
    }
    if (diff.inHours < 24) {
      return Locales.Sessions.List.RelativeDate.hoursAgo(n: '${diff.inHours}');
    }
    final yesterday = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
    final dtDay = DateTime(dt.year, dt.month, dt.day);
    if (dtDay == yesterday) return Locales.Sessions.List.RelativeDate.yesterday;
    if (dt.year == now.year) {
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
    }
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${(dt.year % 100).toString().padLeft(2, '0')}';
  }
}
