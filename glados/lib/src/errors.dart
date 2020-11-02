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
    final richType = RichType.from(type);
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
      if (richType.hasGenerics)
        ..._helpForGenericType(richType)
      else if (richType == RichType('String')) ...[
        Paragraph("For Strings, there's no default generator yet. Instead, "
            'there are a few specialized ones. These might be interesting:'),
        Code([
          'any.lowercaseLetter',
          'any.uppercaseLetter',
          'any.letter',
          'any.digit',
          'any.letterOrDigit',
        ]),
        Paragraph("Maybe, a default String generator will be supported in the "
            'future. But because generating valid Unicode Strings is more '
            "difficult than initially thought, this isn't supported yet. If "
            'you know your way around Strings, maybe you find some time for '
            'filing a PR?'),
      ],
      if (!richType.hasGenerics) ...[
        Paragraph('If you want to make your generator available at multiple '
            'places, you can add it as an extension method:'),
        Code([
          'extension Any$type on Any {',
          '  Generator<$type> get ${type.lowerCamelCased} {',
          '    // TODO: Write the generator.',
          '  }',
          '}',
        ]),
      ],
      Paragraph('For more information on writing your own generator, '
          'have a look at https://pub.dev/packages/glados#how-does-it-work.'),
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

  Iterable<StructuredText> _helpForGenericType(RichType richType) sync* {
    yield Paragraph("Because you're trying to generate a type with generics, "
        'you should compose simpler generators:');
    yield Code([richType.toGeneratorString()]);

    yield BulletList([
      for (final type in richType.allTypes())
        () {
          final generatorName = 'any.${type.toLowerCamelCase()}';
          final packages = typeNameToPackages[type] ?? [];

          if (packages.isEmpty) {
            return Paragraph.noNl('$generatorName: You probably need to write '
                'this one on your own.');
          } else if (packages.length == 1) {
            final package = packages.single;
            if (package == builtIn) {
              return Paragraph.noNl('$generatorName: Is this the $type from '
                  '$package? '
                  "There's already a built-in generator.");
            }
            return Paragraph.noNl("$generatorName: Is it from $package? The "
                '${package.gladosName} package contains a generator for it.');
          } else {
            return Flow([
              Paragraph.noNl("$generatorName: From which package is $type?"),
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
        }()
    ]);

    yield Paragraph();
  }
}

/// For the same input, an invariance sometimes throws an exceptions and
/// sometimes doesn't. Invariants should be deterministic though.
class InvarianceNotDeterministic implements Exception {
  String toString() => 'The invariance was called twice with the same value. '
      'The first time, an exception was thrown, the second time, it executed '
      'normally. The invariance has to be deterministic.';
}
