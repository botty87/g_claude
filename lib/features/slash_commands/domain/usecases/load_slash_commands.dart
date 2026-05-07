import 'package:injectable/injectable.dart';

import '../../../../core/utils/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/slash_command.dart';
import '../repositories/slash_commands_repository.dart';

@injectable
class LoadSlashCommands {
  LoadSlashCommands(this._repo);
  final SlashCommandsRepository _repo;

  Future<Either<Failure, List<SlashCommand>>> call({String? workspaceCwd}) => _repo.loadAll(workspaceCwd: workspaceCwd);
}
