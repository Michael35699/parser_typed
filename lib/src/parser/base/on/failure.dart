import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class OnFailureParser<R> extends WrapParser<R, R> {
  @override
  final List<Parser<R>> children;
  final R value;
  @override
  Parser<R> get parser => children[0];

  OnFailureParser(Parser<R> parser, this.value) : children = <Parser<R>>[parser];
  OnFailureParser.empty(this.value) : children = <Parser<R>>[];

  @override
  Context<R> parseOn(Context<void> context, ParseHandler handler) {
    Context<R> result = handler.parse(parser, context);

    return result.isFailure ? result.success(value) : result;
  }

  @override
  int recognizeOn(String input, int index, ParseHandler handler) {
    int result = handler.recognize(parser, input, index);
    return result < 0 ? index : result;
  }

  @override
  OnFailureParser<R> get empty => OnFailureParser<R>.empty(value);
}

OnFailureParser<R> _failure<R>(Parser<R> parser, R value) => OnFailureParser<R>(parser, value);
// OnFailureParser<R, O> failure<R, O>(Parser<O> parser, R value) => _failure(parser, value);

extension ParserOnFailureExtension<R> on Parser<R> {
  Parser<R> failure(R value) => _failure(this, value);
  Parser<R> operator ~/(R value) => failure(value);
}
