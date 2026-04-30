import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'claude_input_bar.dart';
import 'claude_message_list.dart';
import 'claude_terminal_header.dart';

class ClaudeTerminalPane extends StatelessWidget {
  const ClaudeTerminalPane({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.surface,
      child: Column(
        children: [
          ClaudeTerminalHeader(),
          Expanded(child: ClaudeMessageList()),
          ClaudeInputBar(),
        ],
      ),
    );
  }
}
