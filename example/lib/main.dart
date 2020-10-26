import 'package:glados/glados.dart';
import 'package:glados/src/annotations.dart';
import 'package:test/test.dart';

part 'main.g.dart';

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
    Glados<List<int>>().test('is only null if the list is empty', (list) {
      if (max(list) == null) {
        expect(list, isEmpty);
      }
    });
    Glados(any.nonEmptyList(any.int)).test('is in the list', (list) {
      expect(list, contains(max(list)));
    });
    Glados(any.nonEmptyList(any.int)).test('is >= all items', (list) {
      var maximum = max(list);
      for (var item in list) {
        expect(maximum, greaterThanOrEqualTo(item));
      }
    });
  });
}

@GenerateArbitrary()
class User {
  User(this.email, this.password, {this.age});

  final String email;
  final String password;
  final int age;
}

@GenerateArbitrary()
enum Ripeness {
  ripe,
  medium,
  unripe,
}

extension ArbitraryRipeness on Any {
  Arbitrary<Ripeness> get ripeness => arbitrary(
        generate: (random, size) {
          return [
            Ripeness.ripe,
            Ripeness.medium,
            Ripeness.unripe
          ][random.nextInt(3)];
        },
        shrink: (_) => [],
      );
}
