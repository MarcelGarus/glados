import 'dart:core' as core;

import 'package:characters/characters.dart';

import 'any.dart';
import 'generator.dart';
import 'utils.dart';

extension NullAny on Any {
  Generator<core.Null> get null_ => always(null);
}

extension BoolAny on Any {
  Generator<core.bool> get bool => choose([false, true]);
}

extension IntAnys on Any {
  /// A generator for [int]s. [min] is inclusive, [max] is exclusive.
  Generator<core.int> intInRange(core.int min, core.int max) => simple(
        generate: (random, size) =>
            random.nextIntInRange(min ?? -size, max ?? size),
        shrink: (input) sync* {
          if (input > 0 && input > min ?? 0) yield input - 1;
          if (input < 0 && input < max ?? 0) yield input + 1;
        },
      );
  Generator<core.int> get int => intInRange(null, null);
  Generator<core.int> get positiveInt => intInRange(1, null);
  Generator<core.int> get positiveIntOrZero => intInRange(0, null);
  Generator<core.int> get negativeInt => intInRange(null, 0);
  Generator<core.int> get negativeIntOrZero => intInRange(null, 1);
  Generator<core.int> get uint8 => intInRange(0, 2 << 8);
  Generator<core.int> get uint16 => intInRange(0, 2 << 16);
  Generator<core.int> get uint32 => intInRange(0, 2 << 32);
  Generator<core.int> get uint64 => intInRange(0, 2 << 64);
  Generator<core.int> get int8 => intInRange(-(2 << 7) - 1, 2 << 7);
  Generator<core.int> get int16 => intInRange(-(2 << 15) - 1, 2 << 15);
  Generator<core.int> get int32 => intInRange(-(2 << 31) - 1, 2 << 31);
  Generator<core.int> get int64 => intInRange(-(2 << 63) - 1, 2 << 63);
}

extension DoubleAnys on Any {
  /// A generator for [double]s. [min] is inclusive, [max] is exclusive.
  Generator<core.double> doubleInRange(core.double min, core.double max) =>
      simple(
        generate: (random, size) {
          final actualMin = min ?? -size.toDouble();
          final actualMax = max ?? size.toDouble();
          return random.nextDouble() * (actualMax - actualMin) + actualMin;
        },
        shrink: (input) sync* {
          // Turn 200 -> 199 -> 198 ... and 0.9 -> 0.8 -> 0.7 -> ...
          for (var i = 1; i > 0.001; i ~/= 10) {
            if (input > i && input > min ?? 0) yield input - i;
            if (input < -i && input < max ?? 0) yield input + i;
          }
          // Round to some digets.
          for (var i = 10; i < 100000; i *= 10) {
            final rounded = (input * i).round() / i;
            if (rounded != i) yield rounded;
          }
        },
      );
  Generator<core.double> get double => doubleInRange(null, null);
  Generator<core.double> get positiveDoubleOrZero => doubleInRange(0, null);
  Generator<core.double> get negativeDouble => doubleInRange(null, 0);
}

extension NumAnys on Any {
  // A generator for [double]s. [min] is inclusive, [max] is exclusive.
  // TODO(marcelgarus): Implement.
  // Generator<core.num> numInRange(core.num min, core.num max) => null;
  Generator<core.num> get num => (random, size) {
        return random.nextBool() ? int(random, size) : double(random, size);
      };
}

extension BigIntAnys on Any {
  /// A generator for [double]s. [min] is inclusive, [max] is exclusive.
  Generator<core.BigInt> bigIntInRange(core.BigInt min, core.BigInt max) =>
      simple(
        generate: (random, size) {
          final actualMin = min ?? core.BigInt.from(-size);
          final actualMax = max ?? core.BigInt.from(size);
          final bits =
              (core.BigInt.two * (actualMax - actualMin) + core.BigInt.one)
                  .bitLength;
          var bigInt = core.BigInt.zero;
          for (var i = 0; i < bits; i++) {
            bigInt = bigInt * core.BigInt.two;
            if (random.nextBool()) {
              bigInt += core.BigInt.one;
            }
          }
          return bigInt - min;
        },
        shrink: (input) sync* {
          if (input > core.BigInt.zero) {
            yield input - core.BigInt.one;
          } else if (input < core.BigInt.zero) {
            yield input + core.BigInt.one;
          }
        },
      );
  Generator<core.BigInt> get bigInt => bigIntInRange(null, null);
}

extension ListAnys on Any {
  /// A generator for [List]s with a length in the given bounds. [min] is
  /// inclusive, [max] is exclusive.
  Generator<core.List<T>> listWithLengthInRange<T>(
      core.int min, core.int max, Generator<T> itemGenerator) {
    assert(min == null || min >= 0);
    return (random, size) {
      final length = random.nextIntInRange(min, max);
      return ShrinkableList(<Shrinkable<T>>[
        for (var i = 0; i < length; i++) itemGenerator(random, size),
      ], min);
    };
  }

