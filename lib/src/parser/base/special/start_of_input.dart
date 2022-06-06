import "package:parser_typed/parser.dart";

class StartOfInputParser extends SpecialParser<String> with NullableParser {
  static final StartOfInputParser singleton = StartOfInputParser._();

  factory StartOfInputParser() => singleton;
  StartOfInputParser._();

  @override
  Context<String> parseOn(Context<void> context, Handler handler) {
    int index = context.index;

    return index <= 0 //
        ? context.success("start of input")
        : context.failure("Expected end of input").cast();
  }

  @override
  int recognizeOn(String input, int index, Handler handler) => index <= 0 ? index : -1;
}
