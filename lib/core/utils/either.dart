sealed class Either<L, R> {
  const Either();

  B fold<B>(B Function(L l) ifLeft, B Function(R r) ifRight);

  /// Unsafely returns the [Left] value.
  /// Throws an [Exception] if this is a [Right].
  L get left => fold((l) => l, (_) => throw Exception('Cannot get left value from a Right'));

  /// Unsafely returns the [Right] value.
  /// Throws an [Exception] if this is a [Left].
  R get right => fold((_) => throw Exception('Cannot get right value from a Left'), (r) => r);

  bool get isLeft => fold((_) => true, (_) => false);

  bool get isRight => fold((_) => false, (_) => true);
}

class Left<L, R> extends Either<L, R> {
  const Left(this.value);
  final L value;

  @override
  B fold<B>(B Function(L l) ifLeft, B Function(R r) ifRight) => ifLeft(value);
}

class Right<L, R> extends Either<L, R> {
  const Right(this.value);
  final R value;

  @override
  B fold<B>(B Function(L l) ifLeft, B Function(R r) ifRight) => ifRight(value);
}