  Generator<core.List<T>> listWithLength<T>(
          core.int length, Generator<T> itemGenerator) =>
      listWithLengthInRange(length, length + 1, itemGenerator);
  Generator<core.List<T>> nonEmptyList<T>(Generator<T> itemGenerator) =>
      listWithLengthInRange(1, null, itemGenerator);
  Generator<core.List<T>> list<T>(Generator<T> itemGenerator) =>
      listWithLengthInRange(0, null, itemGenerator);
}

class ShrinkableList<T> implements Shrinkable<core.List<T>> {
  ShrinkableList(this.items, this.minLength);

  final core.List<Shrinkable<T>> items;
  final core.int minLength;

  @core.override
  get value => items.map((shrinkable) => shrinkable.value).toList();

  @core.override
  core.Iterable<Shrinkable<core.List<T>>> shrink() sync* {
    if (items.length > minLength) {
      for (var i = 0; i < items.length; i++) {
        yield ShrinkableList(core.List.of(items)..removeAt(i), minLength);
      }
    }
    for (var i = 0; i < items.length; i++) {
      for (final shrunk in items[i].shrink()) {
        yield ShrinkableList(core.List.of(items)..[i] = shrunk, minLength);
      }
    }
  }
}

extension SetAyns on Any {
  Generator<core.Set<T>> setWithLengthInRange<T>(
      core.int min, core.int max, Generator<T> itemGenerator) {
    assert(min == null || min >= 0);
    return (random, size) {
      final length = random.nextIntInRange(min, max);
      return ShrinkableSet(<Shrinkable<T>>{
        for (var i = 0; i < length; i++) itemGenerator(random, size),
      }, min);
    };
  }

  Generator<core.Set<T>> setWithLength<T>(
          core.int length, Generator<T> itemGenerator) =>
      setWithLengthInRange(length, length + 1, itemGenerator);
  Generator<core.Set<T>> nonEmptySet<T>(Generator<T> itemGenerator) =>
      setWithLengthInRange(1, null, itemGenerator);
  Generator<core.Set<T>> set<T>(Generator<T> itemGenerator) =>
      setWithLengthInRange(0, null, itemGenerator);
}

class ShrinkableSet<T> implements Shrinkable<core.Set<T>> {
  ShrinkableSet(this.items, this.minLength);

  final core.Set<Shrinkable<T>> items;
  final core.int minLength;

  @core.override
  get value => items.map((shrinkable) => shrinkable.value).toSet();

  @core.override
  core.Iterable<Shrinkable<core.Set<T>>> shrink() sync* {
    for (var i = 0; i < items.length; i++) {
      for (final item in items) {
        for (final shrunk in item.shrink()) {
          final newSet = core.Set.of(items)
            ..remove({item})
            ..add(shrunk);
          if (newSet.length >= minLength)
            yield ShrinkableSet(newSet, minLength);
        }
      }
    }
  }
}

extension DateTimeAnys on Any {
  Generator<core.DateTime> get dateTime =>
      int.map((value) => core.DateTime.fromMicrosecondsSinceEpoch(value));
  Generator<core.DateTime> get dateTimeBeforeEpoch => negativeInt
      .map((value) => core.DateTime.fromMicrosecondsSinceEpoch(value));
  Generator<core.DateTime> get dateTimeAfterEpoch => positiveInt
      .map((value) => core.DateTime.fromMicrosecondsSinceEpoch(value));
}

extension DurationAnys on Any {
  Generator<core.Duration> get duration =>
      int.map((value) => core.Duration(microseconds: value));
  Generator<core.Duration> get negativeDuration =>
      negativeInt.map((value) => core.Duration(microseconds: value));
  Generator<core.Duration> get positiveDuration =>
      positiveInt.map((value) => core.Duration(microseconds: value));
}

extension MapAnys on Any {
  Generator<core.MapEntry<K, V>> mapEntry<K, V>(
          Generator<K> keyArbitrary, Generator<V> valueArbitrary) =>
      combine2(keyArbitrary, valueArbitrary,
          (key, value) => core.MapEntry(key, value));
  Generator<core.Map<K, V>> map<K, V>(
          Generator<K> keyGenerator, Generator<V> valueGenerator) =>
      list(mapEntry(keyGenerator, valueGenerator))
          .map((entries) => core.Map.fromEntries(entries));
}

extension StringAnys on Any {
  Generator<core.String> stringOf(core.String chars) =>
      list(choose(chars.characters.toList()))
          .map((listOfChars) => listOfChars.join());
  Generator<core.String> get lowercaseLetter =>
      stringOf('abcdefghijklmnopqrstuvwxyz');
  Generator<core.String> get uppercaseLetter =>
      stringOf('ABCDEFGHIJKLMNOPQRSTUVWXYZ');
  Generator<core.String> get letter =>
      stringOf('aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ');
  Generator<core.String> get digit => stringOf('0123456789');
  Generator<core.String> get letterOrDigit => stringOf(
      'aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ0123456789');
}
