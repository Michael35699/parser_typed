import "package:parser_typed/parser.dart";

abstract class Handler {
  Failure get longestFailure;

  Context<R> parse<I, R>(Parser<R> parser, Context<I> context);
  int recognize<R>(Parser<R> parser, String input, int index);

  Failure failure(Failure ctx);
}
