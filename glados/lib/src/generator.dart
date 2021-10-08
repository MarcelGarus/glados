import 'dart:math';

/// An [Generator] makes it possible to use [Glados] to test type [T].
/// Generates a new [Shrinkable] of type [T], using [size] as a rough
/// complexity estimate. The [random] instance should be used as a source for
/// all pseudo-randomness.
typedef Generator<T> = Shrinkable<T> Function(Random random, int size);

/// A wrapper for a value that knows how to shrink itself.
abstract class Shrinkable<T> {
  factory Shrinkable(T value, Iterable<Shrinkable<T>> Function() shrink) =
      _InlineShrinkableValue<T>;

  /// The actual value itself.
  T get value;

  /// Generates an [Iterable] of [Shrinkable]s that fulfill the following
  /// criteria:
  ///
  /// - They are _similar_ to this: They only differ in little ways.
  /// - They are _simpler_ than this: The transitive hull is finite acyclic. If
  ///   you would call [shrink] on all returned values and on the values
  ///   returned by them etc., this process should terminate sometime.
  Iterable<Shrinkable<T>> shrink();
}

/// An inline versions for the [Shrinkable].
class _InlineShrinkableValue<T> implements Shrinkable<T> {
  _InlineShrinkableValue(this.value, this._shrinker);

  @override
  final T value;
  final Iterable<Shrinkable<T>> Function() _shrinker;

  @override
  Iterable<Shrinkable<T>> shrink() => _shrinker();

  @override
  String toString() => 'Shrinkable$T($value)';
}

/// Useful methods on [Generator]s.
extension GeneratorUtils<T> on Generator<T> {
  Generator<R> map<R>(R Function(T value) mapper) {
    return (random, size) {
      final value = this(random, size);
      return MappedShrinkableValue<T, R>(value, mapper);
    };
  }

  Generator<R> bind<R>(Generator<R> Function(T value) mapper) {
    return (random, size) => map(mapper)(random, size).value(random, size);
  }

  Generator<T?> get nullable {
    return (random, size) {
      final value = this(random, size);
      return NullableShrinkableValue(value);
    };
  }
}

class MappedShrinkableValue<T, R> implements Shrinkable<R> {
  MappedShrinkableValue(this.originalValue, this.mapper);

  final Shrinkable<T> originalValue;
  final R Function(T value) mapper;

  @override
  R get value => mapper(originalValue.value);

  @override
  Iterable<Shrinkable<R>> shrink() {
    return originalValue.shrink().map((value) {
      return MappedShrinkableValue(value, mapper);
    });
  }
}

class NullableShrinkableValue<T> implements Shrinkable<T?> {
  NullableShrinkableValue(this.originalValue);

  final Shrinkable<T> originalValue;

  @override
  T? get value => originalValue.value;

  @override
  Iterable<Shrinkable<T?>> shrink() {
    final shrinkableNull = Shrinkable<T?>(null, () => []);
    return originalValue
        .shrink()
        .cast<Shrinkable<T?>>()
        .followedBy([shrinkableNull]);
  }
}
