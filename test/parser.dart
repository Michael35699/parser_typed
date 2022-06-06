// cspell: disable

import "package:parser_typed/examples/calculator/math.dart" as math_parser;
import "package:parser_typed/parser.dart" as parser;
import "package:test/test.dart";

import "util.dart";

void main() {
  group("action", () {
    parser.Parser<Never> failure = parser.failure("Oh no!");

    group("action", () {
      TestGroup2 run = createTestGroup2((parser.Parser actioned, parser.Parser alwaysFails) {
        expect(actioned, parserSuccess("ab", <String>["a", "c"]));
      });
      parser.Parser<List<Object?>> delegate = parser.string("a") & parser.string("b");

      run(
        "extension_method",
        delegate.action((String a, String b) => <String>["a", "c"]),
        failure.action(() => fail("this should not be called")),
      );
      run(
        "constructor",
        parser.ActionParser<dynamic, dynamic>(delegate, (String a, String b) => <String>["a", "c"]),
        parser.ActionParser<dynamic, dynamic>(delegate, () => fail("this should not be called")),
      );
    });
    group("map", () {
      TestGroup2 run = createTestGroup2((parser.Parser pass, parser.Parser fail) {
        expect(pass, parserSuccess("ab", <String>["b", "b"], index: 2));

        expect(fail, parserFailure("abc"));
        expect(fail, parserFailure("foo"));
      });

      run("extension_method", "a".$.map((_) => "b") & "b",
          failure.map<Never>((_) => fail("this should not be called")));
      run("constructor", parser.MapParser("a".$, (_) => "b") & "b",
          parser.MapParser<void, void>(failure, (_) => fail("this should not be called")));
    });
    group("bind", () {
      TestGroup2 run = createTestGroup2((parser.Parser bound, parser.Parser alwaysFails) {
        expect(bound, parserSuccess("abc", <String>["a", "b"], index: 2));
        expect(bound, parserFailure("a", message: "Expected 'b'"));
        expect(alwaysFails, parserFailure("foo bar"));
      });

      run(
        "extension_method",
        "a".parser().bind((String l) => "b".parser().bind((String r) => parser.success(<String>[l, r]))),
        failure.bind<void>((_) => fail("shouldn't be called")),
      );
      run(
        "constructor",
        parser.BindParser(
          "a".parser(),
          (String l) => parser.BindParser("b".parser(), (String r) => parser.success(<String>[l, r])),
        ),
        parser.BindParser(failure, (_) => fail("shouldn't be called.")),
      );
    });
    group("where", () {
      TestGroup2 run = createTestGroup2((parser.Parser evenNumber, parser.Parser alwaysFails) {
        expect(evenNumber, parserSuccess("12", 12, index: 2));
        expect(evenNumber, parserFailure("13", message: "Filter failure"));
        expect(alwaysFails, parserFailure("foo bar"));
      });

      run(
        "extension_method",
        integer.where((int p) => p.isEven),
        failure.where((_) => fail("shouldn't be called")),
      );
      run(
        "constructor",
        parser.FilterParser<int>(integer, (int p) => p.isEven),
        parser.FilterParser<int>(failure, (int p) => fail("shouldn't be called")),
      );
    });
    group("flatMap", () {
      TestGroup2 run = createTestGroup2((parser.Parser flatMapped, parser.Parser guarded) {
        expect(flatMapped, parserSuccess("b", "bb"));
        expect(guarded, parserFailure("foo bar"));
      });

      parser.PrimitiveParser delegate = "b".parser();
      run(
        "method_extension",
        delegate.expand((_) => const parser.Success("bb")),
        failure.expand((_) => fail("Should not be called")),
      );
      run(
        "constructor",
        parser.FlatMapParser(delegate, (_) => const parser.Success("bb")),
        parser.FlatMapParser(failure, (_) => fail("Should not be called")),
      );
    });
  });

  group("traverse", () {
    parser.Parser body = "a".parser() & ("c".parser()).trim().plus();
    Iterable<parser.Parser> traversal = body.traverse;
    List<parser.Parser> cached = traversal.toList();

    test("traverse_count", () {
      expect(cached.length, 5);

      /// 1. '' & ''
      /// 2. "a".parser()
      /// 3. "c".parser()
      /// 4.   ''.trim()
      /// 5.     ''.plus()
    });
    test("traverse_first", () {
      expect(cached[0].runtimeType, parser.SequenceParser<Object?>);
      expect(cached[1].runtimeType, parser.StringParser);
      expect(cached[2].runtimeType, parser.CyclePlusParser<String>);
      expect(cached[3].runtimeType, parser.TrimParser<String>);
      expect(cached[4].runtimeType, parser.StringParser);
    });
  });

  group("build", () {
    parser.Parser untouched = math_parser.infix().clone();

    test("reference_removal", () {
      parser.Parser built = untouched.build();
      int thunkCount = built.traverse.whereType<parser.ReferenceParser>().length;

      expect(thunkCount, 0);
    });
  });

  group("cycle", () {
    group("star", () {
      TestGroup run = createTestGroup((Object? parser) {
        expect(parser, parserSuccess("bb", emptyList, index: 0));
        expect(parser, parserSuccess("", emptyList));
        expect(parser, parserSuccess("a", "a".split("")));
        expect(parser, parserSuccess("aaaaaaaaa", "aaaaaaaaa".split("")));
      });

      parser.Parser<String> delegate = "a".parser();
      run("method_extension_1", delegate.cycleStar());
      run("method_extension_2", delegate.star());
      run("function", parser.cycleStar(delegate));
      run("constructor", parser.CycleStarParser(delegate));
    });
    group("plus", () {
      TestGroup run = createTestGroup((Object? parser) {
        expect(parser, parserFailure(""));
        expect(parser, parserFailure("bb"));
        expect(parser, parserSuccess("a", "a".split("")));
        expect(parser, parserSuccess("aaaaaaaaa", "aaaaaaaaa".split("")));
      });

      parser.Parser<String> delegate = "a".parser();
      run("method_extension_1", delegate.cyclePlus());
      run("method_extension_2", delegate.plus());
      run("function", parser.cyclePlus(delegate));
      run("constructor", parser.CyclePlusParser(delegate));
    });
    group("separated", () {
      TestGroup run = createTestGroup((Object? separated) {
        expect(separated, parserSuccess("a", <String>["a"]));
        expect(separated, parserSuccess("a,a,a,a", <String>["a", "a", "a", "a"]));
        expect(separated, parserSuccess("a  , a  , a, a", <String>["a", "a", "a", "a"]));
        expect(separated, parserSuccess("a  , a  ,b", <String>["a", "a"], index: 6));
      });

      parser.PrimitiveParser delegate = "a".parser();
      parser.Parser<String> separator = ",".t();
      run("operator_extension", delegate % separator);
      run("method_extension_1", delegate.cycleSeparated(separator));
      run("method_extension_2", delegate.separated(separator));
      run("constructor", parser.CycleSeparatedParser(delegate, separator));
      run("function", parser.cycleSeparated(delegate, separator));
    });
    group("cycle_to", () {
      TestGroup run = createTestGroup((parser.Parser p) {
        expect(
          p,
          parserSuccess("aaaaac", <String>["a", "a", "a", "a", "a"], index: 5),
        );
        expect(
          p & "c",
          parserSuccess("aaac", <Object>[
            <String>["a", "a", "a"],
            "c"
          ]),
        );
        expect(
          p.optional() & "c",
          parserSuccess("ac", <Object>[
            <String>["a"],
            "c"
          ]),
        );
      });

      parser.PrimitiveParser delegate = "a".parser();
      parser.PrimitiveParser delimiter = "c".parser();

      run("method_extension_1", delegate.cycleTo(delimiter));
      run("method_extension_2", delegate.to(delimiter));
      run("constructor", parser.CycleToParser(delegate, delimiter));
      run("function", parser.cycleTo(delegate, delimiter));
    });
    group("n_times", () {
      TestGroup2 run = createTestGroup2((parser.Parser main, parser.Parser grid) {
        expect(main, parserSuccess("λxλxλx", <String>["λx", "λx", "λx"]));
        expect(main, parserSuccess("λxλxλxλxλx", <String>["λx", "λx", "λx"], index: 6));
        expect(main, parserFailure("λx"));
        expect(
          grid,
          parserSuccess("λxλxλxλxλxλxλxλxλx", <List<String>>[
            <String>["λx", "λx", "λx"],
            <String>["λx", "λx", "λx"],
            <String>["λx", "λx", "λx"]
          ]),
        );
      });

      parser.Parser<String> delegate = parser.string("λx");
      run("operator_extension", delegate * 3, (delegate * 3) * 3);
      run("method_extension_1", delegate.cycleN(3), delegate.cycleN(3).cycleN(3));
      run("method_extension_2", delegate.n(3), delegate.n(3).n(3));
      run("constructor", parser.CycleNParser(delegate, 3), parser.CycleNParser(parser.CycleNParser(delegate, 3), 3));
      run("function", parser.cycleN(delegate, 3), parser.cycleN(parser.cycleN(delegate, 3), 3));
    });
  });

  group("lazy_wrap", () {
    group("reference", () {
      parser.Parser built() => "a" & "b";
      TestGroup<parser.ReferenceParser> run = createTestGroup((parser.ReferenceParser<void> lazy) {
        expect(lazy.computed, equals(built.reference().computed));
        expect(lazy.computed, equals(lazy.base));
        expect(lazy, parserThrow<UnsupportedError>("ab"));
        expect(lazy, parserThrow<UnsupportedError>("a"));
      });

      run("extension_method", built.reference());
      run("extension_getter", built.ref);
      run("constructor", parser.ReferenceParser(built));
    });
  });

  group("leaf", () {
    // group("character", () {
    //   const String template = "abcdefghijklmnopqrstuvwxyz";
    //   void run(parser.Parser p) {
    //     expect(p, parserSuccess("ab", "a"));
    //     expect(p, parserFailure("123", message: "expected alphabet"));
    //   }
    //   test("extension_1", () => run(template.character().message("expected alphabet")));
    //   test("extension_2", () => run(template.c().message("expected alphabet")));
    //   test("function", () => run(parser.char(template).message("expected alphabet")));
    //   test("constructor", () => run(parser.CharacterParser(template).message("expected alphabet")));
    //   test("identity", () {
    //     parser.Parser parser1 = template.character();
    //     parser.Parser parser2 = template.c();
    //     parser.Parser parser3 = parser.char(template);
    //     parser.Parser parser4 = parser.CharacterParser(template);
    //     Set<parser.Parser> parsers = {parser1, parser2, parser3, parser4};
    //     expect(parsers.length, 1);
    //   });
    // });

    group("regex", () {
      TestGroup run = createTestGroup((parser.Parser parser) {
        expect(parser, parserSuccess("123", "123"));
        expect(parser, parserSuccess("012", "012"));
        expect(parser, parserFailure(""));
      });

      const String template = "[0-9]+";
      run("", template.r());
      run("extension_2", template.regex());
      run("function", parser.regex(template));
      run("constructor", parser.RegExpParser(template));
      test("identity", () {
        parser.PrimitiveParser parser1 = template.r();
        parser.PrimitiveParser parser2 = template.regex();
        parser.PrimitiveParser parser3 = parser.regex(template);
        parser.PrimitiveParser parser4 = parser.RegExpParser(template);

        Set<parser.Parser> parsers = <parser.Parser>{parser1, parser2, parser3, parser4};
        expect(parsers.length, equals(1));
      });
    });

    group("string", () {
      const String template = "foo bar";
      TestGroup run = createTestGroup((parser.Parser parser) {
        expect(parser, parserSuccess("foo bar", "foo bar"));
        expect(parser, parserFailure("hello", message: "Expected 'foo bar'"));
      });

      run("extension_1", template.parser());
      run("extension_2", template.p());
      run("function", parser.string(template));
      run("constructor", parser.StringParser(template));
      run("dollar", template.$);
      test("identity", () {
        parser.Parser parser1 = template.$;
        parser.Parser parser2 = template.parser();
        parser.Parser parser3 = template.p();
        parser.Parser parser4 = parser.string(template);
        parser.Parser parser5 = parser.StringParser(template);

        Set<parser.Parser> parsers = <parser.Parser>{parser1, parser2, parser3, parser4, parser5};
        expect(parsers.length, 1);
      });
    });
  });

  group("lookahead", () {
    group("not", () {
      TestGroup run = createTestGroup((parser.Parser parser) {
        expect(parser, parserSuccess("b", <String?>[null, "b"]));
        expect(parser, parserFailure("ab"));
      });

      run("operator", ~"a" & "b");
      run("method_extension_1", "a".parser().negativeLookahead() & "b");
      run("method_extension_2", "a".parser().not() & "b");
      run("function", parser.not("a".parser()) & "b");
      run("constructor", parser.NegativeLookaheadParser("a".parser()) & "b");
    });
    group("and", () {
      TestGroup run = createTestGroup((parser.Parser parser) {
        expect(parser, parserSuccess("ab", <String?>[null, "a", "b"], index: 2));
        expect(parser, parserFailure("df"));
      });

      run("method_extension_1", "a".parser().positiveLookahead() & "a".parser() & "b".parser());
      run("method_extension_2", "a".parser().and() & "a".parser() & "b".parser());
      run("function", parser.and("a".parser()) & "a".parser() & "b".parser());
      run("constructor", parser.PositiveLookaheadParser("a".parser()) & "a".parser() & "b".parser());
    });
  });

  group("on", () {
    group("failure", () {
      TestGroup run = createTestGroup((parser.Parser p) {
        expect(p, parserSuccess("b", "b", index: 1));
        expect(p, parserSuccess("d", "c", index: 0));
      });

      run("operator_extension", "b" ~/ "c");
      run("method_extension", "b".failure("c"));
      run("constructor", parser.OnFailureParser<String>("b".$, "c"));
    });
    group("success", () {
      TestGroup run = createTestGroup((parser.Parser p) {
        expect(p, parserSuccess("ab", <String>["a", "c"]));
        expect(p, parserFailure("ac", message: "Expected 'b'"));
      });

      run("extension", "a" & "b".success("c"));
      run("constructor", "a" & parser.OnSuccessParser("b".parser(), "c"));
    });
  });

  group("predicate", () {
    group("empty", () {
      TestGroup run = createTestGroup((parser.Parser p) {
        expect(p, parserEmpty("ab"));
        expect(p, parserEmpty(""));
      });

      run("function", parser.empty());
      run("constructor", parser.EmptyParser());
    });
    group("except", () {
      TestGroup run = createTestGroup((parser.Parser p) {
        expect(p, parserFailure("ab", message: "no chance"));
        expect(p, parserFailure("", message: "no chance"));
      });

      run("function", parser.failure("no chance"));
      run("constructor", parser.FailureParser("no chance"));
    });
    group("success", () {
      TestGroup run = createTestGroup((parser.Parser p) {
        expect(p, parserSuccess("ab", "yes chance", index: 0));
        expect(p, parserSuccess("", "yes chance", index: 0));
      });

      run("function", parser.success<String>("yes chance"));
      run("constructor", parser.SuccessParser("yes chance"));
    });
  });

  group("special", () {
    group("blank", () {
      TestGroup run = createTestGroup((parser.Parser p) {
        expect(p, parserFailure("any input", message: "blank"));
        expect(p, parserFailure("doesn't work", message: "blank"));
      });

      run("function", parser.blank());
      run("constructor", parser.BlankParser());
      test("factory", () {
        expect(parser.blank(), equals(parser.blank()));
        expect(parser.BlankParser(), equals(parser.BlankParser()));

        expect(parser.BlankParser.generate(), isNot(equals(parser.BlankParser.generate())),
            reason: "using [BlankParser.generate] should return a new [BlankParser] instance");
      });
    });
    group("eoi", () {
      TestGroup run = createTestGroup((parser.Parser p) {
        expect(p, parserFailure("foo", message: "Expected end of input"));
        expect(p, parserSuccess("", null));
      });

      run("function", parser.eoi());
      run("constructor", parser.EndOfInputParser());
      test("factory", () {
        expect(parser.eoi(), equals(parser.eoi()));
        expect(parser.end(), equals(parser.end()));
        expect(parser.EndOfInputParser(), equals(parser.EndOfInputParser()));
      });
    });
    group("epsilon", () {
      TestGroup run = createTestGroup((parser.Parser p) {
        expect(p, parserSuccess("", "", index: 0));
        expect(p, parserSuccess("abc", "", index: 0));
      });

      run("function", parser.epsilon());
      run("constructor", parser.EpsilonParser());
    });
    group("source", () {
      TestGroup run = createTestGroup((parser.Parser p) {
        expect(parser.any(), parserFailure("", message: "Expected any character"));
        expect(parser.any(), parserSuccess("abc", "a", index: 1));
      });

      run("function", parser.any());
      run("constructor", parser.SourceParser());
    });
  });

  group("wrap", () {
    group("continuation", () {
      TestGroup run = createTestGroup((parser.Parser parser) {
        expect(parser, parserFailure("b"));
        expect(parser, parserSuccess("a", "a"));
      });

      parser.PrimitiveParser delegate = "a".parser();
      run("extension", delegate.cc(<R, I>(parser.ParseFunction<R, I> fn, parser.Context<I> ctx) => fn(ctx)));
      run(
          "function",
          parser.ContinuationParser<String>(
              delegate, <R, I>(parser.ParseFunction<R, I> fn, parser.Context<I> ctx) => fn(ctx)));
    });
    // group("drop", () {
    //   parser.Parser delegate = "ab".parser();
    //   void run(parser.Parser p) {
    //     expect(p, parserEmpty("ab"));
    //     expect(p, parserFailure("ac"));
    //   }

    //   test("extension", () => run(delegate.drop()));
    //   test("function", () => run(parser.drop(delegate)));
    //   test("constructor", () => run(parser.DropParser(delegate)));
    // });
    group("except_message", () {
      TestGroup run = createTestGroup((parser.Parser p) {
        expect(p, parserSuccess("'hello world!'", "hello world!"));
        expect(p, parserFailure("'hello world!", message: "Expected string literal"));
      });
      parser.Parser delegate = parser.string();
      run("operator", delegate ^ "Expected string literal");
      run("extension_method", delegate.message("Expected string literal"));
      run("constructor", parser.FailureMessageParser(delegate, "Expected string literal"));
    });
    group("flat", () {
      TestGroup run = createTestGroup((parser.Parser p) {
        expect(p, parserSuccess("foo bar baz", "foo bar baz"));
        expect(p, parserSuccess("foobarbaz", "foobarbaz"));
        expect(p, parserFailure("foo"));
      });

      parser.Parser<List<Object?>> template = "foo" & "bar".parser().tl() & "baz".parser().tl();
      run("extension", template.flat());
      run("function", parser.flat(template));
      run("constructor", parser.FlatParser(template));
    });
    group("optional", () {
      TestGroup run = createTestGroup((parser.Parser p) {
        expect(p, parserSuccess("a", "a"));
        expect(p, parserSuccess("b", null, index: 0));
      });

      parser.PrimitiveParser delegate = "a".parser();
      run("extension", delegate.optional());
      run("function", parser.optional(delegate));
      run("constructor", parser.OptionalParser(delegate));
    });
    group("trim", () {
      parser.Parser<String> left = parser.string("a");
      parser.Parser<String> delegate = parser.string("+");
      parser.Parser<String> right = parser.string("b");

      group("trim_newline", () {
        group("trim_left", () {
          TestGroup run = createTestGroup((parser.Parser p) {
            expect(p, parserSuccess("a+b", <String>["a", "+", "b"]));
            expect(p, parserSuccess("a \n \n +b", <String>["a", "+", "b"]));
            expect(p, parserFailure("a+  \n b"));
            expect(p, parserFailure("a \n  + \n  b"));
          });

          run("extension_1", left & delegate.trimNewlineLeft() & right);
          run("extension_2", left & delegate.tnlL() & right);
          run("function", left & parser.trimNewlineLeft(delegate) & right);
        });
        group("trim_right", () {
          TestGroup run = createTestGroup((parser.Parser p) {
            expect(p, parserSuccess("a+b", <String>["a", "+", "b"]));
            expect(p, parserSuccess("a+  \n b", <String>["a", "+", "b"]));
            expect(p, parserFailure("a \n \n +b"));
            expect(p, parserFailure("a \n  + \n  b"));
          });

          run("extension_1", left & delegate.trimNewlineRight() & right);
          run("extension_2", left & delegate.tnlR() & right);
          run("function", left & parser.trimNewlineRight(delegate) & right);
        });
        group("trim_left_right", () {
          TestGroup run = createTestGroup((parser.Parser p) {
            expect(p, parserSuccess("a+b", <String>["a", "+", "b"]));
            expect(p, parserSuccess("a+  \n b", <String>["a", "+", "b"]));
            expect(p, parserSuccess("a \n \n +b", <String>["a", "+", "b"]));
            expect(p, parserSuccess("a \n  + \n  b", <String>["a", "+", "b"]));
          });

          run("extension_1", left & delegate.trimNewline() & right);
          run("extension_2", left & delegate.tnl() & right);
          run("function", left & parser.trimNewline(delegate) & right);
        });
      });
      group("trim", () {
        group("trim_left", () {
          TestGroup run = createTestGroup((parser.Parser p) {
            expect(p, parserSuccess("a+b", <String>["a", "+", "b"]));
            expect(p, parserSuccess("a   +b", <String>["a", "+", "b"]));
            expect(p, parserFailure("a+   b"));
            expect(p, parserFailure("a   +   b"));
          });

          run("extension_1", left & delegate.trimLeft() & right);
          run("extension_2", left & delegate.tl() & right);
          run("function", left & parser.trimLeft(delegate) & right);
        });
        group("trim_right", () {
          TestGroup run = createTestGroup((parser.Parser p) {
            expect(p, parserSuccess("a+b", <String>["a", "+", "b"]));
            expect(p, parserSuccess("a+   b", <String>["a", "+", "b"]));
            expect(p, parserFailure("a   +b"));
            expect(p, parserFailure("a   +   b"));
          });

          run("extension_1", left & delegate.trimRight() & right);
          run("extension_2", left & delegate.tr() & right);
          run("function", left & parser.trimRight(delegate) & right);
        });
        group("trim_left_right", () {
          TestGroup run = createTestGroup((parser.Parser p) {
            expect(p, parserSuccess("a+b", <String>["a", "+", "b"]));
            expect(p, parserSuccess("a+   b", <String>["a", "+", "b"]));
            expect(p, parserSuccess("a   +b", <String>["a", "+", "b"]));
            expect(p, parserSuccess("a   +   b", <String>["a", "+", "b"]));
          });

          run("extension_1", left & delegate.trim() & right);
          run("extension_2", left & delegate.t() & right);
          run("function", left & parser.trim(delegate) & right);
        });
      });
    });
  });
}
