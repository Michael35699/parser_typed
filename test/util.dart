// ignore_for_file: always_specify_types

import "package:meta/meta.dart";
import "package:parser_typed/parser.dart" as parser;
import "package:test/test.dart";

typedef Matrix<R> = List<List<R>>;

Matcher contextSuccess({dynamic index = anything, dynamic result = anything}) => isA<parser.Success>() //
    .having((c) => c.index, "index", index)
    .having((c) => c.value, "result", result);

Matcher contextFailure({dynamic index = anything, dynamic message = anything}) => isA<parser.Failure>() //
    .having((c) => c.index, "index", index)
    .having((c) => c.message, "message", message);

Matcher contextEmpty({dynamic index = anything, dynamic message = anything}) => isA<parser.Empty>() //
    .having((c) => c.index, "index", index);

Matcher parserSuccess(String input, dynamic res, {Object? index}) => isA<parser.Parser>()
    .having((p) => p.parse(input), "parse", contextSuccess(index: index ?? input.length, result: res))
    .having((p) => p.recognize(input), "recognize", equals(index ?? input.length));

Matcher parserFailure(String input, {dynamic index = anything, dynamic message = anything}) => isA<parser.Parser>()
    .having((p) => p.parse(input), "parse", contextFailure(index: index, message: message))
    .having((p) => p.recognize(input), "recognize", equals(-1));

Matcher parserEmpty(String input, {dynamic index = anything}) => isA<parser.Parser>()
    .having((p) => p.parse(input), "parse", contextEmpty(index: index))
    .having((p) => p.recognize(input), "recognize", equals(index));

Matcher parserThrow<R extends Error>(String input) => isA<parser.Parser>()
    .having((p) => () => p.parse(input), "parse", throwsA(isA<R>()))
    .having((p) => () => p.recognize(input), "recognize", throwsA(isA<R>()));

const List<Object?> emptyList = <Object?>[];

parser.Parser<int> get integer => "[0-9]+".regex().action(int.parse);

@optionalTypeArgs
typedef TestGroup<P extends parser.Parser<Object?>> = void Function(String name, P parser);

TestGroup<P> createTestGroup<P extends parser.Parser<Object?>>(void Function(P parser) callback) => //
    (String name, P p) {
      test(name, () => callback(p));
    };

@optionalTypeArgs
typedef TestGroup2<P1 extends parser.Parser<Object?>, P2 extends parser.Parser<Object?>> = void Function(
    String name, P1 parser1, P2 parser2);

TestGroup2<P1, P2> createTestGroup2<P1 extends parser.Parser<Object?>, P2 extends parser.Parser<Object?>>(
        void Function(P1, P2) callback) =>
    (String name, P1 parser1, P2 parser2) {
      test(name, () => callback(parser1, parser2));
    };
