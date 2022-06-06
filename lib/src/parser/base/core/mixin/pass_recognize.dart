import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
mixin PassRecognizer<O, I> on WrapParser<O, I> {
  @override
  @nonVirtual
  int recognizeOn(String input, int index, ParseHandler handler) => handler.recognize(this.parser, input, index);
}
