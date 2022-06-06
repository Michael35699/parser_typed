import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
mixin CannotParse<R> on Parser<R> {
  @nonVirtual
  @override
  Context<R> parseOn(Context<void> context, Handler handler) =>
      throw UnsupportedError("'$runtimeType' parsers cannot parse!");

  @nonVirtual
  @override
  int recognizeOn(String input, int index, Handler handler) =>
      throw UnsupportedError("'$runtimeType' parsers cannot recognize!");
}
