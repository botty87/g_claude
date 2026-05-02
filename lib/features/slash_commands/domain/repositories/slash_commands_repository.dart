import '../../../../core/utils/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/slash_command.dart';

abstract interface class SlashCommandsRepository {
  Future<Either<Failure, List<SlashCommand>>> loadAll({required String? workspaceCwd});
}
