import "package:parser_typed/parser.dart";

typedef JsonValue = Object?;
typedef JsonMap = Map<String, JsonValue>;
typedef JsonMapEntry = MapEntry<String, JsonValue>;

Parser jsonParser() {
  Parser<dynamic> reflection = BlankParser<Object?>.generate();

  Parser<void> nullParser = string("null").success(null);
  Parser<bool> trueParser = string("true").success(true);
  Parser<bool> falseParser = string("false").success(false);
  Parser<num> numberParser = (string("-").optional() &
          digits() &
          (string(".") & digits()).optional() &
          (string("e") & (string("+") | string("-")).optional() & digits()).optional())
      .flat()
      .map(num.parse)
      .message("Expected a number");

  Parser<String> stringParser = ((r"\".parser() >> any() | '"'.parser().not() >> any()).star())
      .flat()
      .message("Expected a string literal")
      .between(string('"'), string('"'));

  Parser<List<JsonValue>> arrayParser = (reflection.separated(string(",").tnl())) //
      .failure(<dynamic>[]) //
      .between(string("[").tnl(), string("]").tnl());

  Parser<JsonMap> objectParser = (stringParser & string(":").tnl() & reflection)
      .action<JsonMapEntry>((String key, void _, JsonValue value) => JsonMapEntry.new(key, value))
      .separated(string(",").tnl()) //
      .map(JsonMap.fromEntries)
      .failure(JsonMap.new())
      .between(string("{").tnl(), string("}").tnl());

  Parser<JsonValue> valueParser = nullParser |
      trueParser |
      falseParser |
      numberParser | //
      stringParser |
      arrayParser |
      objectParser;

  return valueParser.replace(reflection, valueParser).build().end();
}
