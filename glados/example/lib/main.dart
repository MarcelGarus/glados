import 'package:glados/glados.dart';
import 'package:test/test.dart';

// part 'main.g.dart';

int? max(List<int> input) {
  if (input.isEmpty) return null;
  int? max;
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
    Glados<List<int>>(null, ExploreConfig(initialSize: 1, random: Random(3)))
        .test('...', (list) {
      print('Testing for list $list.');
      assert(list.where((it) => it < 0).length >
          list.where((it) => it >= 0).length);
    });

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
