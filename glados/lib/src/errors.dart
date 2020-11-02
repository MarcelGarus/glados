import 'package:glados/src/packages.dart';

import 'structured_text.dart';
import 'utils.dart';

class InternalNoGeneratorFound implements Exception {}

/// Indicates that no arbitrary was found for a type.
class NoGeneratorFound implements Exception {
  NoGeneratorFound(this.numGladosArgs, this.typeIndex, this.type);

  final int numGladosArgs;
  final int typeIndex;
  final Type type;

  String toString() {
    final richType = RichType.fromType(type);
    return Flow([
      Paragraph("Glados couldn't find a generator for $type."),
      Paragraph.noNl('This type is used in your Glados call:'),
      Code([_gladosCall([])]),
      Paragraph('There are two ways to fix this:'),
      BulletList([
        Flow([
          Paragraph.noNl('Use a generator explicitly:'),
          Code([
            _gladosCall([
              for (var i = 0; i <= typeIndex; i++)
                if (i < typeIndex) 'null' else 'yourGenerator',
            ], showTypeParameter: false),
          ]),
        ]),
        Flow([
          Paragraph.noNl('Register a default generator:'),
          Code(['Any.setDefault<$type>(yourGenerator);']),
        ]),
      ]),
      Paragraph('So, how can you create a generator?'),
      if (richType.hasGenerics) ...[
        Paragraph("Because you're trying to generate a type with generics, you "
            'should compose simpler generators:'),
        Code([richType.toGeneratorString()]),
        BulletList([
          for (final typeName in richType.allTypes())
            Flow([
              Paragraph.noNl('any.${typeName.toLowerCamelCase()}:'),
              ..._helpForSimpleType(typeName),
              Paragraph(),
            ]),
        ]),
      ] else ...[
        Paragraph("Your generator should probably look like this:"),
        ..._helpForSimpleType(richType.name.toString()),
      ],
      Paragraph(),
      Paragraph('For more information on writing your own generator, have a '
          'look at https://pub.dev/packages/glados#how-to-write-generators.'),
    ]).toString();
  }

  String _gladosCall(List<String> arguments, {bool showTypeParameter = true}) {
    return [
      'Glados',
      if (numGladosArgs > 1) '$numGladosArgs',
      '<',
      [
        for (var i = 0; i < numGladosArgs; i++)
          if (i == typeIndex && showTypeParameter) '$type' else '...',
      ].join(', '),
      '>(',
      arguments.join(', '),
      ')',
    ].join();
  }

  Iterable<StructuredText> _helpForSimpleType(String typeName) sync* {
    final packages = typeNameToPackages[typeName] ?? [];

    if (packages.isEmpty) {
      yield Paragraph.noNl(
          'You probably need to write this generator on your own.');
    } else if (packages.length == 1) {
      final package = packages.single;
      if (package == builtIn) {
        yield Paragraph.noNl("Is this the $typeName from $package? There's "
            "already a built-in generator.");
      } else {
        yield Paragraph.noNl('Is it from $package? The ${package.gladosName} '
            'package contains a generator for it.');
      }
    } else {
      yield Flow([
        Paragraph.noNl("From which package is $typeName?"),
        BulletList([
          for (final package in packages)
            if (package == builtIn)
              Paragraph.noNl('$package: Already built-in.')
            else
              Paragraph.noNl(
                  "$package: There's a ${package.gladosName} package."),
        ]),
      ]);
    }
  }
}

/// For the same input, an invariance sometimes throws an exceptions and
/// sometimes doesn't. Invariants should be deterministic though.
class InvarianceNotDeterministic implements Exception {
  InvarianceNotDeterministic(this.input);

  final dynamic input;

  @override
  String toString() {
    return Flow([
      Paragraph('An invariance behaved undeterministically. For the input '
          '$input, it failed the first time, but succeeded the second time.'),
      Paragraph('Make sure that if given the same input, the invariance '
          'always behaves the same way.'),
    ]).toString();
  }
}
