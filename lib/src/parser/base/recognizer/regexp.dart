import "package:parser_typed/parser.dart";

class RegExpParser extends PrimitiveParser with ChildlessParser {
  static final Map<String, RegExpParser> _savedParsers = <String, RegExpParser>{};

  final RegExp pattern;

  factory RegExpParser.generate(
    String pattern, {
    bool multiLine = false,
    bool caseSensitive = true,
    bool unicode = false,
    bool dotAll = false,
  }) =>
      _savedParsers[pattern] ??= RegExpParser.fromString(
        pattern,
        multiLine: multiLine,
        caseSensitive: caseSensitive,
        unicode: unicode,
        dotAll: dotAll,
      );

  RegExpParser.fromString(
    String pattern, {
    bool multiLine = false,
    bool caseSensitive = true,
    bool unicode = false,
    bool dotAll = false,
  }) : pattern = RegExp(
          pattern,
          multiLine: multiLine,
          caseSensitive: caseSensitive,
          unicode: unicode,
          dotAll: dotAll,
        );

  @override
  Context<int> call(String input, int index, ParseHandler handler) {
    Match? match = pattern.matchAsPrefix(input, index);
    if (match != null) {
      return succeed(match.end);
    }

    return fail("Expected '$pattern'");
  }

  @override
  String toString() => "regex[/${pattern.pattern}/]";
}

RegExpParser regex(
  String pattern, {
  bool multiLine = false,
  bool caseSensitive = true,
  bool unicode = false,
  bool dotAll = false,
}) =>
    RegExpParser.generate(
      pattern,
      multiLine: multiLine,
      caseSensitive: caseSensitive,
      unicode: unicode,
      dotAll: dotAll,
    );

extension StringRegExpExtension on String {
  PrimitiveParser r() => RegExpParser.generate(this);

  PrimitiveParser regex({
    bool multiLine = false,
    bool caseSensitive = true,
    bool unicode = false,
    bool dotAll = false,
  }) =>
      RegExpParser.generate(
        this,
        multiLine: multiLine,
        caseSensitive: caseSensitive,
        unicode: unicode,
        dotAll: dotAll,
      );
}
