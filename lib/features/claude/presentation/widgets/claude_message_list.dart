import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/pretty_json.dart';
import '../../../../core/di/di.dart';
import '../../../editor/presentation/cubit/file_tabs_cubit.dart';
import '../../../explorer/presentation/cubit/explorer_cubit.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../../domain/entities/claude_message.dart';
import '../cubit/claude_sessions_cubit.dart';
import 'ask_user_question_card.dart';
import 'clickable_code_builder.dart';
import 'clickable_code_resolver.dart';
import 'permission_request_card.dart';
import 'user_bubble_chip.dart';

const _kAnimDuration = Duration(milliseconds: 180);
const _kToolBodyMaxHeight = 200.0;
const _kStickThreshold = 48.0;

(IconData, Color) _toolGroupHeaderIconAndColor({
  required int running,
  required int errors,
}) {
  if (errors > 0) return (Symbols.error, AppColors.error);
  if (running > 0) return (Symbols.sync, AppColors.tertiary);
  return (Symbols.check_circle, AppColors.outline);
}

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
    final stickToBottom = useState(true);

    useEffect(() {
      void onScroll() {
        if (!scrollController.hasClients) return;
        final pos = scrollController.position;
        final distanceFromBottom = pos.maxScrollExtent - pos.pixels;
        final atBottom = distanceFromBottom <= _kStickThreshold;
        if (stickToBottom.value != atBottom) {
          stickToBottom.value = atBottom;
        }
      }
      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    useEffect(() {
      if (!stickToBottom.value) return null;
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

    final lastUserId = useMemoized(() {
      for (var i = messages.length - 1; i >= 0; i--) {
        final m = messages[i];
        if (m is ClaudeMessageUser) return m.id;
      }
      return '';
    }, [messages]);

    useEffect(() {
      if (lastUserId.isEmpty) return null;
      stickToBottom.value = true;
      return null;
    }, [lastUserId]);

    if (messages.isEmpty && lastError == null) {
      return _EmptyState(status: status);
    }

    final hasError =
        status == ClaudeRunStatus.error || status == ClaudeRunStatus.sessionDead;

    final items = useMemoized(() => _buildItems(messages), [messages]);

    return Stack(
      children: [
        ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          itemCount: items.length + (hasError ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == items.length) {
              return Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: _ErrorBanner(failure: lastError, stderrTail: stderrTail),
              );
            }
            final item = items[index];
            final previous = index > 0 ? items[index - 1] : null;
            final gap = _gapBefore(previous, item);
            return Padding(
              key: ValueKey(item.key),
              padding: EdgeInsets.only(top: gap),
              child: _ItemRenderer(item: item, workspaceId: workspaceId),
            );
          },
        ),
        Positioned(
          right: AppSpacing.lg,
          bottom: AppSpacing.lg,
          child: AnimatedSwitcher(
            duration: _kAnimDuration,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: ScaleTransition(scale: anim, child: child),
            ),
            child: stickToBottom.value
                ? const SizedBox.shrink()
                : _ScrollToBottomFab(
                    onTap: () {
                      stickToBottom.value = true;
                      if (!scrollController.hasClients) return;
                      scrollController.animateTo(
                        scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  /// Groups consecutive tools into one [_ToolGroupItem] and emits user
  /// prompt → tool group → assistant text(s) per turn.
  List<_Item> _buildItems(List<ClaudeMessage> all) {
    final items = <_Item>[];
    var i = 0;
    while (i < all.length) {
      final m = all[i];
      if (m is ClaudeMessageUser) {
        items.add(_SingleItem(m));
        i++;
        final tools = <ClaudeMessageTool>[];
        final others = <ClaudeMessage>[];
        while (i < all.length && all[i] is! ClaudeMessageUser) {
          final t = all[i];
          if (t is ClaudeMessageTool) {
            tools.add(t);
          } else {
            others.add(t);
          }
          i++;
        }
        if (tools.isNotEmpty) items.add(_ToolGroupItem(tools));
        for (final o in others) {
          items.add(_SingleItem(o));
        }
      } else {
        if (m is ClaudeMessageTool) {
          items.add(_ToolGroupItem([m]));
        } else {
          items.add(_SingleItem(m));
        }
        i++;
      }
    }
    return items;
  }

  double _gapBefore(_Item? previous, _Item current) {
    if (previous == null) return 0;
    if (previous.role != current.role) return AppSpacing.lg;
    return AppSpacing.sm;
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

enum _Role { user, assistant, tools, system, askUser, permission }

sealed class _Item {
  const _Item();
  _Role get role;
  String get key;
}

class _SingleItem extends _Item {
  const _SingleItem(this.message);
  final ClaudeMessage message;
  @override
  _Role get role => switch (message) {
        ClaudeMessageUser() => _Role.user,
        ClaudeMessageAssistant() => _Role.assistant,
        ClaudeMessageTool() => _Role.tools,
        ClaudeMessageSystem() => _Role.system,
        ClaudeMessageAskUserQuestion() => _Role.askUser,
        ClaudeMessagePermissionRequest() => _Role.permission,
      };
  @override
  String get key => switch (message) {
        ClaudeMessageUser(:final id) => id,
        ClaudeMessageAssistant(:final id) => id,
        ClaudeMessageTool(:final id) => id,
        ClaudeMessageSystem(:final id) => id,
        ClaudeMessageAskUserQuestion(:final id) => id,
        ClaudeMessagePermissionRequest(:final id) => id,
      };
}

class _ToolGroupItem extends _Item {
  const _ToolGroupItem(this.tools);
  final List<ClaudeMessageTool> tools;
  @override
  _Role get role => _Role.tools;
  @override
  String get key => 'tg-${tools.first.id}';
}

class _ItemRenderer extends StatelessWidget {
  const _ItemRenderer({required this.item, required this.workspaceId});
  final _Item item;
  final String workspaceId;
  @override
  Widget build(BuildContext context) {
    return switch (item) {
      _SingleItem(:final message) =>
        _MessageItem(message: message, workspaceId: workspaceId),
      _ToolGroupItem(:final tools) => _ToolGroup(tools: tools),
    };
  }
}

class _ScrollToBottomFab extends StatelessWidget {
  const _ScrollToBottomFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: Locales.Claude.Message.scrollToBottomTooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadii.full),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.6),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: const Icon(
              Symbols.keyboard_double_arrow_down,
              size: 20,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
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
              Locales.Claude.Empty.title,
              style: AppTypography.bodyMain.copyWith(
                color: AppColors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              Locales.Claude.Empty.hint,
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

class _MessageItem extends StatelessWidget {
  const _MessageItem({required this.message, required this.workspaceId});

  final ClaudeMessage message;
  final String workspaceId;

  @override
  Widget build(BuildContext context) {
    return switch (message) {
      final ClaudeMessageUser m => _UserBubble(message: m),
      ClaudeMessageAssistant(:final text, :final isStreaming) =>
        _AssistantBlock(
          text: text,
          isStreaming: isStreaming,
          workspaceId: workspaceId,
        ),
      ClaudeMessageTool(
        :final toolName,
        :final status,
        :final input,
        :final output,
        :final isError,
      ) =>
        _ToolCard(
          toolName: toolName,
          status: status,
          input: input,
          output: output,
          isError: isError,
        ),
      ClaudeMessageSystem(:final text) => _SystemLine(text: text),
      final ClaudeMessageAskUserQuestion m => _AskUserQuestionItemWidget(
          message: m,
          workspaceId: workspaceId,
        ),
      final ClaudeMessagePermissionRequest m => _PermissionRequestItemWidget(
          message: m,
          workspaceId: workspaceId,
        ),
    };
  }
}

class _AskUserQuestionItemWidget extends StatelessWidget {
  const _AskUserQuestionItemWidget({
    required this.message,
    required this.workspaceId,
  });

  final ClaudeMessageAskUserQuestion message;
  final String workspaceId;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ClaudeSessionsCubit>();
    return AskUserQuestionCard(
      message: message,
      onSubmit: (answers) =>
          cubit.answerAskUserQuestion(workspaceId, message.id, answers),
    );
  }
}

class _PermissionRequestItemWidget extends StatelessWidget {
  const _PermissionRequestItemWidget({
    required this.message,
    required this.workspaceId,
  });

  final ClaudeMessagePermissionRequest message;
  final String workspaceId;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ClaudeSessionsCubit>();
    return PermissionRequestCard(
      message: message,
      onDecide: (decision) =>
          cubit.answerPermission(workspaceId, message.id, decision),
    );
  }
}

class _ToolGroup extends HookWidget {
  const _ToolGroup({required this.tools});

  final List<ClaudeMessageTool> tools;

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);

    var running = 0;
    var errors = 0;
    var done = 0;
    for (final t in tools) {
      switch (t.status) {
        case ClaudeToolStatus.running:
          running++;
        case ClaudeToolStatus.error:
          errors++;
        case ClaudeToolStatus.completed:
          done++;
      }
    }

    final (headerIcon, headerColor) = _toolGroupHeaderIconAndColor(
      running: running,
      errors: errors,
    );

    final summary = _summary(running: running, done: done, errors: errors);

    final bulletColor = errors > 0 ? AppColors.error : AppColors.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: _StepBullet(color: bulletColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: AnimatedContainer(
          duration: _kAnimDuration,
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: () => expanded.value = !expanded.value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        headerIcon,
                        size: 14,
                        color: headerColor,
                        fill: errors == 0 && running == 0 ? 1 : 0,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        Locales.Claude.Message.toolGroupTitle(count: '${tools.length}'),
                        style: AppTypography.bodyMain.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          summary,
                          style: AppTypography.bodyMain.copyWith(
                            color: AppColors.outline,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AnimatedRotation(
                        duration: _kAnimDuration,
                        turns: expanded.value ? 0.5 : 0,
                        child: Icon(
                          Symbols.expand_more,
                          size: 16,
                          color: AppColors.outline.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ClipRect(
                child: AnimatedSize(
                  duration: _kAnimDuration,
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: expanded.value
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.sm,
                            0,
                            AppSpacing.sm,
                            AppSpacing.sm,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Divider(
                                height: AppSpacing.sm,
                                thickness: 0.5,
                                color: AppColors.outlineVariant,
                              ),
                              for (var i = 0; i < tools.length; i++) ...[
                                if (i > 0) const SizedBox(height: AppSpacing.xs),
                                _NestedToolCard(tool: tools[i]),
                              ],
                            ],
                          ),
                        )
                      : const SizedBox(width: double.infinity, height: 0),
                ),
              ),
            ],
          ),
            ),
          ),
        ),
      ],
    );
  }

  String _summary({required int running, required int done, required int errors}) {
    final parts = <String>[];
    if (running > 0) {
      parts.add(Locales.Claude.Message.toolGroupRunning(n: '$running'));
    }
    if (done > 0) {
      parts.add(Locales.Claude.Message.toolGroupDone(n: '$done'));
    }
    if (errors > 0) {
      parts.add(Locales.Claude.Message.toolGroupErrors(n: '$errors'));
    }
    return parts.join(' · ');
  }
}

