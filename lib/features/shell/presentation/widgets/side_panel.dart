import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../explorer/presentation/widgets/explorer_view.dart';

class SidePanel extends StatelessWidget {
  const SidePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(
          right: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      child: const ExplorerView(),
    );
  }
}
