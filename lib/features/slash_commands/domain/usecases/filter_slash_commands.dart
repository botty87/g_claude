import 'package:injectable/injectable.dart';

import '../entities/slash_command.dart';

@injectable
class FilterSlashCommands {
  List<SlashCommand> call(List<SlashCommand> all, String filter) {
    final q = filter.replaceFirst(RegExp(r'^/'), '').trim().toLowerCase();
    if (q.isEmpty) return all;

    final postColonPrefix = <SlashCommand>[];
    final wholePrefix = <SlashCommand>[];
    final nameContains = <SlashCommand>[];
    final descContains = <SlashCommand>[];

    for (final c in all) {
      final name = c.trigger.replaceFirst('/', '').toLowerCase();
      final desc = c.description.toLowerCase();
      final colon = name.indexOf(':');
      final postColon = colon >= 0 ? name.substring(colon + 1) : '';

      if (postColon.isNotEmpty && postColon.startsWith(q)) {
        postColonPrefix.add(c);
      } else if (name.startsWith(q)) {
        wholePrefix.add(c);
      } else if (name.contains(q)) {
        nameContains.add(c);
      } else if (desc.contains(q)) {
        descContains.add(c);
      }
    }

    return [...postColonPrefix, ...wholePrefix, ...nameContains, ...descContains];
  }
}
