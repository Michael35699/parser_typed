import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class FlatMapParser<R, O> extends WrapParser<R, O> {
  @override
  final List<Parser<O>> children;
  final FlatMapFunction<R, O> flatMapFunction;

  @override
  Parser<O> get parser => children[0];

  FlatMapParser(Parser<O> child, this.flatMapFunction) : children = <Parser<O>>[child];
  FlatMapParser.empty(this.flatMapFunction) : children = <Parser<O>>[];

  @override
  Context<R> parseOn(Context<void> context, ParseHandler handler) {
    Context<O> resultContext = handler.parse(parser, context);

    return resultContext.isSuccess //
        ? flatMapFunction(resultContext.value).inherit(resultContext)
        : resultContext.cast();
  }

  @override
  int recognizeOn(String input, int index, ParseHandler handler) => handler.recognize(parser, input, index);

  @override
  FlatMapParser<R, O> get empty => FlatMapParser<R, O>.empty(flatMapFunction);
}

extension ParserFlatMapExtension<O> on Parser<O> {
  Parser<R> expand<R>(FlatMapFunction<R, O> function) => FlatMapParser<R, O>(this, function);
}

extension LazyParserFlatMapExtension<O> on Lazy<Parser<O>> {
  Parser<R> expand<R>(FlatMapFunction<R, O> function) => this.reference().expand(function);
}

extension StringFlatMapExtension on String {
  // Parser<R> expand<R>(FlatMapFunction<R, String> function) => this.parser().expand(function);
}
