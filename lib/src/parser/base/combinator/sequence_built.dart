import "package:parser_typed/parser.dart";

class SequenceBase extends CombinatorParser<List<Object?>, Object?> {
  @override
  final List<Parser<Object?>> children;

  SequenceBase(this.children);
  SequenceBase.empty() : children = <Parser>[];

  @override
  Context<List<Object?>> parseOn(Context<void> context, ParseHandler handler) {
    List<Object?> results = <Object?>[];

    Context<void> ctx = context;
    for (int i = 0; i < childrenLength; i++) {
      Context<Object?> inner = handler.parse(children[i], ctx);
      if (inner.isFailure) {
        return inner.failure();
      }

      results.add(inner.value);
      ctx = inner;
    }

    return ctx.success(results);
  }

  @override
  int recognizeOn(String input, int index, ParseHandler handler) {
    int position = index;
    for (int i = 0; i < childrenLength; i++) {
      position = handler.recognize(children[i], input, position);
      if (position < 0) {
        break;
      }
    }
    return position;
  }

  @override
  SequenceBase get empty => SequenceBase.empty();
}

class Sequence1<T1> extends SequenceBase {
  Sequence1(Parser<T1> parser1) : super(<Parser>[parser1]);
  Parser<R> map<R, RT1 extends T1>(R Function(RT1 value1) mapper) => //
      MapParser(this, (List<Object?> value) => mapper(value[0] as RT1));

  Sequence2<T1, Object?> operator &(Parser<Object?> parser2) =>
      Sequence2<T1, Object?>(children[0] as Parser<T1>, parser2);
}

class Sequence2<T1, T2> extends SequenceBase {
  Sequence2(Parser<T1> parser1, Parser<T2> parser2) : super(<Parser<Object?>>[parser1, parser2]);
  Parser<R> map<R, RT1 extends T1, RT2 extends T2>(R Function(RT1 value1, RT2 value2) mapper) =>
      MapParser(this, (List<Object?> value) => mapper(value[0] as RT1, value[1] as RT2));

  Sequence3<T1, T2, Object?> operator &(Parser<Object?> parser3) =>
      Sequence3<T1, T2, Object?>(children[0] as Parser<T1>, children[1] as Parser<T2>, parser3);
}

class Sequence3<T1, T2, T3> extends SequenceBase {
  Sequence3(Parser<T1> parser1, Parser<T2> parser2, Parser<T3> parser3)
      : super(<Parser<Object?>>[parser1, parser2, parser3]);
  Parser<R> map<R, RT1 extends T1, RT2 extends T2, RT3 extends T3>(
          R Function(RT1 value1, RT2 value2, RT3 value3) mapper) =>
      MapParser(this, (List<Object?> value) => mapper(value[0] as RT1, value[1] as RT2, value[2] as RT3));

  Sequence4<T1, T2, T3, Object?> operator &(Parser<Object?> parser4) => Sequence4<T1, T2, T3, Object?>(
      children[0] as Parser<T1>, children[1] as Parser<T2>, children[2] as Parser<T3>, parser4);
}

class Sequence4<T1, T2, T3, T4> extends SequenceBase {
  Sequence4(Parser<T1> parser1, Parser<T2> parser2, Parser<T3> parser3, Parser<T4> parser4)
      : super(<Parser<Object?>>[parser1, parser2, parser3, parser4]);
  Parser<R> map<R, RT1 extends T1, RT2 extends T2, RT3 extends T3, RT4 extends T4>(
          R Function(RT1 value1, RT2 value2, RT3 value3, RT4 value4) mapper) =>
      MapParser(
          this, (List<Object?> value) => mapper(value[0] as RT1, value[1] as RT2, value[2] as RT3, value[3] as RT4));

  Sequence5<T1, T2, T3, T4, Object?> operator &(Parser<Object?> parser5) => Sequence5<T1, T2, T3, T4, Object?>(
      children[0] as Parser<T1>,
      children[1] as Parser<T2>,
      children[2] as Parser<T3>,
      children[3] as Parser<T4>,
      parser5);
}

class Sequence5<T1, T2, T3, T4, T5> extends SequenceBase {
  Sequence5(Parser<T1> parser1, Parser<T2> parser2, Parser<T3> parser3, Parser<T4> parser4, Parser<T5> parser5)
      : super(<Parser<Object?>>[parser1, parser2, parser3, parser4, parser5]);
  Parser<R> map<R, RT1 extends T1, RT2 extends T2, RT3 extends T3, RT4 extends T4, RT5 extends T5>(
          R Function(RT1 value1, RT2 value2, RT3 value3, RT4 value4, RT5 value5) mapper) =>
      MapParser(
          this,
          (List<Object?> value) =>
              mapper(value[0] as RT1, value[1] as RT2, value[2] as RT3, value[3] as RT4, value[4] as RT5));

