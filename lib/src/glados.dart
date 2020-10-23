import 'dart:math';

import 'package:meta/meta.dart';
import 'package:test/test.dart' as testPackage;

import 'any.dart';
import 'utils.dart';

/// Configuration for several parameters used during the exploration phase.
class Explore {
  Explore({
    this.numRuns = 100,
    this.initialSize = 10,
    this.speed = 1,
    Random random,
  })  : assert(numRuns != null),
        assert(numRuns > 0),
        assert(initialSize != null),
        assert(initialSize > 0),
        assert(speed != null),
        assert(speed >= 0),
        this.random = random ?? Random(42);

  /// The number of runs after which [Glados] stops trying to break the
  /// invariant.
  final int numRuns;

  /// The initial size.
  final double initialSize;

  /// The amount by which the size will be increased each run.
  final double speed;

  /// The [Random] used for generating all randomness.
  ///
  /// By default, a [Random] with a seed is used so that the tests are
  /// deterministic.
  final Random random;
}

/// The entrypoint for [Glados] testing.
///
/// Usually, you directly call [test] on the [Glados] instance:
///
/// ```dart
/// Glados<int>().test('blub', (input) { ... });
/// ```
///
/// # Custom arbitraries
///
/// The [arbitrary] can be used to customize how values are generated and
/// shrunk. For example, if you test code that expects email addresses, it may
/// be inefficient to use the default [Arbitrary] for [String] – if the tests
/// contain some sanity checks at the beginning, only a tiny fraction of values
/// actually passes through the code.
/// In that case, create a custom [Arbitrary]. To do that, add an extension on
/// [Any], which is a namespace for [Arbitrary]s:
///
/// ```dart
/// extension EmailArbitrary on Any {
///   Arbitrary<String> get email => arbitrary(
///     generate: (random, size) => /* code for generating emails */,
///     shrink: (input) => /* code for shrinking the given email */,
///   );
/// }
/// ```
///
/// Then, you can use that arbitrary like this:
///
/// ```dart
/// Glados(any.email).test('email test', (email) { ... });
/// ```
///
/// If you create an arbitrary for a type that doesn't have an [Arbitrary] yet
/// (or you want to swap out a built-in [Arbitrary] for some reason), you can
/// set it as the default for that type:
///
/// ```dart
/// // Use the email arbitrary for all Strings.
/// Any.defaults[String] = any.email;
/// ```
///
/// Then, you don't need to explicitly provide the [Arbitrary] to [Glados]
/// anymore. Instead, [Glados] will use it based on given type parameters:
///
/// ```dart
/// // This will now use the any.email arbitrary, because it was set as the
/// // default for String before.
/// Glados<String>().test('blub', () { ... });
/// ```
///
/// If an [Arbitrary] is the default [Arbitrary] for a type, I recommend relying
/// on implicit discovery, as the type parameters make the intention clearer.
/// If you still want to provide the [explore] parameter, you can use [null] as
/// an [arbitrary], causing [Glados] to look for the default [Arbitrary].
///
/// ```dart
/// Glados<String>(null, Explore(...)).test('blub', () { ... });
/// ```
///
/// # Exploration
///
/// To customize the exploration phase, provide an [Explore] configuration.
/// See the [Explore] doc comments for more information.
class Glados<T> {
  Glados([Arbitrary<T> arbitrary, Explore explore])
      : this.arbitrary = arbitrary ?? Any.defaultFor<T>(),
        this.explore = explore ?? Explore();

  final Arbitrary<T> arbitrary;
  final Explore explore;

