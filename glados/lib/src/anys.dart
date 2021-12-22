import 'dart:core' as core;
import 'dart:math' as math;

import 'package:characters/characters.dart';

import 'any.dart';
import 'generator.dart';
import 'utils.dart';

extension NullAny on Any {
  /// A generator that only generates [null].
  // ignore: prefer_void_to_null
  Generator<core.Null> get null_ => always(null);
}

extension BoolAny on Any {
  /// A generator that returns either `true` or `false`.
  ///
  /// `false` is considered less complex than `true`.
  Generator<core.bool> get bool => choose([false, true]);
}

extension IntAnys on Any {
  /// A generator that returns [int]s between [min], inclusive, to [max],
  /// exclusive.
  Generator<core.int> intInRange(core.int? min, core.int? max) {
    if (min != null && max != null) assert(min < max);
    return simple(
      generate: (random, size) {
        final actualMin = min ?? (max == null ? -size : (max - size - 1));
        final actualMax = max ?? (min == null ? size : (min + size + 1)) + 1;
        return random.nextIntInRange(actualMin, actualMax);
      },
      shrink: (input) sync* {
        if (input > 0 && input > (min ?? 0)) yield input - 1;
        if (input < 0 && input < (max ?? 0)) yield input + 1;
      },
    );
  }

  /// A generator that returns [int]s.
  Generator<core.int> get int => intInRange(null, null);

  /// A generator that returns [int]s > 0.
  Generator<core.int> get positiveInt => intInRange(1, null);

  /// A generator that returns [int]s >= 0.
  Generator<core.int> get positiveIntOrZero => intInRange(0, null);

  /// A generator that returns [int]s < 0.
  Generator<core.int> get negativeInt => intInRange(null, 0);

  /// A generator that returns [int]s <= 0.
  Generator<core.int> get negativeIntOrZero => intInRange(null, 1);

  /// A generator that returns [int]s between `0`, inclusive, to `256`, exclusive.
  Generator<core.int> get uint8 => intInRange(0, 2 << 8);

  /// A generator that returns [int]s between `0`, inclusive, to `65536`,
  /// exclusive.
  Generator<core.int> get uint16 => intInRange(0, 2 << 16);

  /// A generator that returns [int]s between `0`, inclusive, to `4294967296`,
  /// exclusive.
  Generator<core.int> get uint32 => intInRange(0, 2 << 32);

  /// A generator that returns [int]s between `-128`, inclusive, to `128`,
  /// exclusive.
  Generator<core.int> get int8 => intInRange(-(2 << 7), 2 << 7);

  /// A generator that returns [int]s between `-32768`, inclusive, to `32768`,
  /// exclusive.
  Generator<core.int> get int16 => intInRange(-(2 << 15), 2 << 15);

  /// A generator that returns [int]s between `-2147483648`, inclusive, to
  /// `2147483648`, exclusive.
  Generator<core.int> get int32 => intInRange(-(2 << 31), 2 << 31);

  /// A generator that returns [int]s between `-9223372036854775808`, inclusive,
  /// to `9223372036854775808`, exclusive.
  Generator<core.int> get int64 => intInRange(-(2 << 63), 2 << 63);
}

extension DoubleAnys on Any {
  /// A generator that returns [double]s between [min], inclusive, and [max],
  /// exclusive.
  Generator<core.double> doubleInRange(core.double? min, core.double? max) {
    return simple(
      generate: (random, size) {
        final actualMin = min ?? -size.toDouble();
        final actualMax = max ?? size.toDouble();
        return random.nextDouble() * (actualMax - actualMin) + actualMin;
      },
      shrink: (input) sync* {
        // Turn 200 -> 199 -> 198 ... and 0.9 -> 0.8 -> 0.7 -> ...
        for (var i = 1; i > 0.001; i ~/= 10) {
          if (input > i && input > (min ?? 0)) yield input - i;
          if (input < -i && input < (max ?? 0)) yield input + i;
        }
        // Round to some digets.
        for (var i = 10; i < 100000; i *= 10) {
          final rounded = (input * i).round() / i;
          if (rounded != i) yield rounded;
        }
      },
    );
  }

  /// A generator that returns [double]s.
  Generator<core.double> get double => doubleInRange(null, null);

  /// A generator that returns [double]s > 0.
  Generator<core.double> get positiveDouble {
    return doubleInRange(null, 0).map((it) => it * -1);
  }

  /// A generator that returns [double]s >= 0.
  Generator<core.double> get positiveDoubleOrZero => doubleInRange(0, null);

  /// A generator that returns [double]s < 0.
  Generator<core.double> get negativeDouble => doubleInRange(null, 0);

