import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class SuccessParser<R extends Object?> extends SpecialParser<R> with NullableParser, NullRecognizer {
  final R result;

  SuccessParser(this.result);

  @override
  Context<R> parseOn(Context<void> context, Handler handler) => context.success(result);
}

SuccessParser<R> _success<R>(R result) => SuccessParser<R>(result);
Parser<R> success<R extends Object?>(R result) => _success(result);
