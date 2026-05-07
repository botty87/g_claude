// Contracts for the project-local Either<L, R> in lib/core/utils/either.dart.
//
// The codebase uses this Either as the standard return shape for repositories
// and use cases (Future<Either<Failure, T>>). Every higher layer assumes:
// - fold dispatches to the matching branch,
// - the unsafe getters throw on the wrong branch (callers that use them are
//   guarded by isLeft/isRight),
// - isLeft/isRight reflect the constructor.
//
// If any of these break, every repository test downstream is broken too.

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/core/utils/either.dart';

void main() {
  group('Either.fold', () {
    test('Left dispatches to ifLeft and never invokes ifRight', () {
      final either = Left<String, int>('boom');

      final ifRightCalls = <int>[];
      final out = either.fold((l) => 'left:$l', (r) {
        ifRightCalls.add(r);
        return 'right:$r';
      });

      expect(out, 'left:boom');
      expect(ifRightCalls, isEmpty, reason: 'fold must short-circuit on the matching branch.');
    });

    test('Right dispatches to ifRight and never invokes ifLeft', () {
      final either = Right<String, int>(42);

      final ifLeftCalls = <String>[];
      final out = either.fold((l) {
        ifLeftCalls.add(l);
        return 'left:$l';
      }, (r) => 'right:$r');

      expect(out, 'right:42');
      expect(ifLeftCalls, isEmpty);
    });
  });

  group('Either getters left / right', () {
    test('Left.left returns the value, Left.right throws Exception', () {
      final either = Left<String, int>('boom');
      expect(either.left, 'boom');
      // Tightening: callers rely on this being an Exception (not Error). If
      // someone "improves" it to throw a typed Failure or returns null, every
      // call site that catches Exception would silently break.
      expect(() => either.right, throwsA(isA<Exception>()));
    });

    test('Right.right returns the value, Right.left throws Exception', () {
      final either = Right<String, int>(42);
      expect(either.right, 42);
      expect(() => either.left, throwsA(isA<Exception>()));
    });
  });

  group('Either flags isLeft / isRight', () {
    test('Left reports isLeft=true and isRight=false', () {
      final either = Left<String, int>('boom');
      expect(either.isLeft, isTrue);
      expect(either.isRight, isFalse);
    });

    test('Right reports isRight=true and isLeft=false', () {
      final either = Right<String, int>(42);
      expect(either.isRight, isTrue);
      expect(either.isLeft, isFalse);
    });
  });

  group('Either with nullable type parameters', () {
    test('Right(null) is still a Right and yields null on the right branch', () {
      final either = Right<String, int?>(null);
      expect(either.isRight, isTrue);
      expect(either.right, isNull);
      expect(either.fold((l) => 'L', (r) => r == null ? 'NULL' : 'V'), 'NULL');
    });

    test('Left(null) is still a Left and yields null on the left branch', () {
      final either = Left<String?, int>(null);
      expect(either.isLeft, isTrue);
      expect(either.left, isNull);
    });
  });
}
