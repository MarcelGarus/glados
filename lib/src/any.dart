import 'dart:math';

import 'package:meta/meta.dart';

import 'anys.dart';
import 'utils.dart';

/// An [Arbitrary] makes it possible to use [Glados] to test type [T].
abstract class Arbitrary<T> {
  /// Generates a new value of type [T], using [size] as a rough complexity
  /// estimate. The [random] instance should be used for all pseudo-random
  /// values.
  T generate(Random random, int size);

  /// Given an [input], generates an [Iterable] of inputs that fulfill the
  /// following criteria:
  ///
  /// - They are _similar_ to the given [input]: They only differ in little
  ///   ways.
  /// - They are _simpler_ than the given [input]: The transitive hull is finite
  ///   and acyclic: If you would call [shrink] on all returned inputs and on
  ///   the inputs returned by them etc., this process should terminate
  ///   sometime.
  Iterable<T> shrink(T input);
}

/// A version of [Arbitrary] where you can pass both methods as parameters,
/// making it very simple to define custom anonymous implementations without
/// creating new classes.
class _InlineArbitrary<T> extends Arbitrary<T> {
  _InlineArbitrary(this._generate, this._shrink);

  final T Function(Random random, int size) _generate;
  final Iterable<T> Function(T input) _shrink;

  T generate(Random random, int size) => _generate(random, size);
  Iterable<T> shrink(T input) => _shrink(input);
}

/// A namespace for all [Arbitrary]s.
///
/// New [Arbitrary]s should be added as extension methods, so you can use them
/// with a syntax like this: `any.int`
/// Also, you can register an [Arbitrary] as the default [Arbitrary] for a given
/// type. Then, you don't need to pass the concrete [Arbitrary] to [Glados]
/// anymore – [Glados] can infer the right [Arbitrary] for the type annotation.
class Any {
  /// A map from [Type]s to their default [Arbitrary].
  static final _defaults = <_TypeWrapper<dynamic>, Arbitrary<dynamic>>{
    ..._defaultArbitraries
  };
  static void setDefault<T>(Arbitrary<T> arbitrary) =>
      _defaults[_TypeWrapper<T>()] = arbitrary;
  static Arbitrary<T> defaultFor<T>() =>
      _defaults[_TypeWrapper<T>()] ?? (throw NoArbitraryFound(T));

  /// Creates a new arbitrary with the given functions.
  Arbitrary<T> arbitrary<T>({
    @required T Function(Random random, int size) generate,
    @required Iterable<T> Function(T input) shrink,
  }) =>
      _InlineArbitrary(generate, shrink);
}

/// The [any] singleton, providing a namespace for [Arbitrary]s.
final any = Any();

class _TypeWrapper<T> {
  operator ==(Object other) => other.runtimeType == runtimeType;
  int get hashCode => runtimeType.hashCode;
}

final _defaultArbitraries = {
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
