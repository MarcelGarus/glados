import 'package:glados/src/utils.dart';
import 'package:test/test.dart';

class Foo {}

class Bar<A> {}

class Baz<A, B> {}

void main() {
  test('simple', () {
    expect(RichType.from(Foo), equals(RichType('Foo')));
    expect(RichType.from(String), equals(RichType('String')));
    expect(RichType.from(int), equals(RichType('int')));
  });
  test('nested', () {
    expect(
      RichType.from(Bar<Foo>().runtimeType),
      equals(RichType('Bar', [RichType('Foo')])),
    );
    expect(
      RichType.from(Baz<Foo, Bar<Foo>>().runtimeType),
      equals(RichType('Baz', [
        RichType('Foo'),
        RichType('Bar', [RichType('Foo')])
      ])),
    );
    expect(
      RichType.from(Bar<Bar<Foo>>().runtimeType),
      equals(RichType('Bar', [
        RichType('Bar', [RichType('Foo')])
      ])),
    );
  });
}
