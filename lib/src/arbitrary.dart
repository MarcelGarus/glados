import 'dart:math';

/// An [Arbitrary] that makes it possible to use glados to test type [T].
abstract class Arbitrary<T> {
  /// Should generate a new value of type [T] with about the given [size].
  /// The [random] instance should be used for all pseudo-random values.
  T generate(Random random, int size);

  /// Should generate an [Iterable] of values that are similar and simpler than
  /// the given [value]. Simpler means that the transitive hull is finite: If
  /// you would call shrink on all returned values and on the values returned by
  /// them etc., this process should terminate sometime.
  Iterable<T> shrink(T value);
}

/// The arbitraries that glados uses when no explicit arbitrary is passed.
final gladosArbitraries = <Arbitrary<dynamic>>{
  intArbitrary,
  listOfIntArbitrary,
};

/// An Arbitrary that generates N other arbitraries.
/// This is non-type-safe by design – otherwise we'd need Arbitrary2,
/// Arbitrary3 etc.
class ArbitraryN extends Arbitrary<List<dynamic>> {
  ArbitraryN(this.arbitraries);

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

/// An arbitrary for integers.
class IntArbitrary implements Arbitrary<int> {
  @override
  int generate(Random random, int size) => random.nextInt(2 * size + 1) - size;

  @override
  Iterable<int> shrink(int value) sync* {
    if (value > 0) {
      for (var i = 0; i < value; i++) {
        yield i;
      }
    } else {
      for (var i = value + 1; i <= 0; i++) {
        yield i;
      }
    }
  }
}

final intArbitrary = IntArbitrary();

/// An arbitrary for lists.
class ListArbitrary<T> implements Arbitrary<List<T>> {
  ListArbitrary(this.arbitrary);

  final Arbitrary<T> arbitrary;

  @override
  List<T> generate(Random random, int size) {
    final length = random.nextInt(size);
    return <T>[
      for (var i = 0; i < length; i++) arbitrary.generate(random, size),
    ];
  }

  @override
  Iterable<List<T>> shrink(List<T> value) sync* {
    for (var i = 0; i < value.length; i++) {
      yield List.of(value)..removeAt(i);
    }
    for (var i = 0; i < value.length; i++) {
      for (final shrunk in arbitrary.shrink(value[i])) {
        yield List.of(value)..[i] = shrunk;
      }
    }
  }
}

final listOfIntArbitrary = ListArbitrary(intArbitrary);
