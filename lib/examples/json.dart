import "package:parser_typed/parser.dart";

typedef JsonValue = Object?;
typedef JsonMap = Map<String, JsonValue>;
typedef JsonMapEntry = MapEntry<String, JsonValue>;

Parser jsonParser() {
  Parser reflection = BlankParser<Object?>.generate();

  // ignore: prefer_void_to_null
  Parser<Null> nullParser = string("null").map((_) => null);
  Parser<bool> trueParser = string("true").map((_) => true);
  Parser<bool> falseParser = string("false").map((_) => false);
  Parser<num> numberParser = (string("-").optional() &
          digits() &
          (string(".") & digits()).optional() &
          (string("e") & (string("-") | string("+")).optional() & digits()).optional())
      .flat()
      .map(num.parse)
      .message("Expected a number");

  Parser<String> stringParser = (((r"\") >> any() | '"'.not() >> any()).star())
      .flat()
      .message("Expected a string literal")
      .between(string('"'), string('"'));

  Parser<List<dynamic>> arrayParser = (reflection.separated(string(",").tnl())) //
      .failure(<dynamic>[]) //
      .between(string("[").tnl(), string("]").tnl());

  Parser<JsonMap> objectParser = (stringParser & string(":").tnl() & reflection)
      .map((List<dynamic> result) => JsonMapEntry(result[0] as String, result[2]))
      .separated(string(",").tnl()) //
      .map(JsonMap.fromEntries)
      .between(string("{").tnl(), string("}").tnl());

  Parser valueParser = nullParser / trueParser |
      falseParser / numberParser | //
      stringParser / arrayParser |
      objectParser;

  return valueParser.replace(reflection, valueParser).build();
}
