|                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |                                                                                   |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| <p>Testing is tedious! At least that's what I thought before I stumbled over **property-based testing** – a simple approach that allows you to write fewer tests yet gain more confidence in your code.</p><p>In traditional testing, you define concrete inputs and test whether they result in the desired output. In property based testing, you define certain conditions that are always true for any input (those are also called *invariants*). In mathematics, there's the ∀ operator for that. In Dart, now there's Glados.</p> | <img src="https://raw.githubusercontent.com/marcelgarus/glados/main/glados.webp"> |

Here are some benefits:

- ⚡ **You have to write fewer tests.** Remember the old days when you had to come up with concrete values? With Glados, just write a few invariants and let Glados take care of figuring out the inputs that break them.
- 🌌 **You test for all possible inputs.** Well, not literally all. But Glados takes care of testing your invariants with a huge variety of inputs. Feel more confident in your code!
- 🐜 **You get a minimal error inducing input.** After Glados found an input that breaks your invariant, it doesn't just stop. Rather, it tries to simplify the input to give you the most condensed error report possible.
- 🤯 **You develop a better understanding for the problem domain** because you have to think of invariants.
- 🎲 **Don't worry: The tests are reproducible.** Glados uses a pseudo-random generator that's always created with the same seed. Running a test again tests your invariant with the same inputs as before.

```yml
dev_dependencies:
  test: ...
  glados: ...
```

<details>
<summary>Table of Contents</summary>

