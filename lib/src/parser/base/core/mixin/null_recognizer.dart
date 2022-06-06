import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
mixin NullRecognizer<R> on Parser<R> {
  @override
  @nonVirtual
  int recognizeOn(String input, int index, Handler handler) => index;
}
