import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";
import "package:parser_typed/src/handler/packrat/quadratic/classes.dart";

class LeftRecursion<SeedType, Result> {
  final Parser<Result> parser;
  SeedType seed;
  Head<Result>? head;

  LeftRecursion({required this.seed, required this.parser, required this.head});
}

@optionalTypeArgs
typedef RecognizingLeftRecursion<R> = LeftRecursion<int, R>;

@optionalTypeArgs
typedef ParsingLeftRecursion<R> = LeftRecursion<Context<R>, dynamic>;