- [Getting started](#getting-started)
- [How does it work?](#how-does-it-work)
- [Advanced Glados testing](#advanced-glados-testing)
  - [Multiple inputs](#multiple-inputs)
  - [Using custom arbitraries](#using-custom-arbitraries)
  - [Generating custom arbitraries](#generating-custom-arbitraries)
  - [Creating custom arbitraries manually](#creating-custom-arbitraries-manually)
  - [Explore](#explore)
- [What's up with the name?](#whats-up-with-the-name)
- [Further info & resources](#further-info--resources)

</details>

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

> Not familiar with the syntax of the [`test`](https://pub.dev/packages/test) package? [Here are the docs](https://pub.dev/packages/test).

Executing `pub run test path/to/tests.dart` should show that the second test fails.

In property-based testing, you look for invariants – conditions that should be true for any input.
For example, if `max` produces `null`, the list should be empty:

```dart
Glados<List<int>>().test('maximum is only null if the list is empty', (list) {
  if (max(list) == null) {
    expect(list, isEmpty);
  }
});
```

Just create a `Glados` instance and call its `test` method instead of using the normal `test` function.
`Glados` takes a generic type parameter – in this case, `List<int>`.
It then tests your code with a variety of inputs of that type.
All of them need to succeed for the whole test to succeed.

Running the test should produce something like this:

```txt
Tested 1 input, shrunk 25 times.
Failing for input: [0]
...
```

Glados discovered that a list with some content breaks the condition!

Let's modify our `max` function to pass this test:

```dart
int max(List<int> input) => 42;
```

We need to add another invariant to reject this function as well.
Arguably the most obvious invariant for `max` is the following: The maximum should be greater than or equal to all items of the list:

```dart
Glados(any.nonEmptyList(any.int)).test('maximum is >= all items', (list) {
  var maximum = max(list);
  for (var item in list) {
    expect(maximum, greaterThanOrEqualTo(item));
  }
});
```

Instead of defining type parameters, you can also pass in *arbitraries* to Glados to customize which values are generated.
You can find all available arbitraries as fields on the `any` value.
In this case, we only test with non-empty lists because we handled the empty list in the first test.

Running the tests produces the following result:

```txt
Tested 35 inputs, shrunk 117 times.
Failing for input: [43]
...
```

Glados detected that the invariant breaks if the input list contains a `43`.

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
Glados(any.nonEmptyList(any.int)).test('maximum is in the list', (list) {
  expect(list, contains(max(list)));
});
```

I'll leave implementing the function correctly to you, the reader.

But whatever solution you come up with, it'll be correct:
Our tests aren't merely some arbitrary examples anymore.
Rather, they correspond to the **actual mathematical definition of max**.

## How does it work?

Glados works in two phases:

- 🌍 **The exploration phase**: Glados generates increasingly complex, random inputs until one breaks the invariant or the maximum number of runs is reached.
- 🐜 **The shrinking phase**: This phase only happens if Glados found an input that breaks the invariant. In this case, the input is gradually simplified and the smallest input that's still breaking the invariant is returned.

## Advanced Glados testing

### Multiple inputs

You can use `Glados2` and `Glados3` for Glados tests with multiple inputs.
If you need support for more inputs, don't hestitate to [open an issue](https://github.com/marcelgarus/glados/issues/new).

```dart
Glados2<int, int>().test('complicated stuff', (a, b) {
  ...
})
```

### Using custom arbitraries

Arbitraries are responsible for generating and shrinking values. The `Arbitrary` class has two methods:

- `T generate(Random random, int size)` generates a new value of type `T`, using `random` as a source for randomness. The `size` argument is used as a rough estimate on how big or complex the returned value should be.  
  For example, the arabitrary for `int` produces `int`s in the range from `-size` to `size`.
- `Iterable<T> shrink(T input)` takes a value and returns an `Iterable` containing similar, but smaller values. Smaller means that calling `shrink` repeatedly on the smaller values and their children etc., the program should eventually terminate (aka the transitive hull with regard to `shrink` should be finite and acyclic).


The basic types all have corresponding arbitraries implemented. More arbitraries can be found on `any`.

For example, if you want to test some code only with lowercase letters, you can write:

```dart
Glados(any.lowercaseLetters).test('text test', (text) { ... });
```

### Generating custom arbitraries

You can let Glados generate arbitraries for your types by annotating them with `@GenerateArbitrary` and then running `pub run build_runner build`.
This works for both data classes and enums.

### Creating custom arbitraries manually

Sometimes it makes sense to write new arbitraries.

For example, if you test code that expects email addresses, it may be inefficient to test the code with random `String`s; if the tested code contains some sanity checks at the beginning, only a tiny fraction of values actually passes through the rest of the code.

In that case, create a custom arbitrary.
To do that, add an extension on `Any`, which is a namespace for arbitraries:

```dart
extension EmailAdressArbitrary on Any {
  Arbitrary<String> get emailAddress => arbitrary(
    generate: (random, size) => /* code for generating email addresses */,
    shrink: (emailAddress) => /* code for shrinking the given email address */,
  );
}
```

Then, you can use that arbitrary like this:

```dart
Glados(any.emailAddress).test('email test', (emailAddress) { ... });
```

You can also set an arbitrary as the default arbitrary for a type:

```dart
// Use the email arbitrary for all Strings.
Any.setDefault<String>(any.emailAddress);
```

Then, you don't need to explicitly provide the arbitrary to `Glados` anymore. Instead, `Glados` will use it based on given type parameters:

```dart
// This will now use the any.emailAddress arbitrary, because it was set as the
// default for String before.
Glados<String>().test('blub', () { ... });
```

<!--
TODO: package ecosystem arbitrary support
-->

### Explore

You can also customize the exploration phase.
To do that, you can use `Explore`, which is a configuration for certain values used during that phase.

For example, if you want to test some code with very big inputs, you might adjust `Explore`'s parameters so that Glados starts with very big inputs and generates much bigger inputs after just a few runs:

```dart
Glados(any.email, Explore(
  initialSize: 100, // Start quite big
  speed: 10,        // and increase the input size by 10 each run,
  numRuns: 10,      // but only do 10 runs instead of 100.
)).test('my test', (input) {
  ...
});
```

`Explore` also has a `random` parameter, which you can provide with a custom `Random` instance.
By default, `Explore` uses a `Random` instance created with a fixed seed so that your tests are deterministic.

## What's up with the name?

GLaDOS is a very nice robot in the Portal game series. She's the head of the Aperture Science Laboratory facilities, where she spends the rest of her days testing. So I thought that's quite a fitting name. 🥔

By the way, both Portal games are great. If you haven't played them, definitely [check them out](https://store.steampowered.com/app/400/Portal/).

## Further info & resources

- Special thanks to [@batteredgherkin](https://github.com/batteredgherkin) for the Glados sticker.
- [Here's the talk](https://www.youtube.com/watch?v=IYzDFHx6QPY) that got me into property-based testing.
- [This article](https://begriffs.com/posts/2017-01-14-design-use-quickcheck.html) covers the topic in more detail.

🍰
