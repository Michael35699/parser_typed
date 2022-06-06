import "package:parser_typed/parser.dart";

extension StringParserResolutionExtension on String {
  Parser<String> get $ => StringParser(this);
}
