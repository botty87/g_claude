import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../cubit/workspaces_cubit.dart';

class NewWorkspaceButton extends StatefulWidget {
  const NewWorkspaceButton({super.key});

  @override
  State<NewWorkspaceButton> createState() => _NewWorkspaceButtonState();
}

class _NewWorkspaceButtonState extends State<NewWorkspaceButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => context.read<WorkspacesCubit>().openFromPicker(),
        child: Container(
          key: const ValueKey('new_workspace_button'),
          width: 28,
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: _hover ? AppColors.glassHover : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Icon(
            Symbols.add,
            size: 16,
            color: AppColors.onSurfaceVariant.withValues(alpha: _hover ? 1.0 : 0.7),
          ),
        ),
      ),
    );
  }
}
