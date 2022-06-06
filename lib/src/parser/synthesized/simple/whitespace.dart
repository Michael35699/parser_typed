import "package:parser_typed/parser.dart";

const Set<int> _newlineWhitespace = <int>{
  0x0009,
  0x000A, // line-break
  0x000B, // line-break
  0x000C, // line-break
  0x000D,
  0x0020,
  0x0085, // line-break
  0x00A0,
  0x1680,
  0x2000,
  0x2001,
  0x2002,
  0x2003,
  0x2004,
  0x2005,
  0x2006,
  0x2007,
  0x2008,
  0x2009,
  0x200A,
  0x2028, // line-break
  0x2029, // line-break
  0x202F,
  0x205F,
  0x3000,
};
const Set<int> _whitespace = <int>{
  0x0009,
  // 0x000A, // line-break
  // 0x000B, // line-break
  // 0x000C, // line-break
  0x000D,
  0x0020,
  // 0x0085, // line-break
  0x00A0,
  0x1680,
  0x2000,
  0x2001,
  0x2002,
  0x2003,
  0x2004,
  0x2005,
  0x2006,
  0x2007,
  0x2008,
  0x2009,
  0x200A,
  // 0x2028, // line-break
  // 0x2029, // line-break
  0x202F,
  0x205F,
  0x3000,
};

PrimitiveParser _whitespaceGenerator(Set<int> matches) =>
    recognizer((String input, int index, RecognizeSuccess success, RecognizeFailure failure) {
      int position = index;
      while (position < input.length && matches.contains(input.codeUnitAt(position))) {
        position++;
      }
      if (position == index) {
        return failure("Expected whitespace");
      }
      return success(position);
    });

PrimitiveParser whitespace() => _whitespaceGenerator(_whitespace);
PrimitiveParser newlineWhitespace() => _whitespaceGenerator(_newlineWhitespace);
