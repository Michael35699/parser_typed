import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class FailureMessageParser<R> extends WrapParser<R, R> with PassRecognizer, CannotDebugParser {
  @override
  final List<Parser<R>> children;
  final String message;
  @override
  Parser<R> get parser => children[0];

  FailureMessageParser(Parser<R> parser, this.message) : children = <Parser<R>>[parser];
  FailureMessageParser.empty(this.message) : children = <Parser<R>>[];

  @override
  Context<R> parseOn(Context<void> context, ParseHandler handler) {
    Context<R> result = handler.parse(parser, context);

    return result.isFailure //
        ? result.failure.artificial(message)
        : result;
  }

  @override
  FailureMessageParser<R> get empty => FailureMessageParser<R>.empty(message);
}

FailureMessageParser<R> _message<R>(Parser<R> parser, String message) => FailureMessageParser<R>(parser, message);
FailureMessageParser<R> message<R>(Parser<R> parser, String message) => _message(parser, message);

extension ParserFailureMessageExtension<R> on Parser<R> {
  Parser<R> message(String message) => _message(this, message);
  Parser<R> operator ^(String message) => this.message(message);
}
