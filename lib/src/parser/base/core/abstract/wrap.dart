import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
abstract class WrapParser<O, I> extends Parser<O> with WrapTransform<O> {
  @override
  List<Parser> get children;

  @override
  Parser<I> get parser;

  @override
  Parser get base => parser.base;
}
