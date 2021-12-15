import 'package:glados/glados.dart';

void main() {
  group('Anys', () {
    Glados(any.null_).test('null', (it) => expect(it, equals(null)));
    group('IntAnys', () {
      Glados3(any.int, any.int, any.int).testWithRandom(
        'intInRange',
        (size, min, max, random) {
          if (min >= max) {
            expect(
              () => any.intInRange(min, max)(random, size),
              throwsA(anything),
            );
            return;
          }
          final generated = any.intInRange(min, max)(random, size).value;
          expect(generated, greaterThanOrEqualTo(min));
          expect(generated, lessThan(max));
        },
      );
      Glados(any.positiveIntOrZero).testWithRandom('int', (size, random) {
        final generated = any.int(random, size).value;
        expect(generated, greaterThanOrEqualTo(-size));
        expect(generated, lessThanOrEqualTo(size));
      });
      Glados(any.positiveInt).test('positiveInt', (number) {
        expect(number, greaterThan(0));
      });
      Glados(any.positiveIntOrZero).test('positiveIntOrZero', (number) {
        expect(number, greaterThanOrEqualTo(0));
      });
      Glados(any.negativeInt).test('negativeInt', (number) {
        expect(number, lessThan(0));
      });
      Glados(any.negativeIntOrZero).test('negativeIntOrZero', (number) {
        expect(number, lessThanOrEqualTo(0));
      });
      Glados(any.uint8).test('uint8', (number) {
        expect(number, greaterThanOrEqualTo(0));
        expect(number, lessThan(2 << 8));
      });
      Glados(any.uint16).test('uint16', (number) {
        expect(number, greaterThanOrEqualTo(0));
        expect(number, lessThan(2 << 16));
      });
      Glados(any.uint32).test('uint32', (number) {
        expect(number, greaterThanOrEqualTo(0));
        expect(number, lessThan(2 << 32));
      });
    });
    group('ListAnys', () {
      Glados(any.listWithLengthInRange(null, null, any.always(42)))
          .test('listWithLengthInRange(null, null, ...)', (list) {
        expect(list, everyElement(equals(42)));
      });
      Glados(any.listWithLengthInRange(5, 10, any.bigInt))
          .test('listWithLengthInRange(5, 10, ...)', (list) {
        expect(list.length, greaterThanOrEqualTo(5));
        expect(list.length, lessThan(10));
      });
    });
    group('SetAnys', () {
      // ignore: deprecated_member_use_from_same_package
      Glados(any.setWithLengthInRange(null, null, any.always(42)))
          .test('setWithLengthInRange(null, null, ...)', (set) {
        if (set.isNotEmpty) {
          expect(set, equals({42}));
        }
      });
      // ignore: deprecated_member_use_from_same_package
      Glados(any.setWithLengthInRange(5, 10, any.bigInt))
          .test('setWithLengthInRange(5, 10, ...)', (set) {
        expect(set.length, lessThan(10));
      });
    });
  });
}
