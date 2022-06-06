import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class CacheParser<R extends Object?> extends WrapParser<R, R> with PassRecognizer, CannotParse {
  @override
  final List<Parser<R>> children;

  @override
  Parser<R> get parser => children[0];

  CacheParser(Parser<R> parser) : children = <Parser<R>>[parser];
  CacheParser.empty() : children = <Parser<R>>[];

  @override
  CacheParser<R> get empty => CacheParser<R>.empty();
}
