import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class MapParser<R extends Object?, O extends Object?> extends WrapParser<R, O> {
  @override
  final List<Parser<O>> children;
  final MapFunction<R, O> function;

  @override
  Parser<O> get parser => children[0];

  MapParser(Parser<O> child, this.function) : children = <Parser<O>>[child];
  MapParser.empty(this.function) : children = <Parser<O>>[];

  @override
  Context<R> parseOn(Context<void> context, Handler handler) {
    Context<O> result = handler.parse(parser, context);

    return result.isSuccess //
        ? result.success(function(result.value))
        : result.cast();
  }

  @override
  int recognizeOn(String input, int index, Handler handler) => handler.recognize(parser, input, index);

  @override
  MapParser<R, O> get empty => MapParser<R, O>.empty(function);
}

extension ParserMapExtension<O> on Parser<O> {
  Parser<R> map<R extends Object?>(MapFunction<R, O> function) => MapParser<R, O>(this, function);
}

extension LazyParserMapExtension<O> on Lazy<Parser<O>> {
  Parser<R> map<R extends Object?>(MapFunction<R, O> function) => this.reference().map(function);
}

extension StringMapExtension on String {
  // Parser<R> map<R >(MapFunction<R, String> function) => this.parser().map(function);
}