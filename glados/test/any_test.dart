import 'package:glados/glados.dart';
import 'package:test/test.dart';

void main() {
  group('AnyUtils', () {
    group('choose', () {
      const size = 10;

      test('empty list', () {
        final list = [];
        final generator = any.choose(list);
        expect(() => generator(Random(), size), throwsArgumentError);
      });

      test('one element list', () {
        final list = [42];
        final generator = any.choose(list);
        final element = generator(Random(), size);
        expect(element.value, list[0]);
      });

      test('multiple element list', () {
        final list = [0, 1, 2];
        final generator = any.choose(list);
        final element = generator(Random(), size);
        expect(list.contains(element.value), true);
      });
    });
  });
}