class _NestedToolCard extends StatelessWidget {
  const _NestedToolCard({required this.tool});

  final ClaudeMessageTool tool;

  @override
  Widget build(BuildContext context) {
    return _ToolCard(
      toolName: tool.toolName,
      status: tool.status,
      input: tool.input,
      output: tool.output,
      isError: tool.isError,
      padded: false,
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.message});

  final ClaudeMessageUser message;

  @override
  Widget build(BuildContext context) {
    final hasChips =
        message.slashTriggers.isNotEmpty || message.attachments.isNotEmpty;
    final hasText = message.text.isNotEmpty;
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(4),
            ),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasChips)
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final t in message.slashTriggers)
                      BubbleSlashChip(trigger: t),
                    for (final a in message.attachments)
                      BubbleAttachmentChip(attachment: a),
                  ],
                ),
              if (hasChips && hasText) const SizedBox(height: AppSpacing.xs),
              if (hasText)
                SelectableText(
                  message.text,
                  style: AppTypography.bodyMain.copyWith(
                    color: AppColors.onSurface,
                    height: 1.45,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssistantBlock extends HookWidget {
  const _AssistantBlock({
    required this.text,
    required this.isStreaming,
    required this.workspaceId,
  });

  final String text;
  final bool isStreaming;
  final String workspaceId;

  @override
  Widget build(BuildContext context) {
    final showPulse = text.isEmpty && isStreaming;

    final cwd = context.select<WorkspacesCubit, String?>(
      (c) => c.state.workspacesOrEmpty
          .firstWhereOrNull((w) => w.id == workspaceId)
          ?.path,
    );
    final tree = context.select<ExplorerCubit, WorkspaceTree?>(
      (c) => c.state.trees[workspaceId],
    );
    final basenameIndex = useMemoized<Map<String, List<String>>>(
      () => tree == null ? const {} : buildBasenameIndex(tree),
      [tree],
    );

    final builders = useMemoized<Map<String, MarkdownElementBuilder>>(
      () {
        if (cwd == null) return const {};
        return {
          'code': ClickableCodeBuilder(
            cwd: cwd,
            basenameIndex: basenameIndex,
            onTapPath: (absPath) =>
                getIt<FileTabsCubit>().openFile(workspaceId, absPath),
          ),
        };
      },
      [cwd, basenameIndex, workspaceId],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: _StepBullet(
            color: AppColors.primary,
            pulsing: showPulse,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: showPulse
              ? const SizedBox(height: 18)
              : MarkdownBody(
                  data: text,
                  selectable: true,
                  softLineBreak: true,
                  styleSheet: _markdownStyle,
                  builders: builders,
                ),
        ),
      ],
    );
  }
}

class _StepBullet extends HookWidget {
  const _StepBullet({
    required this.color,
    this.pulsing = false,
  });

  static const double _size = 7;

  final Color color;
  final bool pulsing;

  @override
  Widget build(BuildContext context) {
    if (!pulsing) {
      return Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
    }
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        final scale = 0.65 + 0.35 * t;
        final opacity = 0.45 + 0.55 * t;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              color: color.withValues(alpha: opacity),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

final MarkdownStyleSheet _markdownStyle = _buildMarkdownStyle();

MarkdownStyleSheet _buildMarkdownStyle() {
  final body = AppTypography.bodyMain.copyWith(
    color: AppColors.onSurface,
    height: 1.55,
  );
  final code = AppTypography.terminalCode.copyWith(
    color: AppColors.onSurface,
    fontSize: 12.5,
    height: 1.5,
  );
  return MarkdownStyleSheet(
    p: body,
    h1: body.copyWith(fontSize: 18, fontWeight: FontWeight.w700, height: 1.3),
    h2: body.copyWith(fontSize: 16, fontWeight: FontWeight.w700, height: 1.3),
    h3: body.copyWith(fontSize: 14, fontWeight: FontWeight.w700, height: 1.35),
    strong: body.copyWith(
      color: AppColors.onSurface,
      fontWeight: FontWeight.w700,
    ),
    em: body.copyWith(fontStyle: FontStyle.italic),
    blockquote: body.copyWith(color: AppColors.onSurfaceVariant),
    blockquoteDecoration: BoxDecoration(
      border: Border(
        left: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.5),
          width: 3,
        ),
      ),
    ),
    blockquotePadding: const EdgeInsets.only(left: AppSpacing.md),
    listBullet: body,
    listIndent: 22,
    code: code.copyWith(
      backgroundColor: AppColors.surfaceContainerLow,
      color: AppColors.tertiary,
    ),
    codeblockPadding: const EdgeInsets.all(AppSpacing.md),
    codeblockDecoration: BoxDecoration(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadii.md),
      border: Border.all(
        color: AppColors.outlineVariant.withValues(alpha: 0.5),
      ),
    ),
    a: body.copyWith(
      color: AppColors.secondary,
      decoration: TextDecoration.underline,
    ),
    horizontalRuleDecoration: BoxDecoration(
      border: Border(
        top: BorderSide(
          color: AppColors.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
    ),
    tableHead: body.copyWith(fontWeight: FontWeight.w700),
    tableBody: body,
    tableBorder: TableBorder.all(
      color: AppColors.outlineVariant.withValues(alpha: 0.4),
      width: 1,
    ),
    tableCellsPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    pPadding: EdgeInsets.zero,
    h1Padding: const EdgeInsets.only(top: AppSpacing.sm),
    h2Padding: const EdgeInsets.only(top: AppSpacing.sm),
    h3Padding: const EdgeInsets.only(top: AppSpacing.sm),
  );
}

class _ToolCard extends HookWidget {
  const _ToolCard({
    required this.toolName,
    required this.status,
    this.input,
    this.output,
    this.isError = false,
    this.padded = true,
  });

  final String toolName;
  final ClaudeToolStatus status;
  final Map<String, dynamic>? input;
  final String? output;
  final bool isError;
  final bool padded;

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);
    final hasBody =
        (input?.isNotEmpty ?? false) || (output?.isNotEmpty ?? false);

    final (icon, color, toolLabel) = switch (status) {
      ClaudeToolStatus.running => (
          Symbols.sync,
          AppColors.tertiary,
          Locales.Claude.Message.toolRunning,
        ),
      ClaudeToolStatus.completed => (
          Symbols.check_circle,
          AppColors.outline,
          Locales.Claude.Message.toolCompleted,
        ),
      ClaudeToolStatus.error => (
          Symbols.error,
          AppColors.error,
          Locales.Claude.Message.toolError,
        ),
    };

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: _kAnimDuration,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: hasBody ? () => expanded.value = !expanded.value : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 12,
                        color: color,
                        fill: status == ClaudeToolStatus.completed ? 1 : 0,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        Locales.Claude.Message.toolPrefix,
                        style: AppTypography.bodyMain.copyWith(
                          color: AppColors.outline,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        toolName,
                        style: AppTypography.terminalCode.copyWith(
                          color: color,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        toolLabel,
                        style: AppTypography.bodyMain.copyWith(
                          color: AppColors.outline,
                          fontSize: 10.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (hasBody) ...[
                        const SizedBox(width: AppSpacing.sm),
                        AnimatedRotation(
                          duration: _kAnimDuration,
                          turns: expanded.value ? 0.5 : 0,
                          child: Icon(
                            Symbols.expand_more,
                            size: 14,
                            color: AppColors.outline.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              ClipRect(
                child: AnimatedSize(
                  duration: _kAnimDuration,
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: expanded.value && hasBody
                      ? _ToolBody(
                          input: input,
                          output: output,
                          isError: isError,
                          maxHeight: _kToolBodyMaxHeight,
                        )
                      : const SizedBox(width: double.infinity, height: 0),
                ),
              ),
            ],
          ),
      ),
    );
    if (!padded) return card;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 9),
          child: _StepBullet(color: color),
        ),
        const SizedBox(width: 10),
        Expanded(child: card),
      ],
    );
  }
}

