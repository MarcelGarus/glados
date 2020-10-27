// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// ArbitraryGenerator
// **************************************************************************

extension AnyRipeness on Any {
  Generator<Ripeness> get ripeness => choose(Ripeness.values);
}

extension AnyUser on Any {
  Generator<User> user(
    Generator<String> emailGenerator,
    Generator<String> passwordGenerator,
    Generator<int> ageGenerator,
  ) =>
      combine3(
        emailGenerator,
        passwordGenerator,
        ageGenerator,
        (email, password, age) {
          return User(
            email,
            password,
            age: age,
          );
        },
      );
}
