import 'dart:math';

import 'package:meta/meta.dart';

import 'anys.dart';
import 'errors.dart';
import 'generator.dart';

/// The [any] singleton, providing a namespace for [Generator]s.
///
/// New [Generator]s should be added as extension methods, so you can use them
/// with a syntax like this: `any.int`
final any = Any();

/// A namespace for all [Generator]s.
///
/// You can register an [Generator] as the default [Generator] for a given
/// type. Then, you don't need to pass the concrete [Generator] to [Glados]
/// anymore – [Glados] can infer the right [Generator] only given the generic
/// types.
class Any {
  /// A map from [Type]s to their default [Generator].
  static final _defaults = <_TypeWrapper<dynamic>, Generator<dynamic>>{
    ..._defaultGenerators
  };
  static void setDefault<T>(Generator<T> generator) =>
      _defaults[_TypeWrapper<T>()] = generator;
  static Generator<T> defaultFor<T>() =>
      _defaults[_TypeWrapper<T>()] ?? (throw InternalNoGeneratorFound());
  static Generator<T> defaultForWithBeautifulError<T>(
      int numGladosArgs, int typeIndex) {
    try {
      return defaultFor<T>();
    } on InternalNoGeneratorFound {
      throw NoGeneratorFound(numGladosArgs, typeIndex, T);
    }
  }
}

class _TypeWrapper<T> {
  @override
  bool operator ==(Object other) => other.runtimeType == runtimeType;
  @override
  int get hashCode => runtimeType.hashCode;
}

/// Useful utilities for creating [Geneator]s that behave just like you want to.
extension AnyUtils on Any {
  /// Creates a new, simple [Generator] that produces values and knows how to
  /// simplify them.
  Generator<T> simple<T>({
    @required T Function(Random random, int size) generate,
    @required Iterable<T> Function(T input) shrink,
  }) {
    // Map both given functions to the semantics of generators: Instead of
    // having two top-level functions, we have one function that generates
    // `ShrinkableValue`s that each know how the shrink themselves.

    Shrinkable<T> Function(T input) generateShrinkable;
    generateShrinkable = (T value) {
      return Shrinkable(value, () sync* {
        for (final value in shrink(value)) {
          yield generateShrinkable(value);
        }
      });
    };
    return (random, size) {
      return generateShrinkable(generate(random, size));
    };
  }

  /// Returns always the same value.
  Generator<T> always<T>(T value) =>
      simple(generate: (_, __) => value, shrink: (_) => []);

  /// Chooses between the given values. Values further at the front of the
  /// list are considered less complex.
  Generator<T> choose<T>(List<T> values) {
    assert(values.toSet().length == values.length,
        'The list of values given to any.choice contains duplicate items.');
    return simple(
      generate: (random, size) => values[random.nextInt(
        size.clamp(0, values.length - 1),
      )],
      shrink: (option) sync* {
        final index = values.indexOf(option);
        if (index > 0) yield values[index - 1];
      },
    );
  }

  /// Uses either the first or the second generator to generate a value.
  Generator<T> either<T>(Generator<T> first, Generator<T> second) {
    return (random, size) {
      final chosenGenerator = choose([first, second])(random, size).value;
      return chosenGenerator(random, size);
    };
  }

  // Generator<T> chooseWithFrequency<T>(Map<T, double> options) {
  //   return arbitrary(
  //     generate: (random, size) =>
  //   );
  // }
}

extension CombinableAny on Any {
  /// Combines n values. Is not typesafe, so it's private.
  Generator<T> _combineN<T>(
    List<Generator<dynamic>> generators,
    T Function(List<dynamic> values) combiner,
  ) {
    return (random, size) {
      return ShrinkableCombination(<Shrinkable<T>>[
        for (final generator in generators) generator(random, size),
      ], combiner);
    };
  }

  /// Combines 2 values.
  Generator<T> combine2<A, B, T>(
    Generator<A> aGenerator,
    Generator<B> bGenerator,
    T Function(A a, B b) combiner,
  ) {
    return _combineN(
      [aGenerator, bGenerator],
      (values) => combiner(values[0] as A, values[1] as B),
    );
  }

