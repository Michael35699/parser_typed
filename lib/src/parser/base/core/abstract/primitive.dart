import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
abstract class PrimitiveParser extends Parser<String> {
  bool _nullable = false;
  @override
  bool get memoize => false;

  Failure fail(String message) => Failure(message);
  Success<int> succeed(int index) => Success(index);

  Context<int> call(String input, int index, Handler handler);

  @override
  Context<String> parseOn(Context<void> context, Handler handler) {
    String input = context.input;
    int index = context.index;
    Context<int> ctx = call(input, index, handler);

    if (ctx.isSuccess) {
      int end = ctx.value;

      return context.success(input.substring(index, end), end);
    }

    return ctx.inherit(context) as Context<String>;
  }

  @override
  int recognizeOn(String input, int index, Handler handler) {
    Context<int> ctx = call(input, index, handler);

    return ctx.isFailure ? -1 : ctx.value;
  }

  PrimitiveParser nullable() => this.._nullable = true;

  @override
  bool selfIsNullable(ParserBooleanCacheMap cache) => _nullable;
}
