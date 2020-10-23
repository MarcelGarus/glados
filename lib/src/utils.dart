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

extension ChoosingRandomly on Random {
  T choose<T>(List<T> list) => list[nextInt(nextInt(list.length))];
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

  String toString() => 'You tried to create a Glados instance with "$type" as\n'
      'a type argument. But no arbitrary was found for $type.\n'
      '\n'
      'You should specify which arbitrary to use. Here are a few options:\n'
      '\n'
      '- Explicitly use a predefined arbitrary, for example like this:\n'
      "    Glados(any.lowercaseLetters).test('blub', (input) { ... });\n"
      // "- Check if there's a glados package for ${type}. For example, for the\n"
      // "  package tuple, there's the tuple_glados package, which contains\n"
      // '  arbitraries for the types defined in tuples.\n'
      // '  By the way, you can also add the following to your\n'
      // '  analysis_options.yaml to get automatic hints for available glados\n'
      // '  packages for types in your glados tests:\n'
      // '    ...\n'
      // '- Automatically generate an Arbitrary<$type> by annotating the $type\n'
      // '  class with @GenerateGladosArbitrary and running the following command\n'
      // '  in the command line:\n'
      // '    \$> pub run build_runner build\n'
      '- Create a new arbitrary manually:\n'
      '    extension ${type}Arbitrary on Any {\n'
      '      Arbitrary<${type}> get ${type.toString().toLowerCase()} => arbitrary(\n'
      '        generate: (random, size) => /* code for generating a ${type} */,\n'
      '        shrink: (input) => /* code for shrinking the input */,\n'
      '      );\n'
      '    }\n'
      '  Then, either use the arbitrary directly:\n'
      "    Glados(any.${type.toString().toLowerCase()}).test('blub', () { ... });\n"
      '  Or register the arbitrary as the default arbitrary for ${type}s:\n'
      '    Any.setDefault<$type>(any.${type.toString().toLowerCase()});\n'
      '  For more information on implementing your own arbitrary, have a look at\n'
      '  https://pub.dev/packages/glados#creating-a-custom-arbitrary.';
}

/// For the same input, an invariance sometimes throws an exceptions and
/// sometimes doesn't. Invariants should be deterministic though.
class InvarianceNotDeterministic implements Exception {
  String toString() => 'The invariance was called twice with the same value. '
      'The first time, an exception was thrown, the second time, it executed '
      'normally. The invariance has to be deterministic.';
}
