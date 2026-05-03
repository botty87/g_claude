import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/slash_command_source.dart';

extension SlashCommandSourceColor on SlashCommandSource {
  Color get badgeColor => switch (this) {
        SlashCommandSource.cliBuiltin => AppColors.outline,
        SlashCommandSource.user => AppColors.brandIndigo,
        SlashCommandSource.project => AppColors.tertiary,
        SlashCommandSource.plugin => AppColors.primary,
        SlashCommandSource.skill => AppColors.secondary,
      };
}
