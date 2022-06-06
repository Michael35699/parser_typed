import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class FailureParser<R extends Object?> extends SpecialParser<R> with NullableParser, FailRecognizer {
  final String message;

  FailureParser(this.message);

  @override
  Context<R> parseOn(Context<void> context, ParseHandler handler) => context.failure.artificial(message);
}

FailureParser<R> _failure<R>(String message) => FailureParser<R>(message);
Parser<R> failure<R extends Object?>(String message) => _failure(message);
