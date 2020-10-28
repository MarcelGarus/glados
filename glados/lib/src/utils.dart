import 'dart:math';

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

extension RandomUtils on Random {
  T choose<T>(List<T> list) => list[nextInt(nextInt(list.length))];
  int nextIntInRange(int min, int max) {
    assert(min == null || max == null || min <= max);
    return nextInt(max - min) + min;
  }
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

extension CamelCasing on String {
  String toLowerCamelCase() => this[0].toLowerCase() + substring(1);
}

extension JoinableStrings on List<String> {
  String joinLines() => join('\n');
  String joinParts() => join('\n\n');
}

/// Indicates that no arbitrary was found for a type.
class NoGeneratorFound implements Exception {
  NoGeneratorFound(this.type);

  final Type type;

  String toString() => [
        'You tried to create a Glados instance with $type as a type argument. '
            'But no default generator was found for $type.',
        '',
        "Here's what you can do:",
        '',
        '1.  Make sure a generator exists.',
        '    Usually, generators are available on any.',
        '',
        '    * Check if a generator matching your use case exists on any.',
        '      Some types have predefined generators for a subset of their '
            "value space and aren't registered as the default for that type.",
        "      For example, String doesn't have a default generator. Instead, "
            'there are generators for specifiy use cases, like any.letter or '
            'any.digit.',
        '',
        '    * Look for a package that provides the generator.',
        "      For example, for types from the tuples package, there's the "
            "tuples_glados package, which simply provides generators on any.",
        '',
        '    * If you want to test your own type, try annotating the type with '
            '@glados and run "pub run build_runner build".',
        '      If your type is simple enough, this will auto-generate a ',
        'generator available at any.${type.lowerCamelCased}.',
        '',
        '    * If you have a complex class or you want more control over the '
            'distribution of the generated value space, you can write your ',
        'own generator.',
        "      Here's the boilerplate code for that:",
        // TODO: Check if the type has generic arguments.
        '',
        '      extension Any$type on Any {',
        '        Generator<$type> get ${type.lowerCamelCased} {',
        '          // TODO: write the generator',
        '        };',
        '      }',
        '',
        '      If your type is composed of smaller values that you also want '
            'to make configurable, you can define it as a getter:',
        '',
        '      extension Any$type on Any {',
        '        Generator<type> ${type.lowerCamelCased}(Generator<Blub> blubGenerator) {',
        '          // TODO: write the generator',
        '        }',
        '      }',
        '',
        '      For more information on writing your own generator, have a look at',
        '      https://pub.dev/packages/glados#how-does-it-work.',
        '',
        '2.  Use the generator.',
        '',
        '    * If you want to set the generator as the default for ${type}s, '
            'do it like this:',
        // TODO: handle generics
        '',
        '      Any.setDefault<$type>(any.${type.lowerCamelCased};',
        '',
        '      Note that the generator will only be used if you request exactly '
            'the same type. For any other call except Glados<$type>(), this '
            'will not work.',
        '',
        '    * Use the generator explicitly:',
        '',
        '      Glados(any.${type.lowerCamelCased}).test((${type.lowerCamelCased}) {',
        '        // your test',
        '      });',
      ].joinLines();
}

/// For the same input, an invariance sometimes throws an exceptions and
/// sometimes doesn't. Invariants should be deterministic though.
class InvarianceNotDeterministic implements Exception {
  String toString() => 'The invariance was called twice with the same value. '
      'The first time, an exception was thrown, the second time, it executed '
      'normally. The invariance has to be deterministic.';
}

extension LowerCasedType on Type {
  String get lowerCamelCased => toString().toLowerCamelCase();
}
