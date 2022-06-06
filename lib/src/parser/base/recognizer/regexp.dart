import "package:parser_typed/parser.dart";

class RegExpParser extends PrimitiveParser with ChildlessParser {
  static final Map<String, RegExpParser> _savedParsers = <String, RegExpParser>{};

  final RegExp pattern;

  factory RegExpParser(String pattern) => _savedParsers[pattern] ??= RegExpParser.fromString(pattern);
  RegExpParser.fromString(String pattern) : pattern = RegExp(pattern);

  @override
  Context<int> call(String input, int index, Handler handler) {
    Match? match = pattern.matchAsPrefix(input, index);
    if (match != null) {
      return succeed(match.end);
    }

    return fail("Expected '$pattern'");
  }

  @override
  String toString() => "regex[/${pattern.pattern}/]";
}

RegExpParser regex(String pattern) => RegExpParser(pattern);

extension StringRegExpExtension on String {
  PrimitiveParser r() => RegExpParser(this);
  PrimitiveParser regex() => RegExpParser(this);
}
