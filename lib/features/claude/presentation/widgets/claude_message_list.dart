import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/claude_message.dart';
import '../cubit/claude_sessions_cubit.dart';

class ClaudeMessageList extends HookWidget {
  const ClaudeMessageList({
    super.key,
    required this.workspaceId,
    required this.messages,
    required this.status,
    required this.lastError,
    required this.stderrTail,
  });

  final String workspaceId;
  final List<ClaudeMessage> messages;
  final ClaudeRunStatus status;
  final Failure? lastError;
  final List<String> stderrTail;

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!scrollController.hasClients) return;
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeOut,
        );
      });
      return null;
    }, [messages.length, _streamingTextSignature(messages)]);

    if (messages.isEmpty && lastError == null) {
      return _EmptyState(status: status);
    }

    final hasError =
        status == ClaudeRunStatus.error || status == ClaudeRunStatus.sessionDead;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        for (var i = 0; i < messages.length; i++) ...[
          _MessageBubble(message: messages[i]),
          if (i < messages.length - 1) const SizedBox(height: AppSpacing.xl),
        ],
        if (hasError) ...[
          const SizedBox(height: AppSpacing.xl),
          _ErrorBanner(failure: lastError, stderrTail: stderrTail),
        ],
      ],
    );
  }

  String _streamingTextSignature(List<ClaudeMessage> list) {
    if (list.isEmpty) return '';
    final last = list.last;
    if (last is ClaudeMessageAssistant && last.isStreaming) {
      return '${last.id}:${last.text.length}';
    }
    return '';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.status});

  final ClaudeRunStatus status;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'claude.empty.title'.tr(),
              style: AppTypography.bodyMain.copyWith(
                color: AppColors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'claude.empty.hint'.tr(),
              style: AppTypography.bodyMain.copyWith(
                color: AppColors.outline,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ClaudeMessage message;

  @override
  Widget build(BuildContext context) {
    return switch (message) {
      ClaudeMessageUser(:final text) => _UserBubble(text: text),
      ClaudeMessageAssistant(:final text, :final isStreaming) =>
        _AssistantBubble(text: text, isStreaming: isStreaming),
      ClaudeMessageTool(:final toolName, :final status) =>
        _ToolBubble(toolName: toolName, status: status),
      ClaudeMessageSystem(:final text) => _SystemBubble(text: text),
    };
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.chevron_right,
                size: 14, color: AppColors.outline),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'claude.message.userLabel'.tr(),
              style: AppTypography.terminalCode.copyWith(
                color: AppColors.outline,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'claude.message.promptDelimiter'.tr(),
              style: AppTypography.terminalCode.copyWith(
                color: AppColors.surfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xl - AppSpacing.xs),
          child: SelectableText(
            text,
            style: AppTypography.terminalCode.copyWith(
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble({required this.text, required this.isStreaming});

  final String text;
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.smart_toy_outlined,
                size: 14, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'claude.message.assistantLabel'.tr(),
              style: AppTypography.terminalPrompt.copyWith(
                color: AppColors.primary,
              ),
            ),
            if (isStreaming) ...[
              const SizedBox(width: AppSpacing.sm),
              const _BlinkingCursor(),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xl - AppSpacing.xs),
          child: SelectableText(
            text.isEmpty && isStreaming ? '…' : text,
            style: AppTypography.bodyMain.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _ToolBubble extends StatelessWidget {
  const _ToolBubble({required this.toolName, required this.status});

  final String toolName;
  final ClaudeToolStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ClaudeToolStatus.running => AppColors.tertiary,
      ClaudeToolStatus.completed => AppColors.outline,
      ClaudeToolStatus.error => AppColors.error,
    };
    final keyName = switch (status) {
      ClaudeToolStatus.running => 'claude.message.toolRunning',
      ClaudeToolStatus.completed => 'claude.message.toolCompleted',
      ClaudeToolStatus.error => 'claude.message.toolError',
    };
    final icon = switch (status) {
      ClaudeToolStatus.running => Symbols.sync,
      ClaudeToolStatus.completed => Symbols.check_circle,
      ClaudeToolStatus.error => Symbols.error,
    };
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xl - AppSpacing.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: AppSpacing.sm),
          Text(
            keyName.tr(namedArgs: {'name': toolName}),
            style: AppTypography.terminalCode.copyWith(
              color: color,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemBubble extends StatelessWidget {
  const _SystemBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xl - AppSpacing.xs),
      child: Text(
        text,
        style: AppTypography.terminalCode.copyWith(
          color: AppColors.outline,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _BlinkingCursor extends HookWidget {
  const _BlinkingCursor();

  @override
  Widget build(BuildContext context) {
    final visible = useState(true);
    useEffect(() {
      final timer = Stream.periodic(const Duration(milliseconds: 500))
          .listen((_) => visible.value = !visible.value);
      return timer.cancel;
    }, const []);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 120),
      opacity: visible.value ? 1.0 : 0.2,
      child: Container(
        width: 6,
        height: 12,
        color: AppColors.primary,
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.failure, required this.stderrTail});

  final Failure? failure;
  final List<String> stderrTail;

  String _renderFailure(Failure f) {
    if (f is SubprocessFailure) {
      if (f.message == 'binary_not_found') {
        return 'claude.error.binaryNotFound'.tr();
      }
      if (f.message == 'exit_code') {
        return 'claude.error.exitedNonZero'
            .tr(namedArgs: {'code': '${f.exitCode ?? -1}'});
      }
      return 'claude.error.spawnFailed'.tr(namedArgs: {'message': f.message});
    }
    if (f is ParsingFailure) {
      return 'claude.error.parseFailed'.tr();
    }
    if (f is UnexpectedFailure) {
      return 'claude.error.spawnFailed'.tr(namedArgs: {'message': f.message});
    }
    return f.toString();
  }

  @override
  Widget build(BuildContext context) {
    final message = failure != null ? _renderFailure(failure!) : '';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Symbols.error, size: 14, color: AppColors.error),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: SelectableText(
                  message,
                  style: AppTypography.bodyMain.copyWith(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (stderrTail.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            SelectableText(
              stderrTail.takeLast(8).join('\n'),
              style: AppTypography.terminalCode.copyWith(
                color: AppColors.outline,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

extension _TakeLast<T> on List<T> {
  Iterable<T> takeLast(int n) => skip(length - n.clamp(0, length));
}
