import 'package:equatable/equatable.dart';

import '../error/failures.dart';
import 'either.dart';

abstract interface class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

abstract interface class StreamUseCase<T, Params> {
  Stream<Either<Failure, T>> call(Params params);
}

final class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object> get props => [];
}
