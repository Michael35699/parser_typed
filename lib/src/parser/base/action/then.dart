import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class ThenParser<R extends Object?, O extends Object?> extends WrapParser<R, O> {
  @override
  final List<Parser<O>> children;
  final ThenFunction<R, O> function;

  @override
  Parser<O> get parser => children[0];

  ThenParser(Parser<O> parser, this.function) : children = <Parser<O>>[parser];
  ThenParser.empty(this.function) : children = <Parser<O>>[];

  @override
  Context<R> parseOn(Context<void> context, Handler handler) => function(handler.parse(parser, context));

  @override
  int recognizeOn(String input, int index, Handler handler) => handler.recognize(parser, input, index);

  @override
  ThenParser<R, O> get empty => ThenParser<R, O>.empty(function);
}

extension ParserThenExtension<O> on Parser<O> {
  Parser<R> then<R extends Object?>(ThenFunction<R, O> function) => ThenParser<R, O>(this, function);
}

extension LazyParserThenExtension<O> on Lazy<Parser<O>> {
  Parser<R> then<R extends Object?>(ThenFunction<R, O> function) => ThenParser<R, O>(this.reference(), function);
}

extension StringThenExtension on String {
  // Parser<R> then<R >(ThenFunction<R, String> function) => ThenParser<R, String>(this.parser(), function);
}
