import 'package:injectable/injectable.dart';

import '../entities/slash_command.dart';

@injectable
class FilterSlashCommands {
  List<SlashCommand> call(List<SlashCommand> all, String filter) {
    if (filter.isEmpty || filter == '/') return all;
    final q = filter.toLowerCase();
    return all.where((c) => c.trigger.toLowerCase().startsWith(q)).toList();
  }
}
