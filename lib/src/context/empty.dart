import "package:meta/meta.dart";
import "package:parser_typed/src/context/context.dart";

@optionalTypeArgs
@immutable
class Empty extends Context<Never> {
  @override
  Never get value => throw UnsupportedError("`Empty` does not have a result!");

  @override
  Never get message => throw UnsupportedError("`Empty` does not have a result!");

  const Empty([super.input = "", super.index = 0]);

  @override
  Empty replaceIndex(int index) => Empty(input, index);

  @override
  Empty replaceInput(String input) => Empty(input, index);

  @override
  Empty inherit<I>(Context<I> context) => Empty(context.input, context.index);

  @override
  String toString() => "Empty[$location]";
}
