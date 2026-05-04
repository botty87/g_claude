import 'dart:async';

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
import '../../domain/entities/app_log_session.dart';
import '../cubit/app_log_detail_cubit.dart';
import '../cubit/app_logs_cubit.dart';
import 'log_entry_tile.dart';
import 'log_level_filter_chip.dart';
import 'log_session_tile.dart';

class LogsView extends StatelessWidget {
  const LogsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLogsCubit, AppLogsState>(
      buildWhen: (p, c) => p.selectedSessionId != c.selectedSessionId,
      builder: (context, state) {
        return state.selectedSessionId == null
            ? const _SessionsList()
            : const _Detail();
      },
    );
  }
}

class _SessionsList extends StatelessWidget {
  const _SessionsList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Header(),
        Expanded(
          child: BlocBuilder<AppLogsCubit, AppLogsState>(
            buildWhen: (p, c) =>
                p.sessions != c.sessions || p.loading != c.loading,
            builder: (context, state) {
              if (state.loading && state.sessions.isEmpty) {
                return const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              if (state.sessions.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    Locales.AppLogs.empty,
                    style: AppTypography.bodyMain.copyWith(
                      fontSize: 12,
                      color:
                          AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: state.sessions.length,
                itemBuilder: (context, i) {
                  final s = state.sessions[i];
                  return LogSessionTile(
                    key: ValueKey<int>(s.id),
                    session: s,
                    isSelected: false,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Text(
            Locales.AppLogs.title.toUpperCase(),
            style: AppTypography.sidebarLabel.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Tooltip(
            message: Locales.AppLogs.deleteAll,
            child: _IconButton(
              icon: Symbols.delete_sweep,
              onTap: () => _confirmDeleteAll(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final cubit = context.read<AppLogsCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(Locales.AppLogs.deleteAllConfirmTitle),
        content: Text(Locales.AppLogs.deleteAllConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(Locales.AppLogs.deleteAllConfirmCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(Locales.AppLogs.deleteAllConfirmOk),
          ),
        ],
      ),
    );
    if (ok == true) await cubit.deleteAll();
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      onTap: onTap,
      builder: (context, hover) {
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: hover ? AppColors.glassHover : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Icon(
            icon,
            size: 14,
            color: hover ? AppColors.onSurface : AppColors.onSurfaceVariant,
          ),
        );
      },
    );
  }
}

class _Detail extends HookWidget {
  const _Detail();

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final debounce = useRef<Timer?>(null);
    useEffect(() {
      void l() {
        debounce.value?.cancel();
        debounce.value = Timer(const Duration(milliseconds: 200), () {
          if (context.mounted) {
            context
                .read<AppLogDetailCubit>()
                .setSearch(searchController.text);
          }
        });
      }

      searchController.addListener(l);
      return () {
        debounce.value?.cancel();
        searchController.removeListener(l);
      };
    }, [searchController]);

    final session = context.select<AppLogsCubit, AppLogSession?>((c) {
      final id = c.state.selectedSessionId;
      if (id == null) return null;
      for (final s in c.state.sessions) {
        if (s.id == id) return s;
      }
      return null;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              _IconButton(
                icon: Symbols.arrow_back,
                onTap: () => context.read<AppLogsCubit>().clearSelection(),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  session == null
                      ? Locales.AppLogs.title
                      : _sessionLabel(session),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.sidebarLabel.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: Locales.AppLogs.Detail.search,
              prefixIcon: const Icon(Symbols.search, size: 16),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
            ),
            style: AppTypography.bodyMain.copyWith(fontSize: 12),
          ),
        ),
        const LogLevelFilterChips(),
        const Divider(height: 1, color: AppColors.outlineVariant),
        Expanded(
          child: BlocBuilder<AppLogDetailCubit, AppLogDetailState>(
            buildWhen: (p, c) =>
                p.entries != c.entries || p.loading != c.loading,
            builder: (context, state) {
              if (state.loading && state.entries.isEmpty) {
                return const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              if (state.entries.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    Locales.AppLogs.Detail.empty,
                    style: AppTypography.bodyMain.copyWith(
                      fontSize: 12,
                      color:
                          AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: state.entries.length,
                itemBuilder: (context, i) {
                  final e = state.entries[i];
                  return LogEntryTile(
                    key: ValueKey<int>(e.id),
                    entry: e,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _sessionLabel(AppLogSession s) {
    final start = _fmt(s.startedAt);
    return s.endedAt == null
        ? '$start  ·  ${Locales.AppLogs.Session.inProgress}'
        : start;
  }

  String _fmt(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)} ${two(dt.hour)}:${two(dt.minute)}';
  }
}