  /// A generator that returns [double]s <= 0.
  Generator<core.double> get negativeDoubleOrZero {
    return doubleInRange(0, null).map((it) => it * -1);
  }
}

extension NumAnys on Any {
  // A generator for [num]s. [min] is inclusive, [max] is exclusive.
  // TODO(marcelgarus): Implement.
  // Generator<core.num> numInRange(core.num min, core.num max) => null;

  /// A generator that returns [num]s.
  Generator<core.num> get num {
    return (random, size) {
      return random.nextBool() ? int(random, size) : double(random, size);
    };
  }
}

extension BigIntAnys on Any {
  /// A generator that returns [BigInt]s between [min], inclusive, to [max],
  /// exclusive.
  Generator<core.BigInt> bigIntInRange(core.BigInt? min, core.BigInt? max) {
    return simple(
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
        return bigInt - actualMin;
      },
      shrink: (input) sync* {
        if (input > core.BigInt.zero) {
          yield input - core.BigInt.one;
        } else if (input < core.BigInt.zero) {
          yield input + core.BigInt.one;
        }
      },
    );
  }

  /// A generator that returns [BigInt]s.
  Generator<core.BigInt> get bigInt => bigIntInRange(null, null);
}

extension ListAnys on Any {
  /// A generator that returns [List]s with a `length` between [min], inclusive,
  /// and [max], exclusive.
  Generator<core.List<T>> listWithLengthInRange<T>(
    core.int? min,
    core.int? max,
    Generator<T> item,
  ) {
    final actualMin = min ?? 0;
    assert(actualMin >= 0);
    return (random, size) {
      final length = random.nextIntInRange(
        actualMin,
        math.max(max ?? size, actualMin + 1),
      );
      return ShrinkableList(
        <Shrinkable<T>>[for (var i = 0; i < length; i++) item(random, size)],
        actualMin,
      );
    };
  }

  /// A generator that returns [List]s with the given `length`.
  Generator<core.List<T>> listWithLength<T>(
    core.int length,
    Generator<T> item,
  ) {
    return listWithLengthInRange(length, length + 1, item);
  }

  /// A generator that returns [List]s that are not empty.
  Generator<core.List<T>> nonEmptyList<T>(Generator<T> item) {
    return listWithLengthInRange(1, null, item);
  }

  /// A generator that returns [List]s.
  Generator<core.List<T>> list<T>(Generator<T> item) {
    return listWithLengthInRange(0, null, item);
  }
}

class ShrinkableList<T> implements Shrinkable<core.List<T>> {
  ShrinkableList(this.items, core.int? minLength) : minLength = minLength ?? 0;

  final core.List<Shrinkable<T>> items;
  final core.int minLength;

  @core.override
  core.List<T> get value =>
      items.map((shrinkable) => shrinkable.value).toList();

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

  @core.override
  core.String toString() => 'ShrinkableList<$T>($items, minLength: $minLength)';
}

extension SetAyns on Any {
  /// A generator that returns [Set]s with a `length` that is between [min] and
  /// [max].
  @core.Deprecated('This generator is deprecated and will be removed in 2.0.0.'
      "It's not possible to reliably generate sets with a given length. For "
      'example, any.setWithLengthInRange(3, 10, any.bool) is impossible.')
  Generator<core.Set<T>> setWithLengthInRange<T>(
    core.int? min,
    core.int? max,
    Generator<T> item,
  ) {
    final actualMin = min ?? 0;
    assert(actualMin >= 0);
    return (random, size) {
      final length = random.nextIntInRange(
        actualMin,
        math.max(max ?? size, actualMin + 1),
      );
      // TODO(marcelgarus): Make sure the same item is not added twice.
      return ShrinkableSet(
        <Shrinkable<T>>{for (var i = 0; i < length; i++) item(random, size)},
        actualMin,
      );
    };
  }

  /// A generator that returns [Set]s with the given `length`.
  @core.Deprecated('This generator is deprecated and will be removed in 2.0.0.'
      "It's not possible to reliably generate sets with a given length. For "
      'example, any.setWithLength(3, any.bool) is impossible.')
  Generator<core.Set<T>> setWithLength<T>(core.int length, Generator<T> item) {
    return setWithLengthInRange(length, length + 1, item);
  }

  /// A generator that returns [Set]s that are not empty.
  Generator<core.Set<T>> nonEmptySet<T>(Generator<T> item) {
    // This works, because we know that the `item` will generate at
    // least one distinct item.
    // ignore: deprecated_member_use_from_same_package
    return setWithLengthInRange(1, null, item);
  }

