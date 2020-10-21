Testing is tedious!
At least that's what I thought before I stumbled over property-based testing – a simple approach that allows you to write less tests yet gain more confidence in your code.

Instead of defining concrete inputs and testing whether they result in the desired output, you define certain conditions that are always true (also called *invariants*).
In mathematics, there's the ∀ operator for that. In Dart, there's `glados`.

```yml
dev_dependencies:
  test: ...
  glados: ...
```

## Getting started

Suppose you write a function that tries to find the maximum in a list.
I know – that's pretty basic – but it's enough to get you started.
Here's an obviously wrong implementation:

```dart
/// If the list is empty, return null, otherwise the biggest item.
int max(List<int> input) => null;
```

To be sure that the function does the right thing, you might want to write some tests.
Here's how those would look like in traditional unit testing:

```dart
test('maximum of empty list', () {
  expect(max([]), equals(null));
});
test('maximum of non-empty list', () {
  expect(max([40, 2, 10]), equals(40));
});
```

> If you're not familiar with the syntax of the [`test`](https://pub.dev/packages/test) package, you should read [their documentation](https://pub.dev/packages/test) first.

Executing `pub run test path/to/tests.dart` should show that the second test fails.

In property-based testing, you look for invariants – conditions that should be true for any input.
For example, if `max` produces `null`, the list should be empty:

```dart
glados<List<int>>('maximum is only null if the list is empty', (list) {
  if (max(list) == null) {
    expect(list, isEmpty);
  }
});
```

You can use the `glados` function whereever you would use the `test` function.
`glados` then tests your code with a variety of inputs and all of them need to succeed.
The `glados` function also takes a generic type parameter describing which values to generate – in this case, `List<int>`.

Running the test should produce something like this:

```txt
Tested 1 inputs, shrunk 25 times.
Failing for input: [0]
...
```

`glados` discovered that the a list containing `0` breaks the condition!

Let's modify our `max` function to pass this test:

```dart
int max(List<int> input) => 42;
```

We need to add another invariant to reject this function as well.
Arguably the most obvious invariant for `max` is that the result should be greater than or equal to all items of the list:

```dart
glados<List<int>>('maximum is >= all items', (list) {
  var maximum = max(list);
  if (maximum != null) {
    for (var item in list) {
      expect(maximum, greaterThanOrEqualTo(item));
    }
  }
});
```

Running the tests produces the following result:

```txt
Tested 35 inputs, shrunk 117 times.
Failing for input: [43]
...
```

`glados` detected that the invariant breaks if the input is a list containing only `43`.

Let's actually add a more reasonable implementation for `max`:

```dart
int max(List<int> input) {
  if (input.isEmpty) {
    return null;
  }
  var max = 0;
  for (var item in input) {
    if (item > max) {
      max = item;
    }
  }
  return max;
}
```

This fixes the tests, but still doesn't work for lists containing only negative values.
So, let's add a final test:

```dart
glados<List<int>>('maximum is in the list', (list) {
  var maximum = max(list);
  if (maxmium != null) {
    expect(list, contains(maximum));
  }
});
```

I'll leave implementing the function correctly to you, the reader.

But whatever solution you come up with, it'll be correct:
Our tests aren't merely some arbitrary examples that we came up with anymore.
Rather, they correspond to the **actual mathematical definition of max**.

## How does it work?

`glados` works in two phases:

- **The exploration phase**: `glados` generates increasingly complex, random inputs until one breaks the invariant or the maximum number of tries is reached.
- **The shrinking phase**: This phase only happens if `glados` found an input that breaks the invariant. In this case, the input is gradually simplified and the smallest input that's still breaking the invariant is returned.

Both phases internally use the `Arbitrary<T>` class, which has two methods:

- `T generate(Random random, int size)` generates a new value of type `T`, using the `random` generator for random values. The `size` argument should be used as a rough estimate on how big or complex the returned value should be. For example, for a given size *n*, the `intArbitrary` produces `int`s from *-n* to *n*.
- `Iterable<T> shrink(T input)` takes a value and returns an `Iterable` containing similar, but smaller values. Smaller means that calling `shrink` repeatedly on the smaller values and their children etc., the program should eventually terminate (aka the transitive hull with regard to `shrink` should be finite).

`glados` looks for a fitting arbitrary in the global variable `gladosArbitraries` and then uses that to generate and shrink values.

## Creating a custom Arbitrary

The basic types all have corresponding `Arbitrary`s implemented. If you want to use a custom type, you need to create a custom arbitrary and register it:

```dart
// Assuming User consists of name (String) and age (int).
class UserArbitrary extends Arbitrary<User> {
  UserArbitrary(this.nameArbitrary, this.ageArbitray);
  
  final Arbitrary<String> nameArbitrary;
  final Arbitrary<int> ageArbitrary;

  @override
  List<T> generate(Random random, int size) {
    return User(
      name: nameArbitrary.generate(random, size),
      age: ageArbitrary.generate(random, size),
    );
  }

  @override
  Iterable<List<T>> shrink(List<T> value) sync* {
    yield User(
      name: nameArbitrary.shrink(value.name),
      age: value.age,
    );
    yield User(
      name: value.name,
      age: ageArbitrary.shrink(value.age),
    );
  }
}

final userArbitrary = UserArbitrary(stringArbitrary, intArbitrary);

// in the main method
gladosArbitraries.add(userArbitrary);
```

It's best practice to make arbitraries that are internally used in another arbitrary configurable so that you can customize them if needed.

## What's up with the name?

GLaDOS is a very nice robot in the Portal game series.
She's the head of the Aperture Science Laboratory facilities, where she spends the rest of her days testing.
So I thought that's quite a fitting name. 🍰

## Further info

- [Here's the talk](https://www.youtube.com/watch?v=IYzDFHx6QPY) that got me into property-based testing.
- [This article](https://begriffs.com/posts/2017-01-14-design-use-quickcheck.html) covers the topic in more detail.
