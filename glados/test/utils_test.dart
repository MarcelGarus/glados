import 'package:glados/glados.dart';
import 'package:glados/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('RandomUtils', () {
    Glados(any.nonEmptyList(any.int)).testWithRandom(
      'choose returns value from list',
      (list, random) {
        expect(list, contains(random.choose(list)));
      },
    );
    Glados2(any.int, any.positiveInt).testWithRandom(
      'nextIntInRange',
      (min, length, random) {
        final max = min + length;
        final value = random.nextIntInRange(min, max);
        expect(value, greaterThanOrEqualTo(min));
        expect(value, lessThan(min));
      },
    );
  });
  group('succeeds', () {
    test('not throwing', () async {
      expect(await succeeds((_) {}, true), equals(true));
    });
    test('throwing', () async {
      expect(
        await succeeds((_) {
          throw 'blub';
        }, true),
        equals(false),
      );
    });
  });
  group('CamelCasing', () {
    test('all lower', () => expect('abc'.toLowerCamelCase(), 'abc'));
    test('already camel', () => expect('abcDef'.toLowerCamelCase(), 'abcDef'));
    test('upper', () => expect('AbcDef'.toLowerCamelCase(), 'abcDef'));
  });
  group('JoinableStrings', () {
    test('joinLines', () => expect(['a', 'b'].joinLines(), 'a\nb'));
    test('joinParts', () => expect(['a', 'b'].joinParts(), 'a\n\nb'));
  });
}