  /// Combines 3 values.
  Generator<T> combine3<A, B, C, T>(
    Generator<A> aGenerator,
    Generator<B> bGenerator,
    Generator<C> cGenerator,
    T Function(A a, B b, C c) combiner,
  ) {
    return _combineN(
      [aGenerator, bGenerator, cGenerator],
      (values) => combiner(values[0] as A, values[1] as B, values[2] as C),
    );
  }

  /// Combines 4 values.
  Generator<T> combine4<A, B, C, D, T>(
    Generator<A> aGenerator,
    Generator<B> bGenerator,
    Generator<C> cGenerator,
    Generator<D> dGenerator,
    T Function(A a, B b, C c, D d) combiner,
  ) {
    return _combineN(
      [aGenerator, bGenerator, cGenerator, dGenerator],
      (values) => combiner(
        values[0] as A,
        values[1] as B,
        values[2] as C,
        values[3] as D,
      ),
    );
  }

  /// Combines 5 values.
  Generator<T> combine5<T0, T1, T2, T3, T4, T>(
    Generator<T0> generator0,
    Generator<T1> generator1,
    Generator<T2> generator2,
    Generator<T3> generator3,
    Generator<T4> generator4,
    T Function(T0 arg0, T1 arg1, T2 arg2, T3 arg3, T4 arg4) combiner,
  ) {
    return _combineN(
      [generator0, generator1, generator2, generator3, generator4],
      (values) => combiner(
        values[0] as T0,
        values[1] as T1,
        values[2] as T2,
        values[3] as T3,
        values[4] as T4,
      ),
    );
  }

  /// Combines 6 values.
  Generator<T> combine6<T0, T1, T2, T3, T4, T5, T>(
    Generator<T0> generator0,
    Generator<T1> generator1,
    Generator<T2> generator2,
    Generator<T3> generator3,
    Generator<T4> generator4,
    Generator<T5> generator5,
    T Function(T0 arg0, T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5) combiner,
  ) {
    return _combineN(
      [generator0, generator1, generator2, generator3, generator4, generator5],
      (values) => combiner(
        values[0] as T0,
        values[1] as T1,
        values[2] as T2,
        values[3] as T3,
        values[4] as T4,
        values[5] as T5,
      ),
    );
  }

  // Combines 7 values.
  Generator<T> combine7<T0, T1, T2, T3, T4, T5, T6, T>(
    Generator<T0> generator0,
    Generator<T1> generator1,
    Generator<T2> generator2,
    Generator<T3> generator3,
    Generator<T4> generator4,
    Generator<T5> generator5,
    Generator<T6> generator6,
    T Function(T0 arg0, T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6)
        combiner,
  ) {
    return _combineN(
      [
        generator0, generator1, generator2, generator3, generator4, generator5,
        generator6 //
      ],
      (values) => combiner(
        values[0] as T0,
        values[1] as T1,
        values[2] as T2,
        values[3] as T3,
        values[4] as T4,
        values[5] as T5,
        values[6] as T6,
      ),
    );
  }

  // Combines 8 values.
  Generator<T> combine8<T0, T1, T2, T3, T4, T5, T6, T7, T>(
    Generator<T0> generator0,
    Generator<T1> generator1,
    Generator<T2> generator2,
    Generator<T3> generator3,
    Generator<T4> generator4,
    Generator<T5> generator5,
    Generator<T6> generator6,
    Generator<T7> generator7,
    T Function(T0 arg0, T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6,
            T7 arg7)
        combiner,
  ) {
    return _combineN(
      [
        generator0, generator1, generator2, generator3, generator4, generator5,
        generator6, generator7 //
      ],
      (values) => combiner(
        values[0] as T0,
        values[1] as T1,
        values[2] as T2,
        values[3] as T3,
        values[4] as T4,
        values[5] as T5,
        values[6] as T6,
        values[7] as T7,
      ),
    );
  }

  // Combines 9 values.
  Generator<T> combine9<T0, T1, T2, T3, T4, T5, T6, T7, T8, T>(
    Generator<T0> generator0,
    Generator<T1> generator1,
    Generator<T2> generator2,
    Generator<T3> generator3,
    Generator<T4> generator4,
    Generator<T5> generator5,
    Generator<T6> generator6,
    Generator<T7> generator7,
    Generator<T8> generator8,
    T Function(T0 arg0, T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6,
            T7 arg7, T8 arg8)
        combiner,
  ) {
    return _combineN(
      [
        generator0, generator1, generator2, generator3, generator4, generator5,
        generator6, generator7, generator8 //
      ],
      (values) => combiner(
        values[0] as T0,
        values[1] as T1,
        values[2] as T2,
        values[3] as T3,
        values[4] as T4,
        values[5] as T5,
        values[6] as T6,
        values[7] as T7,
        values[8] as T8,
      ),
    );
  }

