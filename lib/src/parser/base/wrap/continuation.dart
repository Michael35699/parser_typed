import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class ContinuationParser<R> extends WrapParser<R, R> {
  final ParseContinuationFunction function;
  final RecognizeContinuationFunction? recognizeFn;

  @override
  final List<Parser<R>> children;

  @override
  Parser<R> get parser => children[0];

  ContinuationParser(Parser<R> parser, this.function, [this.recognizeFn]) : children = <Parser<R>>[parser];
  ContinuationParser.empty(this.function, [this.recognizeFn]) : children = <Parser<R>>[];

  @override
  Context<R> parseOn(Context<void> context, ParseHandler handler) =>
      function((Context<void> ctx) => handler.parse(parser, ctx), context);

  @override
  int recognizeOn(String input, int index, ParseHandler handler) =>
      recognizeFn?.call((int i) => handler.recognize(parser, input, i), index) ??
      handler.recognize(parser, input, index);

  @override
  ContinuationParser<R> get empty => ContinuationParser<R>.empty(function);
}

extension ParserContinuationExtension<R> on Parser<R> {
  ContinuationParser<R> cc(ParseContinuationFunction fn, [RecognizeContinuationFunction? recognize]) =>
      ContinuationParser<R>(this, fn, recognize);
}

extension LazyParserContinuationExtension<R> on Lazy<Parser<R>> {
  ContinuationParser<R> cc(ParseContinuationFunction fn, [RecognizeContinuationFunction? recognize]) =>
      this.reference().cc(fn, recognize);
}

extension StringParserContinuationExtension on String {
  ContinuationParser<String> cc(ParseContinuationFunction fn, [RecognizeContinuationFunction? recognize]) =>
      this.parser().cc(fn, recognize);
}
