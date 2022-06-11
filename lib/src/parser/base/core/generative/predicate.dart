import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class PredicateParser<R> extends AtomicParser<R> {
  final ParserPredicate<R> predicate;

  PredicateParser(this.predicate);

  @override
  Context<R> call(String input, int index) => predicate(input, index, succeed, fail);
}

PredicateParser<R> predicate<R>(ParserPredicate<R> predicate) => PredicateParser<R>(predicate);
