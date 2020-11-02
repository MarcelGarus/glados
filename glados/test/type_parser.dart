import 'package:glados/src/utils.dart';
import 'package:test/test.dart';

void main() {
  test('simple', () {
    expect(RichType.fromString('Foo'), equals(RichType('Foo')));
    expect(RichType.fromString('String'), equals(RichType('String')));
    expect(RichType.fromString('int'), equals(RichType('int')));
  });
  test('nested', () {
    expect(
      RichType.fromString('Bar<Foo>'),
      equals(RichType('Bar', [RichType('Foo')])),
    );
    expect(
      RichType.fromString('Baz<Foo, Bar<Foo>>'),
      equals(RichType('Baz', [
        RichType('Foo'),
        RichType('Bar', [RichType('Foo')])
      ])),
    );
    expect(
      RichType.fromString('Bar<Bar<Foo>>'),
      equals(RichType('Bar', [
        RichType('Bar', [RichType('Foo')])
      ])),
    );
  });
  test('invalid', () {
    expect(RichType.fromString('Bar<'), equals(null));
    expect(RichType.fromString('Bar<Foo'), equals(null));
    expect(RichType.fromString('Bar<Foo>>'), equals(null));
  });
}
