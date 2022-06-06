import "package:parser_typed/parser.dart";

class EpsilonParser extends SpecialParser<String> with NullableParser {
  static final EpsilonParser singleton = EpsilonParser._();

  factory EpsilonParser() => singleton;
  EpsilonParser._();

  @override
  Context<String> parseOn(Context<void> context, Handler handler) => context.success("");

  @override
  int recognizeOn(String input, int index, Handler handler) => index;
}

EpsilonParser epsilon() => EpsilonParser();
