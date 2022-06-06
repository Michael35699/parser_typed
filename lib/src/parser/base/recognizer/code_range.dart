import "package:parser_typed/parser.dart";

class CodeRangeParser extends PrimitiveParser with NonNullableParser, ChildlessParser {
  final int low;
  final int high;

  CodeRangeParser(this.low, this.high);
  CodeRangeParser.fromString(String low, String high)
      : low = low.codeUnitAt(0),
        high = high.codeUnitAt(0);

  @override
  Context<int> call(String input, int index, Handler handler) {
    if (index < input.length) {
      int code = input.codeUnitAt(index);
      if (low <= code && code <= high) {
        return succeed(index + 1);
      }
    }
    return fail("Expected unit within '[$low-$high]'");
  }

  @override
  String toString() => "code_range[$low-$high]";
}

CodeRangeParser _unicodeRange(String low, String high) => CodeRangeParser.fromString(low, high);
CodeRangeParser urng(String low, String high) => _unicodeRange(low, high);

extension StringCodeRangeExtension on String {
  PrimitiveParser urng(String high) => _unicodeRange(this, high);
  PrimitiveParser operator >>>(String high) => _unicodeRange(this, high);
}
