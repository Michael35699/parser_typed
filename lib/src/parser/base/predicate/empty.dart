import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class EmptyParser<R> extends SpecialParser<R> with NullableParser, NullRecognizer {
  @override
  Context<R> parseOn(Context<void> context, ParseHandler handler) => context.empty();
}

EmptyParser<R> _empty<R>() => EmptyParser<R>();
Parser<void> empty() => _empty();
