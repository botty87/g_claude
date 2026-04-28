import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../cubit/workspaces_cubit.dart';

class NewWorkspaceButton extends StatelessWidget {
  const NewWorkspaceButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      onTap: () => context.read<WorkspacesCubit>().openFromPicker(),
      builder: (context, hover) => Container(
        key: const ValueKey('new_workspace_button'),
        width: 28,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: hover ? AppColors.glassHover : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Icon(
          Symbols.add,
          size: 16,
          color: AppColors.onSurfaceVariant.withValues(alpha: hover ? 1.0 : 0.7),
        ),
      ),
    );
  }
}
