import "package:meta/meta.dart";
import "package:parser_typed/src/context/context.dart";

@optionalTypeArgs
@immutable
class Success<R> extends Context<R> {
  @override
  final R value;

  @override
  String get message => throw UnsupportedError("`Success<$R>` does not have an error message!");

  const Success(this.value, [super.input = "", super.index = 0]);

  @override
  Success<R> replaceIndex(int index) => Success(value, input, index);

  @override
  Success<R> replaceInput(String input) => Success<R>(value, input, index);

  @override
  Success<R> inherit<I>(Context<I> context) => Success<R>(value, context.input, context.index);

  @override
  String toString() => "Success[$location]: $value";
}
