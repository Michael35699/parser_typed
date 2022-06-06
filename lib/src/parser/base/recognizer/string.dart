import "package:parser_typed/parser.dart";

class StringParser extends PrimitiveParser with NonNullableParser, ChildlessParser {
  static final Map<String, StringParser> _savedParsers = <String, StringParser>{};

  final String pattern;

  factory StringParser(String pattern) => _savedParsers[pattern] ??= StringParser._(pattern);
  StringParser._(this.pattern);

  @override
  Context<int> call(String input, int index, Handler handler) {
    if (index >= 0 && pattern.matchAsPrefix(input, index) != null) {
      return succeed(index + pattern.length);
    }

    return fail("Expected '$pattern'");
  }

  @override
  String toString() => "string['$pattern']";
}

// StringParser string(String pattern) => StringParser(pattern);

extension StringStringParserExtension on String {
  PrimitiveParser parser() => StringParser(this);
  PrimitiveParser p() => StringParser(this);
}
