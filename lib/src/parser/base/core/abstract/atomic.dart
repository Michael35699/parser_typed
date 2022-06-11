import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
abstract class AtomicParser<R> extends Parser<R> with ChildlessParser<R> {
  bool _nullable = false;

  Context<R> fail(String message) => Failure(message);
  Context<R> succeed(R value, int index) => Success(value, "", index);
  Context<R> call(String input, int index);

  @override
  Context<R> parseOn(Context<void> context, ParseHandler handler) {
    String input = context.input;
    int index = context.index;

    Context<R> ctx = call(input, index);
    if (ctx.isFailure) {
      return context.failure(ctx.message);
    }
    return context.success(ctx.value, ctx.index);
  }

  @override
  int recognizeOn(String input, int index, ParseHandler handler) {
    Context<R> ctx = call(input, index);

    return ctx.isFailure ? -1 : ctx.index;
  }

  AtomicParser<R> annotateNullable() => this.._nullable = true;

  @override
  bool selfIsNullable(ParserBooleanCacheMap cache) => _nullable;
}
