import 'package:glados/glados.dart';
import 'package:glados/src/rich_type.dart';
import 'package:test/test.dart';

extension AnyRichType on Any {
  Generator<RichType> get richType => (random, size) {
        return ShrinkableRichType(
          letter(random, size),
          // This getter doesn't return itself, but a lambda which – if
          // invoked – returns it.
          // ignore: recursive_getters
          any.list(richType)(random, size - 1),
        );
      };
}

class ShrinkableRichType implements Shrinkable<RichType> {
  ShrinkableRichType(this.name, this.children);

  final Shrinkable<String> name;
  final Shrinkable<List<RichType>> children;

  @override
  RichType get value => RichType(name.value, children.value);

  @override
  Iterable<ShrinkableRichType> shrink() sync* {
    for (final n in name.shrink()) {
      for (final child in children.shrink()) {
        yield ShrinkableRichType(n, child);
      }
    }
  }
}

void main() {
  Any.setDefault<RichType>(any.richType);

  test('simple', () {
    expect(RichType.fromString('Foo'), equals(RichType('Foo')));
    expect(RichType.fromString('String'), equals(RichType('String')));
    expect(RichType.fromString('int'), equals(RichType('int')));
  });
  Glados<RichType>().test('parsing', (richType) {
    expect(RichType.fromString(richType.toString()), equals(richType));
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
