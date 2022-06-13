import "package:parser_typed/parser.dart";

typedef JsonValue = Object?;
typedef JsonMap = Map<String, JsonValue>;
typedef JsonMapEntry = MapEntry<String, JsonValue>;

Parser jsonParser() {
  Parser<dynamic> reflection = BlankParser<Object?>.generate();

  Parser<void> nullParser = string("null").map((_) {});
  Parser<bool> trueParser = string("true").map((_) => true);
  Parser<bool> falseParser = string("false").map((_) => false);
  Parser<num> numberParser = <Parser>[
    string("-").optional(),
    digits(),
    (string(".") & digits()).optional(),
    (string("e") & (string("+") | string("-")).optional() & digits()).optional(),
  ].sequence().flat().map(num.parse).message("Expected a number");

  Parser<String> stringParser = ((r"\".parser() >> any() | '"'.parser().not() >> any()).star())
      .flat()
      .message("Expected a string literal")
      .between(string('"'), string('"'));

  Parser<List<JsonValue>> arrayParser = (reflection.separated(string(",").tnl())) //
      .failure(<dynamic>[]) //
      .between(string("[").tnl(), string("]").tnl());

  Parser<JsonMap> objectParser = (stringParser & string(":").tnl() & reflection)
      .map((List<dynamic> result) => JsonMapEntry(result[0] as String, result[2]))
      .separated(string(",").tnl()) //
      .map(JsonMap.fromEntries)
      .between(string("{").tnl(), string("}").tnl());

  Parser<JsonValue> valueParser = nullParser / trueParser |
      falseParser / numberParser | //
      stringParser / arrayParser |
      objectParser;

  return valueParser.replace(reflection, valueParser).build().end();
}
