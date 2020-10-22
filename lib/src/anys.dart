import 'dart:core' as core;
import 'dart:math';

import 'any.dart';

extension PredefinedAnys on Any {
  Arbitrary<core.Null> get null_ => arbitrary(
        generate: (random, size) => null,
        shrink: (input) => [],
      );
  Arbitrary<core.bool> get bool => arbitrary(
        generate: (random, size) => size == 0 ? false : random.nextBool(),
        shrink: (input) => input ? [false] : [],
      );
  Arbitrary<core.int> get int => arbitrary(
        generate: (random, size) => random.nextInt(2 * size + 1) - size,
        shrink: (input) sync* {
          if (input > 0) {
            yield input - 1;
          } else if (input < 0) {
            yield input + 1;
          }
        },
      );
  Arbitrary<core.double> get double => arbitrary(
        generate: (random, size) => random.nextDouble() * 2 * size - size,
        shrink: (input) sync* {
          if (input > 0.1) {
            yield input / 10;
          } else if (input < -0.1) {
            yield input / 10;
          }
        },
      );
  Arbitrary<core.num> get num => arbitrary(
        generate: (random, size) => random.nextBool()
            ? int.generate(random, size)
            : double.generate(random, size),
        shrink: (input) sync* {
          if (input is core.int) {
            yield* int.shrink(input);
          } else if (input is core.double) {
            yield* double.shrink(input);
          } else {
            assert(false, "Shrinking a num that's not an int or double.");
          }
        },
      );
  Arbitrary<core.BigInt> get bigInt => arbitrary(
        generate: (random, size) {
          var bigInt = core.BigInt.zero;
          for (var i = 0; i < size; i++) {
            bigInt = bigInt * core.BigInt.two;
            if (random.nextBool()) {
              bigInt += core.BigInt.one;
            }
          }
          return bigInt;
        },
        shrink: (input) sync* {
          if (input > core.BigInt.zero) {
            yield input - core.BigInt.one;
          } else if (input < core.BigInt.zero) {
            yield input + core.BigInt.one;
          }
        },
      );
  Arbitrary<core.List<T>> list<T>(Arbitrary<T> itemArbitrary) => arbitrary(
        generate: (random, size) {
          final length = random.nextInt(size);
          return <T>[
            for (var i = 0; i < length; i++)
              itemArbitrary.generate(random, size),
          ];
        },
        shrink: (value) sync* {
          for (var i = 0; i < value.length; i++) {
            yield core.List.of(value)..removeAt(i);
          }
          for (var i = 0; i < value.length; i++) {
            for (final shrunk in itemArbitrary.shrink(value[i])) {
              yield core.List.of(value)..[i] = shrunk;
            }
          }
        },
      );
  Arbitrary<core.Set<T>> set<T>(Arbitrary<T> elementArbitrary) => arbitrary(
        generate: (random, size) {
          final additions = random.nextInt(size);
          final set = <T>{};
          for (var i = 0; i < additions; i++) {
            set.add(elementArbitrary.generate(random, size));
          }
          return set;
        },
        shrink: (input) sync* {
          final list = input.toList();
          for (var i = 0; i < input.length; i++) {
            yield (core.List.of(input)..removeAt(i)).toSet();
          }
          for (var i = 0; i < input.length; i++) {
            for (final shrunk in elementArbitrary.shrink(list[i])) {
              yield (core.List.of(input)..[i] = shrunk).toSet();
            }
          }
        },
      );
  Arbitrary<core.DateTime> get dateTime => arbitrary(
      generate: (random, size) => core.DateTime.fromMicrosecondsSinceEpoch(
          int.generate(random, pow(size, 2))),
      shrink: (input) sync* {
        if (input.microsecondsSinceEpoch > 0) {
          yield core.DateTime.fromMicrosecondsSinceEpoch(
              input.microsecondsSinceEpoch - 1);
        } else if (input.microsecondsSinceEpoch < 0) {
          yield core.DateTime.fromMicrosecondsSinceEpoch(
              input.microsecondsSinceEpoch + 1);
        }
      });
  Arbitrary<core.Duration> get duration => arbitrary(
        generate: (random, size) =>
            core.Duration(microseconds: int.generate(random, pow(size, 2))),
        shrink: (input) sync* {
          if (input.inMicroseconds > 0) {
            yield core.Duration(microseconds: input.inMicroseconds - 1);
          } else if (input.inMicroseconds < 0) {
            yield core.Duration(microseconds: input.inMicroseconds + 1);
          }
        },
      );
  Arbitrary<core.MapEntry> mapEntry<K, V>(
          Arbitrary<K> keyArbitrary, Arbitrary<V> valueArbitrary) =>
      arbitrary(
        generate: (random, size) => core.MapEntry(
          keyArbitrary.generate(random, size),
          valueArbitrary.generate(random, size),
        ),
        shrink: (input) sync* {
          for (final key in keyArbitrary.shrink(input.key)) {
            yield core.MapEntry(key, input.value);
          }
          for (final value in valueArbitrary.shrink(input.value)) {
            yield core.MapEntry(input.key, value);
          }
        },
      );
  Arbitrary<core.Map> map<K, V>(
          Arbitrary<K> keyArbitrary, Arbitrary<V> valueArbitrary) =>
      arbitrary(
        generate: (random, size) {
          final keys = set(keyArbitrary).generate(random, size);
          return <K, V>{
            for (final key in keys) key: valueArbitrary.generate(random, size),
          };
        },
        shrink: (input) sync* {
          final keys = input.keys.toList();
          for (final key in keys) {
            yield core.Map.of(input)..remove(key);
          }
          for (final key in keys) {
            for (final value in valueArbitrary.shrink(input[keys])) {
              yield core.Map.of(input)..[key] = value;
            }
          }
        },
      );
  Arbitrary<core.String> _randomString(core.String chars) => arbitrary(
        generate: (random, size) {
          final length = random.nextInt(size);
          final reducedChars = chars.substring(0, max(size, chars.length));
          return [
            for (var i = 0; i < length; i++)
              reducedChars[random.nextInt(reducedChars.length)],
          ].join();
        },
        shrink: (input) sync* {
          // Omit one character from the string.
          for (var i = 0; i < input.length; i++) {
            yield '${input.substring(0, i)}${input.substring(i + 1)}';
          }
          // Make a character simpler.
          for (var i = 0; i < input.length; i++) {
            final index = chars.indexOf(input[i]);
            if (index > 0) {
              yield '${input.substring(0, i)}${chars[index - 1]}${input.substring(i + 1)}';
            }
          }
        },
      );
  Arbitrary<core.String> get lowercaseLetter =>
      _randomString('abcdefghijklmnopqrstuvwxyz');
  Arbitrary<core.String> get uppercaseLetter =>
      _randomString('ABCDEFGHIJKLMNOPQRSTUVWXYZ');
  Arbitrary<core.String> get letter =>
      _randomString('aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ');
  Arbitrary<core.String> get digit => _randomString('0123456789');
}
