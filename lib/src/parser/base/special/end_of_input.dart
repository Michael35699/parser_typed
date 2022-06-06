import "package:parser_typed/parser.dart";

class EndOfInputParser extends SpecialParser<void> with NullableParser {
  static final EndOfInputParser singleton = EndOfInputParser._();

  factory EndOfInputParser() => singleton;
  EndOfInputParser._();

  @override
  Context<void> parseOn(Context<void> context, ParseHandler handler) {
    String input = context.input;
    int index = context.index;

    return index >= input.length //
        ? context.success<void>(null)
        : context.failure("Expected end of input").cast();
  }

  @override
  int recognizeOn(String input, int index, ParseHandler handler) => index >= input.length ? index : -1;
}

EndOfInputParser end() => EndOfInputParser();
EndOfInputParser eoi() => EndOfInputParser();

extension ParserEndOfInputExtension<R> on Parser<R> {
  Parser<R> end() => (this & eoi()).action((R left, void _) => left);
}

extension LazyParserEndOfInputExtension<R> on Lazy<Parser<R>> {
  Parser<R> end() => (this.reference() & eoi()).action((R left, void _) => left);
}
