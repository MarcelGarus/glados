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

/// The maximum number of fields that the code generator can handle. Limited by
/// how many `any.combineN` functions there are.
const numMaxFields = 10;

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
      code.writeln('extension Any$name on Any {');

      if (class_.isEnum) {
        code.writeln('Generator<$name> get ${name.toLowerCamelCase()} => '
            'choose($name.values);');
      } else {
        final fields = class_.fields
            .where((field) => !field.isStatic)
            .where((field) => !field.isSynthetic)
            .toList();
        final constructor = class_.unnamedConstructor;
        final parameters = constructor?.parameters ?? [];
        final fieldNames = fields.map((field) => field.name).toSet();
        final parameterNames =
            parameters.map((parameter) => parameter.name).toSet();

        final hasAcceptableNumberOfFields = fields.length <= numMaxFields;
        final hasUnnamedConstructor = constructor != null;
        final hasOnlyInitializingFormals =
            parameters.every((p) => p.isInitializingFormal);
        final parametersCoverFields =
            fieldNames.difference(parameterNames).isEmpty;

        if (hasAcceptableNumberOfFields &&
            hasUnnamedConstructor &&
            hasOnlyInitializingFormals &&
            parametersCoverFields) {
          code
            ..writeln('Generator<$name> ${name.toLowerCamelCase()}(')
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
        } else {
          throw Exception([
            "$name is annotated with @glados, so Glados tried to create a "
                "generator of type Generator<$name>.",
            "But that didn't work for the following reasons:",
            if (!hasAcceptableNumberOfFields)
              [
                '⚠️ Classes with more than 10 fields are not supported yet.',
                '',
                "  Here's what you should do:",
                '',
                '  1. Open an issue about that.',
                '  2. Work around that by writing a generator manually.',
                '',
                "  To make the first step easier, here's a link to an already "
                    "filled out issue:",
                '  ' +
                    _buildIssueLink(
                      'Support classes with ${fields.length} fields during '
                      'code generation',
                      [
                        'Hi,',
                        '',
                        "my class `$name` has the following fields:",
                        for (final field in fields)
                          '- `${field.name}` (`${field.type}`)',
                        '',
                        'It would be great if Glados could automatically '
                            'serialize such classes using just the `@glados` '
                            'annotation.',
                        "Currently, that doesn't work, because the code "
                            "generator supports only $numMaxFields fields.",
                      ].joinLines(),
                    ),
              ].joinLines(),
            if (!hasUnnamedConstructor)
              [
                "⚠️ $name doesn't have an unnamed constructor, which is "
                    "necessary for this to work.",
                '',
                "  Here's what you can do:",
                '',
                '  * Create an unnamed constructor that initializes all fields '
                    'using the "this.field" syntax (initializing formals).',
                '    By the way, using the meta package, you can also annotate '
                    'constructors with @visibleForTesting. This shows linter '
                    'warnings if you attempt to use the constructor outside '
                    'of your tests.',
                "  * If you don't want to provide an unnamed constructor that "
                    'initializes all fields, you need to write a generator '
                    'manually.',
                '',
              ].joinLines(),
            if (!hasOnlyInitializingFormals)
              [
                "⚠️ $name's unnamed constructor has parameters that don't use "
                    'the "this.field" syntax (initializing formals).',
                '',
                '  These are the parameters in question:',
                '',
                for (final parameter
                    in parameters.where((p) => !p.isInitializingFormal))
                  '  * ${parameter.name}',
                '',
                "This means that you'll have to write a generator manually.",
              ].joinLines(),
            if (hasUnnamedConstructor &&
                hasOnlyInitializingFormals &&
                !parametersCoverFields)
              [
                '⚠️ Not all fields are covered by the "this.field" parameters '
                    'of the unnamed constructor.',
                '',
                '  These fields are not covered:',
                '',
                for (final field in fieldNames.difference(parameterNames))
                  '  * $field',
                '',
                "This means that you'll have to write a generator manually.",
              ].joinLines(),
            [
              "😇 Good luck fixing those errors!",
              "If you decide to write a generator manually, here's the "
                  'boilerplate code for that:',
              '',
              'extension Any$name on Any {',
              '  Generator<$name> ${name.toLowerCamelCase()}(',
              for (final field in fields)
                '    Generator<${field.type}> ${field.name}Generator,',
              '  ) {',
              if (hasAcceptableNumberOfFields) ...[
                '    return combine${fields.length}(',
                for (final field in fields) '      ${field.name}Generator,',
                '      (${fields.map((f) => f.name).join(', ')}) {',
                '        // TODO: Create and return an instance of $name.',
                '      };',
                '    );',
              ] else
                '    // TODO: Create an return an instance of Generator<$name>.',
              '  }',
              '}'
            ].joinLines(),
          ].joinParts());
        }
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
  String joinParts() => join('\n\n');
}

String _buildIssueLink(String title, String body) {
  // TODO: Use built-in functionality.
  String escape(String string) => string
      .replaceAll(' ', '+')
      .replaceAll("'", '%27')
      .replaceAll('\n', '%0a');
  return 'https://github.com/marcelgarus/glados/issues/new?title=${escape(title)}&body=${escape(body)}';
}
