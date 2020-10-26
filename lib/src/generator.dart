import 'package:analyzer/dart/element/element.dart';
// That's just the way the import system works for now.
// ignore: implementation_imports
import 'package:build/src/builder/build_step.dart';
import 'package:build/build.dart';
import 'package:glados/src/annotations.dart';
import 'package:source_gen/source_gen.dart';

/// Builds generators for `build_runner` to run.
Builder getArbitraryBuilder(BuilderOptions options) {
  return SharedPartBuilder([ArbitraryGenerator()], 'glados');
}

class ArbitraryGenerator extends Generator {
  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    final code = StringBuffer();
    final annotatedClasses = library.allElements
        .whereType<ClassElement>()
        .where((class_) => class_.wantsArbitrary);

    for (final class_ in annotatedClasses) {
      final name = class_.name;
      final getterName = name.toLowerCamelCase();
      code.writeln('extension Arbitrary$name on Any {');

      if (class_.isEnum) {
        code
          ..writeln('Arbitrary<$name> get $getterName => arbitrary(')
          ..writeln('  generate: (random, size) {')
          ..writeln('    return $name.values[random.nextInt(')
          ..writeln('      size.clamp(0, $name.values.length - 1),')
          ..writeln('    )];')
          ..writeln('  },')
          ..writeln('  shrink: ($getterName) sync* {')
          ..writeln('    if ($getterName.index > 0) {')
          ..writeln('      yield $name.values[$getterName.index - 1];')
          ..writeln('    }')
          ..writeln('  },')
          ..writeln(');');
      } else {
        // TODO: assert: has only initializing formals and no extra fields.
        final constructor = class_.unnamedConstructor;
        if (constructor == null) {
          throw Exception("$name isn't annotated with @GenerateArbitrary, but "
              "doesn't have an unnamed constructor. If you don't want to "
              'provide an unnamed constructor, you need to create an arbitray '
              'manually.');
        }
        final parameters = constructor.parameters;
        for (final parameter in parameters) {
          if (!parameter.isInitializingFormal) {
            throw Exception("$name's unnamed constructor has the parameter "
                '"${parameter.name}", which doesn\'t use the '
                '"this.${parameter.name}" syntax. '
                "You'll need to create an arbitrary manually.");
          }
        }
        for (final field in class_.fields) {
          if (parameters.every((parameter) => parameter.name != field.name)) {
            throw Exception("Field ${field.name} isn't initialized in the "
                'unnamed constructor using the "this.${field.name}" syntax. '
                "You'll need to create an arbitrary manually.");
          }
        }
        code
          ..writeln('Arbitrary<${class_.name}> $getterName(')
          ..writeln([
            for (final parameter in parameters)
              'Arbitrary<${parameter.type.getDisplayString(withNullability: false)}> '
                  '${parameter.name}Arbitrary,'
          ].joinLines())
          ..writeln(') => arbitrary(')
          ..writeln('  generate: (random, size) {')
          ..writeln('    return $name(')
          ..writeln([
            for (final parameter in parameters) ...[
              if (parameter.isNamed) '${parameter.name}: ',
              '${parameter.name}Arbitrary.generate(random, size),'
            ],
          ].joinLines())
          ..writeln('    );')
          ..writeln('  },')
          ..writeln('  shrink: ($getterName) sync* {')
          ..writeln([
            for (final parameter in parameters) ...[
              'for (final ${parameter.name} in '
                  '${parameter.name}Arbitrary.shrink($getterName.${parameter.name})) {',
              '  yield $name(',
              for (final p in parameters) ...[
                if (p.isNamed) '${p.name}: ',
                if (p == parameter)
                  '${parameter.name},'
                else
                  '$getterName.${p.name},',
              ],
              '  );',
              '}',
            ],
          ].joinLines())
          ..writeln('  ')
          ..writeln('  },')
          ..writeln(');');
      }

      code.writeln('}\n');
    }

    return code.toString();
  }
}

extension on Element {
  bool get wantsArbitrary => TypeChecker.fromRuntime(GenerateArbitrary)
      .hasAnnotationOf(this, throwOnUnresolved: false);
}

extension on String {
  String toLowerCamelCase() => this[0].toLowerCase() + substring(1);
}

extension on List<String> {
  String joinLines() => join('\n');
}
