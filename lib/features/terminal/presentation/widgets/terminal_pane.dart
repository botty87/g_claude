import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:xterm/xterm.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/terminal_theme.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../../data/datasources/pty_datasource.dart';
import '../cubit/terminal_sessions_cubit.dart';

class TerminalPane extends HookWidget {
  const TerminalPane({super.key});

  @override
  Widget build(BuildContext context) {
    final activeId = context.select<WorkspacesCubit, String?>((c) => c.state.activeIdOrNull);

    if (activeId == null) {
      return const _NoWorkspaceState();
    }

    final hasSession = context.select<TerminalSessionsCubit, bool>((c) => c.state.sessions.containsKey(activeId));
    if (!hasSession) {
      return const _NoWorkspaceState();
    }

    return _TerminalPaneActive(key: ValueKey('terminal_pane_$activeId'), workspaceId: activeId);
  }
}

class _TerminalPaneActive extends HookWidget {
  const _TerminalPaneActive({super.key, required this.workspaceId});

  final String workspaceId;

  @override
  Widget build(BuildContext context) {
    final status = context.select<TerminalSessionsCubit, TerminalRunStatus>(
      (c) => c.state.sessions[workspaceId]?.status ?? TerminalRunStatus.starting,
    );
    final incarnation = context.select<TerminalSessionsCubit, int>(
      (c) => c.state.sessions[workspaceId]?.incarnation ?? 0,
    );

    final focusNode = useFocusNode();

    useEffect(() {
      if (status == TerminalRunStatus.running) {
        focusNode.requestFocus();
      }
      return null;
    }, [workspaceId, status]);

    // Retrieve the live Terminal + controller. Not memoized — always fetch
    // fresh so the widget picks up the new instances after a restart.
    final cubit = context.read<TerminalSessionsCubit>();
    final terminal = cubit.terminalFor(workspaceId);
    final controller = cubit.controllerFor(workspaceId);

    if (terminal == null || controller == null || status == TerminalRunStatus.starting) {
      return const _StartingState();
    }

    final isErrorState = status == TerminalRunStatus.exited || status == TerminalRunStatus.failed;

    return Stack(
      children: [
        Container(
          color: AppColors.surface,
          child: TerminalView(
            terminal,
            // Keyed on (workspaceId, incarnation): when restart() bumps the
            // incarnation, the View tears down cleanly and rebinds listeners
            // (onOutput/onResize) on the fresh Terminal handle. Unlike the
            // previous ObjectKey(terminal) approach, this works even if a
            // fast respawn skips the `starting` transition.
            key: ValueKey('terminal_$workspaceId#$incarnation'),
            controller: controller,
            theme: appTerminalTheme,
            textStyle: TerminalStyle.fromTextStyle(AppTypography.terminalCode),
            focusNode: focusNode,
            autofocus: !isErrorState,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            backgroundOpacity: 1,
            // Right-click handled by xterm's internal gesture detector;
            // an outer GestureDetector loses the gesture-arena fight.
            onSecondaryTapDown: (details, _) => _showContextMenu(context, details.globalPosition, terminal, controller),
          ),
        ),
        if (isErrorState) _ErrorOverlay(workspaceId: workspaceId, status: status),
      ],
    );
  }
}

Future<void> _showContextMenu(
  BuildContext context,
  Offset position,
  Terminal terminal,
  TerminalController controller,
) async {
  final selection = controller.selection;
  final hasSelection = selection != null;

  // Capture overlay size synchronously: the widget may unmount during the
  // showMenu await, after which `Overlay.of(context)` is no longer valid.
  final overlaySize = (Overlay.of(context).context.findRenderObject() as RenderBox).size;
  final result = await showMenu<_TerminalMenuAction>(
    context: context,
    position: RelativeRect.fromRect(Rect.fromLTWH(position.dx, position.dy, 0, 0), Offset.zero & overlaySize),
    items: [
      PopupMenuItem(value: _TerminalMenuAction.copy, enabled: hasSelection, child: Text(Locales.Terminal.Menu.copy)),
      PopupMenuItem(
        value: _TerminalMenuAction.paste,
        // Always enabled: clipboard contents are validated at action time.
        child: Text(Locales.Terminal.Menu.paste),
      ),
    ],
  );

  switch (result) {
    case _TerminalMenuAction.copy:
      if (selection == null) return;
      final text = terminal.buffer.getText(selection);
      await Clipboard.setData(ClipboardData(text: text));
    case _TerminalMenuAction.paste:
      final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
      final text = clipboard?.text;
      if (text == null || text.isEmpty) return;
      terminal.paste(text);
      controller.clearSelection();
    case null:
      return;
  }
}

enum _TerminalMenuAction { copy, paste }

/// Centered icon-or-spinner + label used for the "no workspace selected"
/// and "shell starting" placeholders. Both states have identical layout —
/// only the leading visual and the label differ.
class _PlaceholderState extends StatelessWidget {
  const _PlaceholderState({required this.leading, required this.label});

  final Widget leading;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(height: AppSpacing.md),
          Text(label, style: AppTypography.bodyMain.copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _NoWorkspaceState extends StatelessWidget {
  const _NoWorkspaceState();

  @override
  Widget build(BuildContext context) {
    return _PlaceholderState(
      leading: const Icon(Symbols.terminal, size: 32, color: AppColors.onSurfaceVariant),
      label: Locales.Terminal.noWorkspace,
    );
  }
}

class _StartingState extends StatelessWidget {
  const _StartingState();

  @override
  Widget build(BuildContext context) {
    return _PlaceholderState(
      leading: const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandIndigo),
      ),
      label: Locales.Terminal.starting,
    );
  }
}

class _ErrorOverlay extends StatelessWidget {
  const _ErrorOverlay({required this.workspaceId, required this.status});

  final String workspaceId;
  final TerminalRunStatus status;

  @override
  Widget build(BuildContext context) {
    final exitCode = context.select<TerminalSessionsCubit, int?>((c) => c.state.sessions[workspaceId]?.exitCode);
    final lastError = context.select<TerminalSessionsCubit, String?>((c) => c.state.sessions[workspaceId]?.lastError);

    final message = status == TerminalRunStatus.failed && lastError != null
        ? Locales.Terminal.spawnFailed(message: lastError)
        : Locales.Terminal.exited(code: '${exitCode ?? 0}');

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        color: AppColors.surfaceContainerHigh,
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMain.copyWith(color: AppColors.onSurfaceVariant, fontSize: 12),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            TextButton(
              onPressed: () => context.read<TerminalSessionsCubit>().restart(workspaceId),
              child: Text(
                Locales.Terminal.restart,
                style: AppTypography.bodyMain.copyWith(color: AppColors.brandIndigo, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
