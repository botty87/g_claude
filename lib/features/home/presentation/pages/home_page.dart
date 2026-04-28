import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/conversation_pane.dart';
import '../widgets/idle_pane.dart';
import '../widgets/side_nav_bar.dart';
import '../widgets/top_header.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _tabs = ['main.py', 'terminal', 'logs'];
  String _activeTab = 'main.py';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          TopHeader(
            tabs: _tabs,
            activeTab: _activeTab,
            onTabSelected: (t) => setState(() => _activeTab = t),
          ),
          const Expanded(
            child: Row(
              children: [
                SideNavBar(),
                Expanded(child: _Workspace()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Workspace extends StatelessWidget {
  const _Workspace();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.paneGap),
      child: Row(
        children: const [
          Expanded(child: ConversationPane()),
          SizedBox(width: AppSpacing.paneGap),
          Expanded(child: IdlePane()),
        ],
      ),
    );
  }
}
