import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../core/di/di.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Claude Code GUI'),
        actions: [
          IconButton(
            tooltip: 'Open Talker logs',
            icon: const Icon(Icons.bug_report_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => TalkerScreen(talker: getIt<Talker>())),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.terminal, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('Claude Code GUI — setup OK', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Scaffolding pronto. Le feature arriveranno nelle prossime sessioni.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
