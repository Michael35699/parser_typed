import "package:parser_typed/parser.dart";

class StartOfInputParser extends SpecialParser<String> with NullableParser {
  static final StartOfInputParser singleton = StartOfInputParser._();

  factory StartOfInputParser() => singleton;
  StartOfInputParser._();

  @override
  Context<String> parseOn(Context<void> context, ParseHandler handler) {
    int index = context.index;

    return index <= 0 //
        ? context.success("start of input")
        : context.failure("Expected end of input").cast();
  }

  @override
  int recognizeOn(String input, int index, ParseHandler handler) => index <= 0 ? index : -1;
}

StartOfInputParser start() => StartOfInputParser();
StartOfInputParser soi() => StartOfInputParser();

extension ParserStartOfInputExtension<R> on Parser<R> {
  Parser<R> start() => prefix(start());
}
