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
  nullArbitrary,
  boolArbitrary,
  intArbitrary,
  doubleArbitrary,
  numArbitrary,
  bigIntArbitrary,
  dateTimeArbitrary,
  durationArbitrary,
  setOfIntArbitrary,
  setOfDoubleArbitrary,
  setOfNumArbitrary,
  setOfBigIntArbitrary,
  listOfBoolArbitrary,
  listOfIntArbitrary,
  listOfDoubleArbitrary,
  listOfNumArbitrary,
  listOfBigIntArbitrary,
  mapEntryFromIntToBoolArbitrary,
  mapEntryFromIntToIntArbitrary,
  mapEntryFromIntToDoubleArbitrary,
  mapEntryFromIntToNumArbitrary,
  mapEntryFromIntToBigIntArbitrary,
  mapEntryFromBigIntToBoolArbitrary,
  mapEntryFromBigIntToIntArbitrary,
  mapEntryFromBigIntToDoubleArbitrary,
  mapEntryFromBigIntToNumArbitrary,
  mapEntryFromBigIntToBigIntArbitrary,
  mapFromIntToBoolArbitrary,
  mapFromIntToIntArbitrary,
  mapFromIntToDoubleArbitrary,
  mapFromIntToNumArbitrary,
  mapFromIntToBigIntArbitrary,
  mapFromBigIntToBoolArbitrary,
  mapFromBigIntToIntArbitrary,
  mapFromBigIntToDoubleArbitrary,
  mapFromBigIntToNumArbitrary,
  mapFromBigIntToBigIntArbitrary,
};

final nullArbitrary = NullArbitrary();
final boolArbitrary = BoolArbitrary();
final intArbitrary = IntArbitrary();
final doubleArbitrary = DoubleArbitrary();
final numArbitrary = NumArbitrary();
final bigIntArbitrary = BigIntArbitrary();
final dateTimeArbitrary = DateTimeArbitrary();
final durationArbitrary = DurationArbitrary();

final setOfIntArbitrary = SetArbitrary(intArbitrary);
final setOfDoubleArbitrary = SetArbitrary(doubleArbitrary);
final setOfNumArbitrary = SetArbitrary(numArbitrary);
final setOfBigIntArbitrary = SetArbitrary(bigIntArbitrary);

final listOfBoolArbitrary = ListArbitrary(boolArbitrary);
final listOfIntArbitrary = ListArbitrary(intArbitrary);
final listOfDoubleArbitrary = ListArbitrary(doubleArbitrary);
final listOfNumArbitrary = ListArbitrary(numArbitrary);
final listOfBigIntArbitrary = ListArbitrary(bigIntArbitrary);

final mapEntryFromIntToBoolArbitrary =
    MapEntryArbitrary(intArbitrary, boolArbitrary);
final mapEntryFromIntToIntArbitrary =
    MapEntryArbitrary(intArbitrary, intArbitrary);
final mapEntryFromIntToDoubleArbitrary =
    MapEntryArbitrary(intArbitrary, doubleArbitrary);
final mapEntryFromIntToNumArbitrary =
    MapEntryArbitrary(intArbitrary, numArbitrary);
final mapEntryFromIntToBigIntArbitrary =
    MapEntryArbitrary(intArbitrary, bigIntArbitrary);
final mapEntryFromBigIntToBoolArbitrary =
    MapEntryArbitrary(bigIntArbitrary, boolArbitrary);
final mapEntryFromBigIntToIntArbitrary =
    MapEntryArbitrary(bigIntArbitrary, intArbitrary);
final mapEntryFromBigIntToDoubleArbitrary =
    MapEntryArbitrary(bigIntArbitrary, doubleArbitrary);
final mapEntryFromBigIntToNumArbitrary =
    MapEntryArbitrary(bigIntArbitrary, numArbitrary);
final mapEntryFromBigIntToBigIntArbitrary =
    MapEntryArbitrary(bigIntArbitrary, bigIntArbitrary);

final mapFromIntToBoolArbitrary = MapArbitrary(intArbitrary, boolArbitrary);
final mapFromIntToIntArbitrary = MapArbitrary(intArbitrary, intArbitrary);
final mapFromIntToDoubleArbitrary = MapArbitrary(intArbitrary, doubleArbitrary);
final mapFromIntToNumArbitrary = MapArbitrary(intArbitrary, numArbitrary);
final mapFromIntToBigIntArbitrary = MapArbitrary(intArbitrary, bigIntArbitrary);
final mapFromBigIntToBoolArbitrary =
    MapArbitrary(bigIntArbitrary, boolArbitrary);
final mapFromBigIntToIntArbitrary = MapArbitrary(bigIntArbitrary, intArbitrary);
final mapFromBigIntToDoubleArbitrary =
    MapArbitrary(bigIntArbitrary, doubleArbitrary);
final mapFromBigIntToNumArbitrary = MapArbitrary(bigIntArbitrary, numArbitrary);
final mapFromBigIntToBigIntArbitrary =
    MapArbitrary(bigIntArbitrary, bigIntArbitrary);

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

/// An arbitrary for nulls.
class NullArbitrary implements Arbitrary<Null> {
  @override
  Null generate(Random random, int size) => null;

  @override
  Iterable<Null> shrink(Null value) sync* {}
}

/// An arbitrary for bools.
class BoolArbitrary implements Arbitrary<bool> {
  @override
  bool generate(Random random, int size) =>
      size == 0 ? false : random.nextBool();

