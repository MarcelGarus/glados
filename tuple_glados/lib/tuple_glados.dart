import 'package:glados/glados.dart';
import 'package:tuple/tuple.dart';

extension ArbitraryTuples on Any {
  Arbitrary<Tuple2<A, B>> tuple2<A, B>(
    Arbitrary<A> aArbitrary,
    Arbitrary<B> bArbitrary,
  ) =>
      arbitrary(
        generate: (random, size) {
          return Tuple2(
            aArbitrary.generate(random, size),
            bArbitrary.generate(random, size),
          );
        },
        shrink: (tuple) sync* {
          for (final a in aArbitrary.shrink(tuple.item1)) {
            yield Tuple2(a, tuple.item2);
          }
          for (final b in bArbitrary.shrink(tuple.item2)) {
            yield Tuple2(tuple.item1, b);
          }
        },
      );

  Arbitrary<Tuple3<A, B, C>> tuple3<A, B, C>(
    Arbitrary<A> aArbitrary,
    Arbitrary<B> bArbitrary,
    Arbitrary<C> cArbitrary,
  ) =>
      arbitrary(
        generate: (random, size) {
          return Tuple3(
            aArbitrary.generate(random, size),
            bArbitrary.generate(random, size),
            cArbitrary.generate(random, size),
          );
        },
        shrink: (tuple) sync* {
          for (final a in aArbitrary.shrink(tuple.item1)) {
            yield Tuple3(a, tuple.item2, tuple.item3);
          }
          for (final b in bArbitrary.shrink(tuple.item2)) {
            yield Tuple3(tuple.item1, b, tuple.item3);
          }
          for (final c in cArbitrary.shrink(tuple.item3)) {
            yield Tuple3(tuple.item1, tuple.item2, c);
          }
        },
      );

  Arbitrary<Tuple4<A, B, C, D>> tuple4<A, B, C, D>(
    Arbitrary<A> aArbitrary,
    Arbitrary<B> bArbitrary,
    Arbitrary<C> cArbitrary,
    Arbitrary<D> dArbitrary,
  ) =>
      arbitrary(
        generate: (random, size) {
          return Tuple4(
            aArbitrary.generate(random, size),
            bArbitrary.generate(random, size),
            cArbitrary.generate(random, size),
            dArbitrary.generate(random, size),
          );
        },
        shrink: (tuple) sync* {
          for (final a in aArbitrary.shrink(tuple.item1)) {
            yield Tuple4(a, tuple.item2, tuple.item3, tuple.item4);
          }
          for (final b in bArbitrary.shrink(tuple.item2)) {
            yield Tuple4(tuple.item1, b, tuple.item3, tuple.item4);
          }
          for (final c in cArbitrary.shrink(tuple.item3)) {
            yield Tuple4(tuple.item1, tuple.item2, c, tuple.item4);
          }
          for (final d in dArbitrary.shrink(tuple.item4)) {
            yield Tuple4(tuple.item1, tuple.item2, tuple.item3, d);
          }
        },
      );

  Arbitrary<Tuple5<A, B, C, D, E>> tuple5<A, B, C, D, E>(
    Arbitrary<A> aArbitrary,
    Arbitrary<B> bArbitrary,
    Arbitrary<C> cArbitrary,
    Arbitrary<D> dArbitrary,
    Arbitrary<E> eArbitrary,
  ) =>
      arbitrary(
        generate: (random, size) {
          return Tuple5(
            aArbitrary.generate(random, size),
            bArbitrary.generate(random, size),
            cArbitrary.generate(random, size),
            dArbitrary.generate(random, size),
            eArbitrary.generate(random, size),
          );
        },
        shrink: (tuple) sync* {
          for (final a in aArbitrary.shrink(tuple.item1)) {
            yield Tuple5(a, tuple.item2, tuple.item3, tuple.item4, tuple.item5);
          }
          for (final b in bArbitrary.shrink(tuple.item2)) {
            yield Tuple5(tuple.item1, b, tuple.item3, tuple.item4, tuple.item5);
          }
          for (final c in cArbitrary.shrink(tuple.item3)) {
            yield Tuple5(tuple.item1, tuple.item2, c, tuple.item4, tuple.item5);
          }
          for (final d in dArbitrary.shrink(tuple.item4)) {
            yield Tuple5(tuple.item1, tuple.item2, tuple.item3, d, tuple.item5);
          }
          for (final e in eArbitrary.shrink(tuple.item5)) {
            yield Tuple5(tuple.item1, tuple.item2, tuple.item3, tuple.item4, e);
          }
        },
      );