  // Combines 10 values.
  Generator<T> combine10<T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T>(
    Generator<T0> generator0,
    Generator<T1> generator1,
    Generator<T2> generator2,
    Generator<T3> generator3,
    Generator<T4> generator4,
    Generator<T5> generator5,
    Generator<T6> generator6,
    Generator<T7> generator7,
    Generator<T8> generator8,
    Generator<T9> generator9,
    T Function(T0 arg0, T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6,
            T7 arg7, T8 arg8, T9 arg9)
        combiner,
  ) {
    return _combineN(
      [
        generator0, generator1, generator2, generator3, generator4, generator5,
        generator6, generator7, generator8, generator9 //
      ],
      (values) => combiner(
        values[0] as T0,
        values[1] as T1,
        values[2] as T2,
        values[3] as T3,
        values[4] as T4,
        values[5] as T5,
        values[6] as T6,
        values[7] as T7,
        values[8] as T8,
        values[9] as T9,
      ),
    );
  }
}

class ShrinkableCombination<T> implements Shrinkable<T> {
  ShrinkableCombination(this.fields, this.combiner);

  final List<Shrinkable<T>> fields;
  final T Function(List<dynamic> values) combiner;

  @override
  T get value => combiner(fields);

  @override
  Iterable<Shrinkable<T>> shrink() sync* {
    for (var i = 0; i < fields.length; i++) {
      for (final shrunk in fields[i].shrink()) {
        yield ShrinkableCombination(List.of(fields)..[i] = shrunk, combiner);
      }
    }
  }
}

final _defaultGenerators = {
  _TypeWrapper<Null>(): any.null_,
  _TypeWrapper<bool>(): any.bool,
  _TypeWrapper<int>(): any.int,
  _TypeWrapper<double>(): any.double,
  _TypeWrapper<num>(): any.num,
  _TypeWrapper<BigInt>(): any.bigInt,
  _TypeWrapper<DateTime>(): any.dateTime,
  _TypeWrapper<Duration>(): any.duration,
  _TypeWrapper<List<bool>>(): any.list(any.bool),
  _TypeWrapper<List<int>>(): any.list(any.int),
  _TypeWrapper<List<double>>(): any.list(any.double),
  _TypeWrapper<List<num>>(): any.list(any.num),
  _TypeWrapper<List<BigInt>>(): any.list(any.bigInt),
  _TypeWrapper<List<DateTime>>(): any.list(any.dateTime),
  _TypeWrapper<List<Duration>>(): any.list(any.duration),
  _TypeWrapper<Set<int>>(): any.set(any.int),
  _TypeWrapper<Set<BigInt>>(): any.set(any.bigInt),
  _TypeWrapper<Map<int, bool>>(): any.map(any.int, any.bool),
  _TypeWrapper<Map<int, int>>(): any.map(any.int, any.int),
  _TypeWrapper<Map<int, double>>(): any.map(any.int, any.double),
  _TypeWrapper<Map<int, num>>(): any.map(any.int, any.num),
  _TypeWrapper<Map<int, BigInt>>(): any.map(any.int, any.bigInt),
  _TypeWrapper<Map<int, DateTime>>(): any.map(any.int, any.dateTime),
  _TypeWrapper<Map<int, Duration>>(): any.map(any.int, any.duration),
  _TypeWrapper<Map<int, bool>>(): any.map(any.int, any.bool),
  _TypeWrapper<Map<BigInt, int>>(): any.map(any.bigInt, any.int),
  _TypeWrapper<Map<BigInt, double>>(): any.map(any.bigInt, any.double),
  _TypeWrapper<Map<BigInt, num>>(): any.map(any.bigInt, any.num),
  _TypeWrapper<Map<BigInt, BigInt>>(): any.map(any.bigInt, any.bigInt),
  _TypeWrapper<Map<BigInt, DateTime>>(): any.map(any.bigInt, any.dateTime),
  _TypeWrapper<Map<BigInt, Duration>>(): any.map(any.bigInt, any.duration),
};
