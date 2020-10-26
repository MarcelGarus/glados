// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// ArbitraryGenerator
// **************************************************************************

extension ArbitraryRipeness on Any {
  Arbitrary<Ripeness> get ripeness => arbitrary(
        generate: (random, size) {
          return Ripeness.values[random.nextInt(
            size.clamp(0, Ripeness.values.length - 1),
          )];
        },
        shrink: (ripeness) sync* {
          if (ripeness.index > 0) {
            yield Ripeness.values[ripeness.index - 1];
          }
        },
      );
}

extension ArbitraryUser on Any {
  Arbitrary<User> user(
    Arbitrary<String> emailArbitrary,
    Arbitrary<String> passwordArbitrary,
    Arbitrary<int> ageArbitrary,
  ) =>
      arbitrary(
        generate: (random, size) {
          return User(
            emailArbitrary.generate(random, size),
            passwordArbitrary.generate(random, size),
            age: ageArbitrary.generate(random, size),
          );
        },
        shrink: (user) sync* {
          for (final email in emailArbitrary.shrink(user.email)) {
            yield User(
              email,
              user.password,
              age: user.age,
            );
          }
          for (final password in passwordArbitrary.shrink(user.password)) {
            yield User(
              user.email,
              password,
              age: user.age,
            );
          }
          for (final age in ageArbitrary.shrink(user.age)) {
            yield User(
              user.email,
              user.password,
              age: age,
            );
          }
        },
      );
}
