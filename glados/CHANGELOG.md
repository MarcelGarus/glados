## 0.2.0

- Make architecture more flexible: Split arbitraries into `Generator`s and `Shrinkable`s.
- Add generators:
  - Meta generators: `simple`, `always`, `choose`, `either`, `combine2`, `combine3`, `combine4`, `combine5`, `combine6`, `combine7`, `combine8`, `combine9`, `combine10`
  - `int` generators: `intInRange`, `positiveInt`, `positiveIntOrZero`, `negativeInt`, `negativeIntOrZero`, `uint8`, `uint16`, `uint32`, `uint64`, `int8`, `int16`, `int32`, `int64`
  - `double` generators: `doubleInRange`, `positiveDoubleOrZero`, `negativeDouble`
  - `num` generator: `numInRange`
  - `BigInt` generator: `bigIntInRange`
  - `List` generators: `listWithLengthInRange`, `listWithLength`
  - `Set` generators: `setWithLengthInRange`, `setWithLength`, `nonEmptySet`
  - `DateTime` generators: `dateTimeBeforeEpoch`, `dateTimeAfterEpoch`
  - `Duration` generators: `positiveDuration`, `negativeDuration`
  - `String` generators: `letterOrDigit`
- Improve shrinking for `double` generators: The decimal digits of values are now shrunk too (e.g. `2.2` is considered less complex than `2.1008`). 
- Improve the code generator:
  - It uses the new meta generators to generate more concise code.
  - It provides a much better error experience.
- Make readme more concisee.
- Make package more lightweight by moving sticker image to a separate location and removing git files.

## 0.1.6

- Add quickstart section to readme.
- Fix errors in readme.
- Remove several unused files.

## 0.1.5

- Improve readme.
- Fix code generator for classes.
- Fix analysis errors.

## 0.1.4

- Add code generator.
- Add arbitrary: `stringOf`
- Flesh out example.
- Fix analysis error.

## 0.1.3

- Move sticker to the top.
- Minor readme improvements.

## 0.1.2

- Improve readme.
- Fix the sticker URL.

## 0.1.1

- Improve readme. This includes adding a Glados sticker at the top.
- Add arbitraries: `nonEmptyList`, `positiveInt`, `positiveIntOrZero`, `negativeInt`, `negativeIntOrZero`

## 0.1.0

- Redesign API: Syntax is now `Glados<...>().test(...)`. The `any` provides a namespace for all `Arbitrary`s.
- Improve readme and describe customization options.
- Improve console output.
- Add arbitraries: `lowercaseLetter`, `uppercaseLetter`, `letter`, `digit`
- Make errors more helpful by providing call to actions.

## 0.0.4

- Improve readme.
- Add arbitraries: `null`, `bool`, `int`, `double`, `num`, `bigInt`, `dateTime`, `duration`, `set`, `list`, `mapEntry`, `map`
- Improve errors.

## 0.0.3

- Improve readme.
- Improve doc comments.

## 0.0.2

- Add `glados2` and `glados3` for testing with multiple input parameters.
- Improve readme.
- Improve console output.
- Add doc comments.

## 0.0.1

- Initial release.
