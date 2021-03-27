import 'package:glados/glados.dart';
import 'package:tuple/tuple.dart';

extension GeneratorTuples on Any {
  Generator<Tuple2<A, B>> tuple2<A, B>(Generator<A> a, Generator<B> b) {
    return combine2(a, b, (A a, B b) => Tuple2(a, b));
  }

  Generator<Tuple3<A, B, C>> tuple3<A, B, C>(
    Generator<A> a,
    Generator<B> b,
    Generator<C> c,
  ) {
    return combine3(a, b, c, (A a, B b, C c) => Tuple3(a, b, c));
  }

  Generator<Tuple4<A, B, C, D>> tuple4<A, B, C, D>(
    Generator<A> a,
    Generator<B> b,
    Generator<C> c,
    Generator<D> d,
  ) {
    return combine4(a, b, c, d, (A a, B b, C c, D d) => Tuple4(a, b, c, d));
  }

  Generator<Tuple5<A, B, C, D, E>> tuple5<A, B, C, D, E>(
    Generator<A> a,
    Generator<B> b,
    Generator<C> c,
    Generator<D> d,
    Generator<E> e,
  ) {
    return combine5(
      a,
      b,
      c,
      d,
      e,
      (A a, B b, C c, D d, E e) => Tuple5(a, b, c, d, e),
    );
  }

  Generator<Tuple6<A, B, C, D, E, F>> tuple6<A, B, C, D, E, F>(
    Generator<A> a,
    Generator<B> b,
    Generator<C> c,
    Generator<D> d,
    Generator<E> e,
    Generator<F> f,
  ) {
    return combine6(
      a,
      b,
      c,
      d,
      e,
      f,
      (A a, B b, C c, D d, E e, F f) => Tuple6(a, b, c, d, e, f),
    );
  }

  Generator<Tuple7<A, B, C, D, E, F, G>> tuple7<A, B, C, D, E, F, G>(
    Generator<A> a,
    Generator<B> b,
    Generator<C> c,
    Generator<D> d,
    Generator<E> e,
    Generator<F> f,
    Generator<G> g,
  ) {
    return combine7(
      a,
      b,
      c,
      d,
      e,
      f,
      g,
      (A a, B b, C c, D d, E e, F f, G g) => Tuple7(a, b, c, d, e, f, g),
    );
  }
}