  @override
  Iterable<bool> shrink(bool value) sync* {
    if (value == true) {
      yield false;
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
      yield value - 1;
    } else if (value < 0) {
      yield value + 1;
    }
  }
}

/// An arbitrary for doubles.
class DoubleArbitrary implements Arbitrary<double> {
  @override
  double generate(Random random, int size) =>
      random.nextDouble() * double.maxFinite;

  @override
  Iterable<double> shrink(double value) sync* {
    if (value > 0.1) {
      yield value / 10;
    } else if (value < -0.1) {
      yield value / 10;
    }
  }
}

/// An arbitrary for nums.
class NumArbitrary implements Arbitrary<num> {
  @override
  num generate(Random random, int size) => random.nextBool()
      ? intArbitrary.generate(random, size)
      : doubleArbitrary.generate(random, size);

  @override
  Iterable<num> shrink(num value) sync* {
    if (value is int) {
      yield* intArbitrary.shrink(value);
    } else if (value is double) {
      yield* doubleArbitrary.shrink(value);
    } else {
      assert(false, "Shrinking a num that's not an int or double.");
    }
  }
}

/// An arbitrary for BigInt.
class BigIntArbitrary implements Arbitrary<BigInt> {
  @override
  BigInt generate(Random random, int size) {
    var bigInt = BigInt.zero;
    for (var i = 0; i < size; i++) {
      bigInt = bigInt * BigInt.two;
      if (random.nextBool()) {
        bigInt += BigInt.one;
      }
    }
    return bigInt;
  }

  @override
  Iterable<BigInt> shrink(BigInt value) sync* {
    if (value > BigInt.zero) {
      yield value - BigInt.one;
    } else if (value < BigInt.zero) {
      yield value + BigInt.one;
    }
  }
}

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

/// An arbitrary for sets.
class SetArbitrary<T> implements Arbitrary<Set<T>> {
  SetArbitrary(this.arbitrary);

  final Arbitrary<T> arbitrary;

  @override
  Set<T> generate(Random random, int size) {
    final additions = random.nextInt(size);
    final set = <T>{};
    for (var i = 0; i < additions; i++) {
      set.add(arbitrary.generate(random, size));
    }
    return set;
  }

  @override
  Iterable<Set<T>> shrink(Set<T> value) sync* {
    final list = value.toList();
    for (var i = 0; i < value.length; i++) {
      yield (List.of(value)..removeAt(i)).toSet();
    }
    for (var i = 0; i < value.length; i++) {
      for (final shrunk in arbitrary.shrink(list[i])) {
        yield (List.of(value)..[i] = shrunk).toSet();
      }
    }
  }
}

/// An arbitrary for DateTimes.
class DateTimeArbitrary implements Arbitrary<DateTime> {
  @override
  DateTime generate(Random random, int size) =>
      DateTime.fromMicrosecondsSinceEpoch(
          intArbitrary.generate(random, pow(size, 2)));

  @override
  Iterable<DateTime> shrink(DateTime value) sync* {
    if (value.microsecondsSinceEpoch > 0) {
      yield DateTime.fromMicrosecondsSinceEpoch(
          value.microsecondsSinceEpoch - 1);
    } else if (value.microsecondsSinceEpoch < 0) {
      yield DateTime.fromMicrosecondsSinceEpoch(
          value.microsecondsSinceEpoch + 1);
    }
  }
}

/// An arbitrary for Duration.
class DurationArbitrary implements Arbitrary<Duration> {
  @override
  Duration generate(Random random, int size) =>
      Duration(microseconds: intArbitrary.generate(random, pow(size, 2)));

  @override
  Iterable<Duration> shrink(Duration value) sync* {
    if (value.inMicroseconds > 0) {
      yield Duration(microseconds: value.inMicroseconds - 1);
    }
  }
}

/// An arbitrary for MapEntry.
class MapEntryArbitrary<K, V> implements Arbitrary<MapEntry<K, V>> {
  MapEntryArbitrary(this.keyArbitrary, this.valueArbitrary);

  final Arbitrary<K> keyArbitrary;
  final Arbitrary<V> valueArbitrary;

  @override
  MapEntry<K, V> generate(Random random, int size) => MapEntry(
      keyArbitrary.generate(random, size),
      valueArbitrary.generate(random, size));

  @override
  Iterable<MapEntry<K, V>> shrink(MapEntry<K, V> entry) sync* {
    for (final key in keyArbitrary.shrink(entry.key)) {
      yield MapEntry(key, entry.value);
    }
    for (final value in valueArbitrary.shrink(entry.value)) {
      yield MapEntry(entry.key, value);
    }
  }
}

/// An arbitrary for Map.
class MapArbitrary<K, V> implements Arbitrary<Map<K, V>> {
  MapArbitrary(this.keyArbitrary, this.valueArbitrary);

  final Arbitrary<K> keyArbitrary;
  final Arbitrary<V> valueArbitrary;

  @override
  Map<K, V> generate(Random random, int size) {
    final keys = SetArbitrary(keyArbitrary).generate(random, size);
    return <K, V>{
      for (final key in keys) key: valueArbitrary.generate(random, size),
    };
  }

  @override
  Iterable<Map<K, V>> shrink(Map<K, V> map) sync* {
    final keys = map.keys.toList();
    for (final key in keys) {
      yield Map.of(map)..remove(key);
    }
    for (final key in keys) {
      for (final value in valueArbitrary.shrink(map[keys])) {
        yield Map.of(map)..[key] = value;
      }
    }
  }
}

/*
TODO:
String
Uri
UriData
*/