  Sequence6<T1, T2, T3, T4, T5, Object?> operator &(Parser<Object?> parser6) => Sequence6<T1, T2, T3, T4, T5, Object?>(
      children[0] as Parser<T1>,
      children[1] as Parser<T2>,
      children[2] as Parser<T3>,
      children[3] as Parser<T4>,
      children[4] as Parser<T5>,
      parser6);
}

class Sequence6<T1, T2, T3, T4, T5, T6> extends SequenceBase {
  Sequence6(Parser<T1> parser1, Parser<T2> parser2, Parser<T3> parser3, Parser<T4> parser4, Parser<T5> parser5,
      Parser<T6> parser6)
      : super(<Parser<Object?>>[parser1, parser2, parser3, parser4, parser5, parser6]);
  Parser<R> map<R, RT1 extends T1, RT2 extends T2, RT3 extends T3, RT4 extends T4, RT5 extends T5, RT6 extends T6>(
          R Function(RT1 value1, RT2 value2, RT3 value3, RT4 value4, RT5 value5, RT6 value6) mapper) =>
      MapParser(
          this,
          (List<Object?> value) => mapper(
              value[0] as RT1, value[1] as RT2, value[2] as RT3, value[3] as RT4, value[4] as RT5, value[5] as RT6));

  Sequence7<T1, T2, T3, T4, T5, T6, Object?> operator &(Parser<Object?> parser7) =>
      Sequence7<T1, T2, T3, T4, T5, T6, Object?>(
          children[0] as Parser<T1>,
          children[1] as Parser<T2>,
          children[2] as Parser<T3>,
          children[3] as Parser<T4>,
          children[4] as Parser<T5>,
          children[5] as Parser<T6>,
          parser7);
}

class Sequence7<T1, T2, T3, T4, T5, T6, T7> extends SequenceBase {
  Sequence7(Parser<T1> parser1, Parser<T2> parser2, Parser<T3> parser3, Parser<T4> parser4, Parser<T5> parser5,
      Parser<T6> parser6, Parser<T7> parser7)
      : super(<Parser<Object?>>[parser1, parser2, parser3, parser4, parser5, parser6, parser7]);
  Parser<R> map<R, RT1 extends T1, RT2 extends T2, RT3 extends T3, RT4 extends T4, RT5 extends T5, RT6 extends T6,
              RT7 extends T7>(
          R Function(RT1 value1, RT2 value2, RT3 value3, RT4 value4, RT5 value5, RT6 value6, RT7 value7) mapper) =>
      MapParser(
          this,
          (List<Object?> value) => mapper(value[0] as RT1, value[1] as RT2, value[2] as RT3, value[3] as RT4,
              value[4] as RT5, value[5] as RT6, value[6] as RT7));

  Sequence8<T1, T2, T3, T4, T5, T6, T7, Object?> operator &(Parser<Object?> parser8) =>
      Sequence8<T1, T2, T3, T4, T5, T6, T7, Object?>(
          children[0] as Parser<T1>,
          children[1] as Parser<T2>,
          children[2] as Parser<T3>,
          children[3] as Parser<T4>,
          children[4] as Parser<T5>,
          children[5] as Parser<T6>,
          children[6] as Parser<T7>,
          parser8);
}

class Sequence8<T1, T2, T3, T4, T5, T6, T7, T8> extends SequenceBase {
  Sequence8(Parser<T1> parser1, Parser<T2> parser2, Parser<T3> parser3, Parser<T4> parser4, Parser<T5> parser5,
      Parser<T6> parser6, Parser<T7> parser7, Parser<T8> parser8)
      : super(<Parser<Object?>>[parser1, parser2, parser3, parser4, parser5, parser6, parser7, parser8]);
  Parser<R> map<R, RT1 extends T1, RT2 extends T2, RT3 extends T3, RT4 extends T4, RT5 extends T5, RT6 extends T6,
              RT7 extends T7, RT8 extends T8>(
          R Function(RT1 value1, RT2 value2, RT3 value3, RT4 value4, RT5 value5, RT6 value6, RT7 value7, RT8 value8)
              mapper) =>
      MapParser(
          this,
          (List<Object?> value) => mapper(value[0] as RT1, value[1] as RT2, value[2] as RT3, value[3] as RT4,
              value[4] as RT5, value[5] as RT6, value[6] as RT7, value[7] as RT8));

