import 'package:analyzer/dart/element/element.dart';
// That's just the way the import system works for now.
// ignore: implementation_imports
import 'package:build/src/builder/build_step.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

/// Annotation for generating arbitraries.
class GladosAnnotation {
  const GladosAnnotation();
}

/// Annotation for auto-generating Glados generators.
///
/// 1. Annotate a data class or enum with this `@glados` annotation.
/// 2. Add a `part 'my_file.g.dart';` directive below your imports.
/// 3. Run `pub run build_runner build` in the command line.
///
/// If that doesn't work, you'll probably need to write a generator manually.
/// But now worries, just have a look at other generators defined on `any` –
/// it's really not that hard.
const glados = GladosAnnotation();

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
      code.writeln('extension Any$name on Any {');

      if (class_.isEnum) {
        code.writeln(
            'Generator<$name> get $getterName => choose($name.values);');
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
        if (parameters.length > 10) {
          throw Exception("Classes with more than 10 fields are not supported "
              "yet. Here's what you should do:\n\n"
              "1. Open an issue about that.\n"
              "2. Work around that by creating a generator manually.\n\n"
              "To make the first point easier, here's a link to a fitting "
              "issue template: TODO");
        }
        code
          ..writeln('Generator<${class_.name}> $getterName(')
          ..writeln([
            for (final parameter in parameters)
              'Generator<${parameter.typeString}> ${parameter.name}Generator,'
          ].joinLines())
          ..writeln(') => combine${parameters.length}(')
          ..writeln([
            for (final parameter in parameters) '${parameter.name}Generator,'
          ].joinLines())
          ..writeln('  (${parameters.map((p) => p.name).join(', ')}) {')
          ..writeln('    return $name(')
          ..writeln([
            for (final parameter in parameters)
              [
                if (parameter.isNamed) '${parameter.name}: ',
                '${parameter.name},'
              ].join(),
          ].joinLines())
          ..writeln('    );')
          ..writeln('  },')
          ..writeln(');');
      }

      code.writeln('}\n');
    }

    return code.toString();
  }
}

extension on Element {
  bool get wantsArbitrary => TypeChecker.fromRuntime(GladosAnnotation)
      .hasAnnotationOf(this, throwOnUnresolved: false);
}

extension on ParameterElement {
  String get typeString => type.getDisplayString(withNullability: false);
}

extension on String {
  String toLowerCamelCase() => this[0].toLowerCase() + substring(1);
}

extension on List<String> {
  String joinLines() => join('\n');
}
