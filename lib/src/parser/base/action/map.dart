import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class MapParser<R, O> extends WrapParser<R, O> {
  @override
  final List<Parser<O>> children;
  final MapFunction<R, O> function;

  @override
  Parser<O> get parser => children[0];

  MapParser(Parser<O> child, this.function) : children = <Parser<O>>[child];
  MapParser.empty(this.function) : children = <Parser<O>>[];

  @override
  Context<R> parseOn(Context<void> context, ParseHandler handler) {
    Context<O> result = handler.parse(parser, context);

    return result.isSuccess //
        ? result.success(function(result.value))
        : result.cast();
  }

  @override
  int recognizeOn(String input, int index, ParseHandler handler) => handler.recognize(parser, input, index);

  @override
  MapParser<R, O> get empty => MapParser<R, O>.empty(function);
}

extension ParserMapExtension<O> on Parser<O> {
  Parser<R> map<R>(MapFunction<R, O> function) => MapParser<R, O>(this, function);
}