  Arbitrary<Tuple6<A, B, C, D, E, F>> tuple6<A, B, C, D, E, F>(
    Arbitrary<A> aArbitrary,
    Arbitrary<B> bArbitrary,
    Arbitrary<C> cArbitrary,
    Arbitrary<D> dArbitrary,
    Arbitrary<E> eArbitrary,
    Arbitrary<F> fArbitrary,
  ) =>
      arbitrary(
        generate: (random, size) {
          return Tuple6(
            aArbitrary.generate(random, size),
            bArbitrary.generate(random, size),
            cArbitrary.generate(random, size),
            dArbitrary.generate(random, size),
            eArbitrary.generate(random, size),
            fArbitrary.generate(random, size),
          );
        },
        shrink: (tuple) sync* {
          for (final a in aArbitrary.shrink(tuple.item1)) {
            yield Tuple6(a, tuple.item2, tuple.item3, tuple.item4, tuple.item5,
                tuple.item6);
          }
          for (final b in bArbitrary.shrink(tuple.item2)) {
            yield Tuple6(tuple.item1, b, tuple.item3, tuple.item4, tuple.item5,
                tuple.item6);
          }
          for (final c in cArbitrary.shrink(tuple.item3)) {
            yield Tuple6(tuple.item1, tuple.item2, c, tuple.item4, tuple.item5,
                tuple.item6);
          }
          for (final d in dArbitrary.shrink(tuple.item4)) {
            yield Tuple6(tuple.item1, tuple.item2, tuple.item3, d, tuple.item5,
                tuple.item6);
          }
          for (final e in eArbitrary.shrink(tuple.item5)) {
            yield Tuple6(tuple.item1, tuple.item2, tuple.item3, tuple.item4, e,
                tuple.item6);
          }
          for (final f in fArbitrary.shrink(tuple.item6)) {
            yield Tuple6(tuple.item1, tuple.item2, tuple.item3, tuple.item4,
                tuple.item5, f);
          }
        },
      );
  Arbitrary<Tuple7<A, B, C, D, E, F, G>> tuple7<A, B, C, D, E, F, G>(
    Arbitrary<A> aArbitrary,
    Arbitrary<B> bArbitrary,
    Arbitrary<C> cArbitrary,
    Arbitrary<D> dArbitrary,
    Arbitrary<E> eArbitrary,
    Arbitrary<F> fArbitrary,
    Arbitrary<G> gArbitrary,
  ) =>
      arbitrary(
        generate: (random, size) {
          return Tuple7(
            aArbitrary.generate(random, size),
            bArbitrary.generate(random, size),
            cArbitrary.generate(random, size),
            dArbitrary.generate(random, size),
            eArbitrary.generate(random, size),
            fArbitrary.generate(random, size),
            gArbitrary.generate(random, size),
          );
        },
        shrink: (tuple) sync* {
          for (final a in aArbitrary.shrink(tuple.item1)) {
            yield Tuple7(a, tuple.item2, tuple.item3, tuple.item4, tuple.item5,
                tuple.item6, tuple.item7);
          }
          for (final b in bArbitrary.shrink(tuple.item2)) {
            yield Tuple7(tuple.item1, b, tuple.item3, tuple.item4, tuple.item5,
                tuple.item6, tuple.item7);
          }
          for (final c in cArbitrary.shrink(tuple.item3)) {
            yield Tuple7(tuple.item1, tuple.item2, c, tuple.item4, tuple.item5,
                tuple.item6, tuple.item7);
          }
          for (final d in dArbitrary.shrink(tuple.item4)) {
            yield Tuple7(tuple.item1, tuple.item2, tuple.item3, d, tuple.item5,
                tuple.item6, tuple.item7);
          }
          for (final e in eArbitrary.shrink(tuple.item5)) {
            yield Tuple7(tuple.item1, tuple.item2, tuple.item3, tuple.item4, e,
                tuple.item6, tuple.item7);
          }
          for (final f in fArbitrary.shrink(tuple.item6)) {
            yield Tuple7(tuple.item1, tuple.item2, tuple.item3, tuple.item4,
                tuple.item5, f, tuple.item7);
          }
          for (final g in gArbitrary.shrink(tuple.item7)) {
            yield Tuple7(tuple.item1, tuple.item2, tuple.item3, tuple.item4,
                tuple.item5, tuple.item6, g);
          }
        },
      );
}
