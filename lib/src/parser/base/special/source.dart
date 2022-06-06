import "package:parser_typed/parser.dart";

class SourceParser extends SpecialParser<String> with NonNullableParser {
  static final SourceParser singleton = SourceParser._();

  factory SourceParser() => singleton;
  SourceParser._();

  @override
  Context<String> parseOn(Context<void> context, Handler handler) {
    String input = context.input;
    int index = context.index;

    return index < input.length //
        ? context.success(input[index], index + 1)
        : context.failure("Expected any character").cast();
  }

  @override
  int recognizeOn(String input, int index, Handler handler) => //
      index < input.length ? index + 1 : -1;
}

SourceParser any() => SourceParser();
