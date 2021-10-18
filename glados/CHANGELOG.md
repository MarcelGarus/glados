## 1.1.1

* Format internal `rich_type.dart` file correctly.
* Update readme to be more contributor-friendly.
* Thanks to @MikkelStorgaard!

## 1.1.0

* Add `Generator.bind`.
* Add `any.oneOf` generator.
* Make `any.either` accept up to ten generators.
* Thanks to @MikkelStorgaard!

## 1.0.3

* Fix typos in the readme file.
* Fix bug in `any.choose`.
* Thanks to @t1ooo!

## 1.0.2

* Update dependencies.
* Thanks to @t1ooo!

## 1.0.1

* Document all generators.
* Add `any.positiveDouble` and `any.negativeDoubleOrZero`.
* Fix off-by-one-errors in `int8`, `int16`, `int32`.

## 1.0.0

* The API is now stable!
* Migrate to null-safety.
* Fix many typos in the readme.
* Fix many typos in this changelog.
* Rename `any.letter` to `any.letters`, `any.uppercaseLetter` to `any.uppercaseLetters`, `any.lowercaseLetter` to `any.lowercaseLetters`, and `any.digit` to `any.digits`.
* Add `any.nonEmptyStringOf`, `any.nonEmptyLetters`, `any.nonEmptyUppercaseLetters`, `any.nonEmptyLowercaseLetters`, and `any.nonEmptyDigits`.
* Remove `any.uint64` because integers are always int64.
* Fixed bug when attempting to generate ints larger than 2^32.
* Directly export 'package:test/test.dart', so that you don't have to do so manually.

## 0.4.0

* Support `async` tests.
* `Explore` is now `ExploreConfig`.
* You can now use all parameters accepted by the standard `test` function (to set timeouts, configure which platform the test runs on, etc.). Glados forwards those parameters.
* Your tests can depend on a `Random`! Just use `testWithRandom`.
* Rename *invariant* to *property* to align with the terminology usually used in property-based testing frameworks.
* Make `PropertyTestNotDeterministic` error more helpful.
* Glados itself is now (partially) tested.

## 0.3.4

* Make pattern images more readable.
* Fix minor errors in the readme.

## 0.3.3

* Add a section about how to find properties.

## 0.3.2

* Fix more analysis warnings.

## 0.3.1

* Fix analysis warnings.

## 0.3.0

* Make the `NoGeneratorFound` error even more helpful by suggesting packages.
* Make the `InvariantNotDeterministic` error more helpful.
* Remove the code generator because higher-level primitives make writing generators just a few lines of code.
* Fix analysis warnings.

## 0.2.2

* Make `NoGeneratorFound` error much more helpful.
* Fix analysis warnings.

## 0.2.1

* Update readme.

## 0.2.0

* Make architecture more flexible: Split arbitraries into `Generator`s and `Shrinkable`s.
* Add generators:
  * Meta generators: `simple`, `always`, `choose`, `either`, `combine2`, `combine3`, `combine4`, `combine5`, `combine6`, `combine7`, `combine8`, `combine9`, `combine10`
  * `int` generators: `intInRange`, `positiveInt`, `positiveIntOrZero`, `negativeInt`, `negativeIntOrZero`, `uint8`, `uint16`, `uint32`, `uint64`, `int8`, `int16`, `int32`, `int64`
  * `double` generators: `doubleInRange`, `positiveDoubleOrZero`, `negativeDouble`
  * `num` generator: `numInRange`
  * `BigInt` generator: `bigIntInRange`
  * `List` generators: `listWithLengthInRange`, `listWithLength`
  * `Set` generators: `setWithLengthInRange`, `setWithLength`, `nonEmptySet`
  * `DateTime` generators: `dateTimeBeforeEpoch`, `dateTimeAfterEpoch`
  * `Duration` generators: `positiveDuration`, `negativeDuration`
  * `String` generators: `letterOrDigit`
* Improve shrinking for `double` generators: They now shrink the decimal digits before their value (e.g., `2.2` is considered less complex than `2.1008`). 
* Improve the code generator:
  * It uses the new meta generators to generate more concise code.
  * It provides a much better error experience.
* Make the readme more concise.
* Make the package more lightweight by moving the sticker image to a separate location and removing the git files.

## 0.1.6

* Add quickstart section to readme.
* Fix errors in the readme.
* Remove several unused files.

## 0.1.5

* Improve readme.
* Fix code generator for classes.
* Fix analysis errors.

## 0.1.4

* Add code generator.
* Add arbitrary: `stringOf`.
* Flesh out the example.
* Fix analysis error.

## 0.1.3

* Move sticker to the top.
* Minor readme improvements.

## 0.1.2

* Improve readme.
* Fix the sticker URL.

## 0.1.1

* Improve readme, including adding a Glados sticker at the top.
* Add arbitraries: `nonEmptyList`, `positiveInt`, `positiveIntOrZero`, `negativeInt`, `negativeIntOrZero`

## 0.1.0

* Redesign API: Syntax is now `Glados<...>().test(...)`. The `any` provides a namespace for all `Arbitrary`s.
* Improve readme and describe customization options.
* Improve console output.
* Add arbitraries: `lowercaseLetter`, `uppercaseLetter`, `letter`, `digit`
* Make errors more helpful by providing a call to action.

## 0.0.4

* Improve readme.
* Add arbitraries: `null`, `bool`, `int`, `double`, `num`, `bigInt`, `dateTime`, `duration`, `set`, `list`, `mapEntry`, `map`
* Improve errors.

## 0.0.3

* Improve readme.
* Improve doc comments.

## 0.0.2

* Add `glados2` and `glados3` for testing with multiple input parameters.
* Improve readme.
* Improve console output.
* Add doc comments.

## 0.0.1

* Initial release.
