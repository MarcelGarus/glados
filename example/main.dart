import 'package:glados/glados.dart';
import 'package:test/test.dart';

int max(List<int> input) {
  if (input.isEmpty) return null;
  int max;
  for (var item in input) {
    max ??= item;
    if (item > max) {
      max = item;
    }
  }
  return max;
}

void main() {
  group('maximum', () {
    Glados<List<int>>().test('is in the list', (list) {
      var maximum = max(list);
      if (maximum == null) return;
      expect(list, contains(max(list)));
    });
    Glados<List<int>>().test('is only null if the list is empty', (list) {
      if (max(list) == null) {
        expect(list, isEmpty);
      }
    });
    Glados<List<int>>().test('is >= all items', (list) {
      var maximum = max(list);
      if (maximum != null) {
        for (var item in list) {
          expect(maximum, greaterThanOrEqualTo(item));
        }
      }
    });
    // Glados2(any.lowercaseLetter, any.uppercaseLetter).test('letters', (a, b) {
    //   expect(a.length, greaterThanOrEqualTo(b.length));
    // });
    Glados<User>().test('blub', (user) {});
  });
}

class User {}
