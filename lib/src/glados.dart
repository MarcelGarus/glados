import 'dart:math';

import 'package:test/test.dart';

import 'arbitrary.dart';
import 'utils.dart';

/// Executes a GLaDOS test with one input.
void glados<T>(
  String name,
  Tester<T> tester, {
  Random random,
  Arbitrary<T> arbitrary,
  int initialExploreSize = 10,
  int exploreCount = 100,
  double exploreSpeed = 1,
}) {
  assert(name != null);
  assert(tester != null);
  random ??= Random(42);
  arbitrary ??= gladosArbitraries.firstWhere(
    (arbitrary) => arbitrary is Arbitrary<T>,
    orElse: () => throw NoArbitraryFound(T),
  );
  assert(initialExploreSize != null);
  assert(initialExploreSize > 0);
  assert(exploreCount != null);
  assert(exploreCount > 0);
  assert(exploreSpeed != null);
  assert(exploreSpeed >= 0);

  final stats = Statistics();

  /// Explores the input space for inputs that break the invariant. This works
  /// by gradually increasing the size. Returns the first value where the
  /// invariance is broken or null if no value was found.
  T explore() {
    var tries = 0;
    var size = initialExploreSize.toDouble();

    while (tries < exploreCount) {
      stats.exploreCounter++;
      final input = arbitrary.generate(random, size.ceil());
      if (!succeeds(tester, input)) {
        return input;
      }

      tries++;
      size += exploreSpeed;
    }
    return null;
  }

  /// Shrinks the given value repeatedly. Returns the shrunk input.
  T shrink(T initialErrorInducingInput) {
    T input = initialErrorInducingInput;
    bool shrunkSomething = true;

    while (shrunkSomething) {
      shrunkSomething = false;
      for (final shrunkInput in arbitrary.shrink(input)) {
        stats.shrinkCounter++;
        if (!succeeds(tester, shrunkInput)) {
          input = shrunkInput;
          shrunkSomething = true;
          break;
        }
      }
    }
    return input;
  }

  test(
    '$name (🍰 testing $exploreCount ${exploreCount == 1 ? 'input' : 'inputs'})',
    () {
      final errorInducingInput = explore();
      if (errorInducingInput == null) return;

      final shrunkInput = shrink(errorInducingInput);
      print('Tested ${stats.exploreCounter} '
          '${stats.exploreCounter == 1 ? 'input' : 'inputs'}, shrunk '
          '${stats.shrinkCounter} ${stats.shrinkCounter == 1 ? 'time' : 'times'}.'
          '\nFailing for input: $shrunkInput');
      tester(shrunkInput); // This should fail the test again.

      throw InvarianceNotDeterministic();
    },
  );
}

/// Executes a GLaDOS test with two inputs.
void glados2<A, B>(
  String name,
  Tester2<A, B> tester, {
  Random random,
  Arbitrary<A> arbitraryA,
  Arbitrary<B> arbitraryB,
  int initialExploreSize = 10,
  int exploreCount = 100,
  double exploreSpeed = 1,
}) {
  glados<List<dynamic>>(
    name,
    (values) => tester(values[0], values[1]),
    random: random,
    arbitrary: ArbitraryN([arbitraryA, arbitraryB]),
    initialExploreSize: initialExploreSize,
    exploreCount: exploreCount,
    exploreSpeed: exploreSpeed,
  );
}

/// Executes a GLaDOS test with three inputs.
void glados3<A, B, C>(
  String name,
  Tester3<A, B, C> tester, {
  Random random,
  Arbitrary<A> arbitraryA,
  Arbitrary<B> arbitraryB,
  Arbitrary<C> arbitraryC,
  int initialExploreSize = 10,
  int exploreCount = 100,
  double exploreSpeed = 1,
}) {
  glados<List<dynamic>>(
    name,
    (values) => tester(values[0], values[1], values[2]),
    random: random,
    arbitrary: ArbitraryN([arbitraryA, arbitraryB, arbitraryC]),
    initialExploreSize: initialExploreSize,
    exploreCount: exploreCount,
    exploreSpeed: exploreSpeed,
  );
}
