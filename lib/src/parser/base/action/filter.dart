import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class FilterParser<R extends Object?> extends WrapParser<R, R> {
  @override
  final List<Parser<R>> children;
  final FilterFunction<R> filterFunction;

  @override
  Parser<R> get parser => children[0];

  FilterParser(Parser<R> parser, this.filterFunction) : children = <Parser<R>>[parser];
  FilterParser.empty(this.filterFunction) : children = <Parser<R>>[];

  @override
  Context<R> parseOn(Context<void> context, Handler handler) {
    Context<R> resultContext = handler.parse(parser, context);

    return resultContext.isSuccess && !filterFunction(resultContext.value) //
        ? resultContext.failure("Filter failure")
        : resultContext;
  }

  @override
  int recognizeOn(String input, int index, Handler handler) {
    Context<void> context = Empty(input, index);
    Context<R> resultContext = parseOn(context, handler);

    return resultContext.isFailure ? -1 : resultContext.index;
  }

  @override
  FilterParser<R> get empty => FilterParser<R>.empty(filterFunction);
}

extension ParserFilterParserExtension<R> on Parser<R> {
  Parser<R> where(FilterFunction<R> function) => FilterParser<R>(this, function);
}

extension LazyParserFilterParserExtension<R> on Lazy<Parser<R>> {
  Parser<R> where(FilterFunction<R> function) => FilterParser<R>(this.reference(), function);
}

extension StringFilterParserExtension on String {
  // Parser<String> where(FilterFunction<String> function) => FilterParser<String>(this.parser(), function);
}