  /// A generator that returns [Set]s.
  Generator<core.Set<T>> set<T>(Generator<T> item) {
    // This works, because we don't care about how many _distinct_ items the
    // `item` generates.
    // ignore: deprecated_member_use_from_same_package
    return setWithLengthInRange(0, null, item);
  }
}

class ShrinkableSet<T> implements Shrinkable<core.Set<T>> {
  ShrinkableSet(this.items, core.int? minLength) : minLength = minLength ?? 0;

  final core.Set<Shrinkable<T>> items;
  final core.int minLength;

  @core.override
  core.Set<T> get value => items.map((shrinkable) => shrinkable.value).toSet();

  @core.override
  core.Iterable<Shrinkable<core.Set<T>>> shrink() sync* {
    for (var i = 0; i < items.length; i++) {
      for (final item in items) {
        for (final shrunk in item.shrink()) {
          final newSet = core.Set.of(items)
            ..remove({item})
            ..add(shrunk);
          if (newSet.length >= minLength) {
            yield ShrinkableSet(newSet, minLength);
          }
        }
      }
    }
  }

  @core.override
  core.String toString() => 'ShrinkableSet<$T>($items, minLength: $minLength)';
}

extension DateTimeAnys on Any {
  /// A generator that returns [DateTime]s.
  Generator<core.DateTime> get dateTime {
    return int.map((int) => core.DateTime.fromMicrosecondsSinceEpoch(int));
  }

  /// A generator that returns [DateTime]s before the UNIX epoch.
  Generator<core.DateTime> get dateTimeBeforeEpoch {
    return negativeInt
        .map((int) => core.DateTime.fromMicrosecondsSinceEpoch(int));
  }

  /// A generator that returns [DateTime]s after the UNIX epoch.
  Generator<core.DateTime> get dateTimeAfterEpoch {
    return positiveInt
        .map((int) => core.DateTime.fromMicrosecondsSinceEpoch(int));
  }
}

extension DurationAnys on Any {
  /// A generator that returns [Duration]s.
  Generator<core.Duration> get duration {
    return int.map((int) => core.Duration(microseconds: int));
  }

  /// A generator that returns negative [Duration]s.
  Generator<core.Duration> get negativeDuration {
    return negativeInt.map((int) => core.Duration(microseconds: int));
  }

  /// A generator that returns positive [Duration]s.
  Generator<core.Duration> get positiveDuration {
    return positiveInt.map((int) => core.Duration(microseconds: int));
  }
}

extension MapAnys on Any {
  /// A generator that returns [MapEntry]s.
  Generator<core.MapEntry<K, V>> mapEntry<K, V>(
    Generator<K> key,
    Generator<V> value,
  ) {
    return combine2(key, value, (K key, V value) => core.MapEntry(key, value));
  }

  /// A generator that returns [Map]s.
  Generator<core.Map<K, V>> map<K, V>(Generator<K> key, Generator<V> value) {
    return list(mapEntry(key, value))
        .map((entries) => core.Map.fromEntries(entries));
  }
}

extension StringAnys on Any {
  static final _lowercaseLetters = 'abcdefghijklmnopqrstuvwxyz';
  static final _uppercaseLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static final _digits = '0123456789';
  static final _letters = '$_lowercaseLetters$_uppercaseLetters';
  static final _lettersOrDigits = '$_letters$_digits';

  Generator<core.String> stringOf(core.String chars) =>
      list(choose(chars.characters.toList()))
          .map((listOfChars) => listOfChars.join());
  Generator<core.String> nonEmptyStringOf(core.String chars) =>
      nonEmptyList(choose(chars.characters.toList()))
          .map((listOfChars) => listOfChars.join());
  Generator<core.String> get lowercaseLetters => stringOf(_lowercaseLetters);
  Generator<core.String> get uppercaseLetters => stringOf(_uppercaseLetters);
  Generator<core.String> get letters => stringOf(_letters);
  Generator<core.String> get digits => stringOf(_digits);
  Generator<core.String> get letterOrDigits => stringOf(_lettersOrDigits);
  Generator<core.String> get nonEmptyLowercaseLetters =>
      nonEmptyStringOf(_lowercaseLetters);
  Generator<core.String> get nonEmptyUppercaseLetters =>
      nonEmptyStringOf(_uppercaseLetters);
  Generator<core.String> get nonEmptyLetters => nonEmptyStringOf(_letters);
  Generator<core.String> get nonEmptyDigits => nonEmptyStringOf(_digits);
  Generator<core.String> get nonEmptyLetterOrDigits =>
      nonEmptyStringOf(_lettersOrDigits);
}