class _ToolBody extends HookWidget {
  const _ToolBody({
    required this.input,
    required this.output,
    required this.isError,
    required this.maxHeight,
  });

  final Map<String, dynamic>? input;
  final String? output;
  final bool isError;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final hasInput = input?.isNotEmpty ?? false;
    final hasOutput = output?.isNotEmpty ?? false;
    final encodedInput = useMemoized(
      () => hasInput ? prettyJson.convert(input) : '',
      [input],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        0,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasInput)
            _ToolBodySection(
              label: Locales.Claude.Message.toolInput,
              body: encodedInput,
              maxHeight: maxHeight,
              tone: AppColors.onSurfaceVariant,
            ),
          if (hasInput && hasOutput) const SizedBox(height: AppSpacing.xs),
          if (hasOutput)
            _ToolBodySection(
              label: isError
                  ? Locales.Claude.Message.toolErrorOutput
                  : Locales.Claude.Message.toolResult,
              body: output!,
              maxHeight: maxHeight,
              tone: isError ? AppColors.error : AppColors.onSurface,
            ),
        ],
      ),
    );
  }
}

class _ToolBodySection extends HookWidget {
  const _ToolBodySection({
    required this.label,
    required this.body,
    required this.maxHeight,
    required this.tone,
  });

  final String label;
  final String body;
  final double maxHeight;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.xs,
            bottom: AppSpacing.xs,
          ),
          child: Text(
            label,
            style: AppTypography.bodyMain.copyWith(
              color: AppColors.outline,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Scrollbar(
              controller: scrollController,
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: SelectableText(
                  body,
                  style: AppTypography.terminalCode.copyWith(
                    color: tone,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SystemLine extends StatelessWidget {
  const _SystemLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isCompletion = text == LocaleKeys.claude_message_completionStub;
    final rendered = isCompletion ? text.tr() : text;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 7),
          child: _StepBullet(color: AppColors.outline),
        ),
        const SizedBox(width: 10),
        if (isCompletion) ...[
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(
              Symbols.check_circle,
              size: 12,
              color: AppColors.outline,
              fill: 1,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
        Flexible(
          child: Text(
            rendered,
            style: (isCompletion
                    ? AppTypography.bodyMain
                    : AppTypography.terminalCode)
                .copyWith(
              color: AppColors.outline,
              fontSize: isCompletion ? 12 : 11,
              fontStyle: isCompletion ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
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
        return Locales.Claude.Error.binaryNotFound;
      }
      if (f.message == 'exit_code') {
        return Locales.Claude.Error.exitedNonZero(code: '${f.exitCode ?? -1}');
      }
      return Locales.Claude.Error.spawnFailed(message: f.message);
    }
    if (f is ParsingFailure) {
      return Locales.Claude.Error.parseFailed;
    }
    if (f is UnexpectedFailure) {
      return Locales.Claude.Error.spawnFailed(message: f.message);
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
        borderRadius: BorderRadius.circular(AppRadii.md),
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
