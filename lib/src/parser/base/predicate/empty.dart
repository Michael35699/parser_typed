import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class EmptyParser<R extends Object?> extends SpecialParser<R> with NullableParser, NullRecognizer {
  @override
  Context<R> parseOn(Context<void> context, Handler handler) => context.empty();
}

EmptyParser<R> _empty<R>() => EmptyParser<R>();
Parser<void> empty() => _empty();
