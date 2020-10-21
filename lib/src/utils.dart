/// A function with one input that's intended to be called in a test context.
typedef Tester<T> = void Function(T input);

/// A function with two inputs that's intended to be called in a test context.
typedef Tester2<A, B> = void Function(A firstInput, B secondInput);

/// A function with three inputs that's intended to be called in a test context.
typedef Tester3<A, B, C> = void Function(
    A firstInput, B secondInput, C thirdInput);

/// A simple class storing statistics.
class Statistics {
  var exploreCounter = 0;
  var shrinkCounter = 0;
}

/// Runs the [tester] with the [input]. Catches thrown errors and instead
/// returns a [bool] indicating whether the tester ran through successfully.
bool succeeds<T>(Tester<T> tester, T input) {
  try {
    tester(input);
    return true;
  } catch (e) {
    return false;
  }
}

/// Indicates that no arbitrary was found for a type.
class NoArbitraryFound implements Exception {
  NoArbitraryFound(this.type);

  final Type type;

  String toString() => 'You tried to call glados with $type as type arguments. '
      'But no arbitrary was found for this type. You should probably create '
      'a new Arbitrary<$type> and either register that using '
      'gladosArbitraries.add(instanceOfTheArbitrary) or use it directly by '
      'passing it into the named arbitrary parameter of the glados function.';
}

/// For the same input, an invariance sometimes throws an exceptions and
/// sometimes doesn't. Invariants should be deterministic though.
class InvarianceNotDeterministic implements Exception {
  String toString() => 'The invariance was called twice with the same value. '
      'The first time, an exception was thrown, the second time, it executed '
      'normally. The invariance has to be deterministic.';
}
