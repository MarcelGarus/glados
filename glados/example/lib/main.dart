import 'package:glados/glados.dart';
import 'package:test/test.dart';

// part 'main.g.dart';

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
    Glados<List<List<int>>>().test('is >= all items', (list) {
      // var maximum = max(list);
      // for (var item in list) {
      //   expect(maximum, greaterThanOrEqualTo(item));
      // }
    });
  });
}

@glados
class User {
  User.blub(
    this.email,
    this.password, {
    this.age,
    this.foo,
    this.bar,
    this.baz,
    this.blubbel,
    this.schub,
    this.shooze,
    this.whooze,
    this.zoooooome,
  });

  final String email;
  final String password;
  final int age;
  final Duration foo;
  final double bar;
  final DateTime baz;
  final BigInt blubbel;
  final int schub;
  final int shooze;
  final bool whooze;
  final bool zoooooome;

  int get doubleAge => age * 2;
}

@glados
enum Ripeness {
  ripe,
  medium,
  unripe,
}