  /// Executes the given body with a bunch of parameters, trying to break it.
  @isTest
  void test(String name, Tester<T> body) {
    final stats = Statistics();

    /// Explores the input space for inputs that break the invariant. This works
    /// by gradually increasing the size. Returns the first value where the
    /// invariance is broken or null if no value was found.
    T explorePhase() {
      var count = 0;
      var size = explore.initialSize;

      while (count < explore.numRuns) {
        stats.exploreCounter++;
        final input = arbitrary.generate(explore.random, size.ceil());
        if (!succeeds(body, input)) {
          return input;
        }

        count++;
        size += explore.speed;
      }
      return null;
    }

    /// Shrinks the given value repeatedly. Returns the shrunk input.
    T shrinkPhase(T initialErrorInducingInput) {
      T input = initialErrorInducingInput;
      bool shrunkSomething = true;

      while (shrunkSomething) {
        shrunkSomething = false;
        for (final shrunkInput in arbitrary.shrink(input)) {
          stats.shrinkCounter++;
          if (!succeeds(body, shrunkInput)) {
            input = shrunkInput;
            shrunkSomething = true;
            break;
          }
        }
      }
      return input;
    }

    testPackage.test(
      '$name (testing ${explore.numRuns} '
      '${explore.numRuns == 1 ? 'input' : 'inputs'})',
      () {
        final errorInducingInput = explorePhase();
        if (errorInducingInput == null) return;

        final shrunkInput = shrinkPhase(errorInducingInput);
        print('Tested ${stats.exploreCounter} '
            '${stats.exploreCounter == 1 ? 'input' : 'inputs'}, shrunk '
            '${stats.shrinkCounter} ${stats.shrinkCounter == 1 ? 'time' : 'times'}.'
            '\nFailing for input: $shrunkInput');
        body(shrunkInput); // This should fail the test again.

        throw InvarianceNotDeterministic();
      },
    );
  }
}

/// Just like [Glados], but with two parameters.
/// See [Glados] for more information about the arguments.
class Glados2<First, Second> {
  Glados2([
    Arbitrary<First> firstArbitrary,
    Arbitrary<Second> secondArbitrary,
    Explore explore,
  ])  : this.firstArbitrary = firstArbitrary ?? Any.defaultFor<First>(),
        this.secondArbitrary = secondArbitrary ?? Any.defaultFor<Second>(),
        this.explore = explore ?? Explore();

  final Arbitrary<First> firstArbitrary;
  final Arbitrary<Second> secondArbitrary;
  final Explore explore;

  void test(String name, Tester2<First, Second> body) {
    Glados(_ArbitraryN([firstArbitrary, secondArbitrary])).test(name, (input) {
      body(input[0] as First, input[1] as Second);
    });
  }
}

/// Just like [Glados], but with three parameters.
/// See [Glados] for more information about the arguments.
class Glados3<First, Second, Third> {
  Glados3([
    Arbitrary<First> firstArbitrary,
    Arbitrary<Second> secondArbitrary,
    Arbitrary<Third> thirdArbitrary,
    Explore explore,
  ])  : this.firstArbitrary = firstArbitrary ?? Any.defaultFor<First>(),
        this.secondArbitrary = secondArbitrary ?? Any.defaultFor<Second>(),
        this.thirdArbitrary = thirdArbitrary ?? Any.defaultFor<Third>(),
        this.explore = explore ?? Explore();

  final Arbitrary<First> firstArbitrary;
  final Arbitrary<Second> secondArbitrary;
  final Arbitrary<Third> thirdArbitrary;
  final Explore explore;

  void test(String name, Tester3<First, Second, Third> body) {
    Glados(_ArbitraryN([
      firstArbitrary,
      secondArbitrary,
      thirdArbitrary,
    ])).test(name, (input) {
      body(input[0] as First, input[1] as Second, input[2] as Third);
    });
  }
}

/// An Arbitrary that generates N other arbitraries.
/// This is non-type-safe by design – otherwise we'd need Arbitrary2,
/// Arbitrary3 etc.
class _ArbitraryN extends Arbitrary<List<dynamic>> {
  _ArbitraryN(this.arbitraries);

  final List<Arbitrary<dynamic>> arbitraries;

  @override
  List<dynamic> generate(Random random, int size) {
    return [
      for (var i = 0; i < arbitraries.length; i++)
        arbitraries[i].generate(random, size),
    ];
  }

  @override
  Iterable<List<dynamic>> shrink(List<dynamic> values) sync* {
    for (var i = 0; i < arbitraries.length; i++) {
      for (final shrunkValue in arbitraries[i].shrink(values[i])) {
        yield List.of(values)..[i] = shrunkValue;
      }
    }
  }
}