  Sequence9<T1, T2, T3, T4, T5, T6, T7, T8, Object?> operator &(Parser<Object?> parser9) =>
      Sequence9<T1, T2, T3, T4, T5, T6, T7, T8, Object?>(
          children[0] as Parser<T1>,
          children[1] as Parser<T2>,
          children[2] as Parser<T3>,
          children[3] as Parser<T4>,
          children[4] as Parser<T5>,
          children[5] as Parser<T6>,
          children[6] as Parser<T7>,
          children[7] as Parser<T8>,
          parser9);
}

class Sequence9<T1, T2, T3, T4, T5, T6, T7, T8, T9> extends SequenceBase {
  Sequence9(Parser<T1> parser1, Parser<T2> parser2, Parser<T3> parser3, Parser<T4> parser4, Parser<T5> parser5,
      Parser<T6> parser6, Parser<T7> parser7, Parser<T8> parser8, Parser<T9> parser9)
      : super(<Parser<Object?>>[parser1, parser2, parser3, parser4, parser5, parser6, parser7, parser8, parser9]);
  Parser<R> map<R, RT1 extends T1, RT2 extends T2, RT3 extends T3, RT4 extends T4, RT5 extends T5, RT6 extends T6,
              RT7 extends T7, RT8 extends T8, RT9 extends T9>(
          R Function(RT1 value1, RT2 value2, RT3 value3, RT4 value4, RT5 value5, RT6 value6, RT7 value7, RT8 value8,
                  RT9 value9)
              mapper) =>
      MapParser(
          this,
          (List<Object?> value) => mapper(value[0] as RT1, value[1] as RT2, value[2] as RT3, value[3] as RT4,
              value[4] as RT5, value[5] as RT6, value[6] as RT7, value[7] as RT8, value[8] as RT9));

  Sequence10<T1, T2, T3, T4, T5, T6, T7, T8, T9, Object?> operator &(Parser<Object?> parser10) =>
      Sequence10<T1, T2, T3, T4, T5, T6, T7, T8, T9, Object?>(
          children[0] as Parser<T1>,
          children[1] as Parser<T2>,
          children[2] as Parser<T3>,
          children[3] as Parser<T4>,
          children[4] as Parser<T5>,
          children[5] as Parser<T6>,
          children[6] as Parser<T7>,
          children[7] as Parser<T8>,
          children[8] as Parser<T9>,
          parser10);
}

class Sequence10<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10> extends SequenceBase {
  Sequence10(Parser<T1> parser1, Parser<T2> parser2, Parser<T3> parser3, Parser<T4> parser4, Parser<T5> parser5,
      Parser<T6> parser6, Parser<T7> parser7, Parser<T8> parser8, Parser<T9> parser9, Parser<T10> parser10)
      : super(<Parser<Object?>>[
          parser1,
          parser2,
          parser3,
          parser4,
          parser5,
          parser6,
          parser7,
          parser8,
          parser9,
          parser10
        ]);
  Parser<R> map<R, RT1 extends T1, RT2 extends T2, RT3 extends T3, RT4 extends T4, RT5 extends T5, RT6 extends T6,
              RT7 extends T7, RT8 extends T8, RT9 extends T9, RT10 extends T10>(
          R Function(RT1 value1, RT2 value2, RT3 value3, RT4 value4, RT5 value5, RT6 value6, RT7 value7, RT8 value8,
                  RT9 value9, RT10 value10)
              mapper) =>
      MapParser(
          this,
          (List<Object?> value) => mapper(value[0] as RT1, value[1] as RT2, value[2] as RT3, value[3] as RT4,
              value[4] as RT5, value[5] as RT6, value[6] as RT7, value[7] as RT8, value[8] as RT9, value[9] as RT10));

  SequenceParser<Object?> operator &(Parser<Object?> parser11) => SequenceParser<Object?>(<Parser>[
        children[0] as Parser<T1>,
        children[1] as Parser<T2>,
        children[2] as Parser<T3>,
        children[3] as Parser<T4>,
        children[4] as Parser<T5>,
        children[5] as Parser<T6>,
        children[6] as Parser<T7>,
        children[7] as Parser<T8>,
        children[8] as Parser<T9>,
        children[9] as Parser<T10>,
        parser11
      ]);
}

extension ParserSequenceBuiltExtension<R> on Parser<R> {
  Sequence2<R, Object?> operator &(Parser<Object?> other) => Sequence2<R, Object?>(this, other);
}
