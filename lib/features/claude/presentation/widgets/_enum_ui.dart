import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/claude_permission_mode.dart';
import '../cubit/claude_sessions_cubit.dart';

extension ClaudePermissionModeUi on ClaudePermissionMode {
  IconData get icon {
    switch (this) {
      case ClaudePermissionMode.plan:
        return Symbols.visibility;
      case ClaudePermissionMode.acceptEdits:
        return Symbols.edit_note;
      case ClaudePermissionMode.auto:
        return Symbols.auto_awesome;
      case ClaudePermissionMode.bypassPermissions:
        return Symbols.bolt;
      case ClaudePermissionMode.defaultMode:
        return Symbols.shield;
    }
  }

  Color get color {
    switch (this) {
      case ClaudePermissionMode.plan:
        return AppColors.secondary;
      case ClaudePermissionMode.acceptEdits:
        return AppColors.primary;
      case ClaudePermissionMode.auto:
        return AppColors.brandIndigo;
      case ClaudePermissionMode.bypassPermissions:
        return AppColors.tertiary;
      case ClaudePermissionMode.defaultMode:
        return AppColors.outline;
    }
  }
}

extension ClaudeRunStatusUi on ClaudeRunStatus {
  Color get color {
    switch (this) {
      case ClaudeRunStatus.idle:
        return AppColors.outline;
      case ClaudeRunStatus.connecting:
        return AppColors.tertiary;
      case ClaudeRunStatus.running:
        return AppColors.secondary;
      case ClaudeRunStatus.compacting:
        return AppColors.tertiary;
      case ClaudeRunStatus.error:
      case ClaudeRunStatus.sessionDead:
        return AppColors.error;
    }
  }

  String get labelKey {
    switch (this) {
      case ClaudeRunStatus.idle:
        return 'claude.terminal.status.idle';
      case ClaudeRunStatus.connecting:
        return 'claude.terminal.status.connecting';
      case ClaudeRunStatus.running:
        return 'claude.terminal.status.running';
      case ClaudeRunStatus.compacting:
        return 'claude.terminal.status.compacting';
      case ClaudeRunStatus.error:
        return 'claude.terminal.status.error';
      case ClaudeRunStatus.sessionDead:
        return 'claude.terminal.status.sessionDead';
    }
  }
}
