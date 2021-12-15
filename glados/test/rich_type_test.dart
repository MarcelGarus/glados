import 'package:glados/glados.dart';
import 'package:glados/src/rich_type.dart';

extension AnyRichType on Any {
  Generator<RichType> get richType {
    return (random, size) {
      return ShrinkableRichType(
        nonEmptyLetters(random, size),
        // This getter doesn't return itself, but a lambda which – if invoked –
        // non-deterministically runs the getter again.
        // ignore: recursive_getters
        any.list(richType)(random, size ~/ 2),
      );
    };
  }
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

  @override
  String toString() => 'ShrinkableRichType($value)';
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
    expect(() => RichType.fromString('Bar<'), throwsFormatException);
    expect(() => RichType.fromString('Bar<Foo'), throwsFormatException);
    expect(() => RichType.fromString('Bar<Foo>>'), throwsFormatException);
  });
}
