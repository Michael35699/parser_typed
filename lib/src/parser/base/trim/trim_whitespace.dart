// import "package:parser_typed/parser.dart";

// import "package:parser_typed/src/parser/base/trim/trim.dart";

import "package:parser_typed/parser.dart";

class TrimParser<R> extends TrimmingParser<R> {
  static const String _pattern = r"(?:(?!\n)\s)+";

  TrimParser.complete(Parser<R> parser) : super.complete(parser, _pattern, _pattern);
  TrimParser.left(Parser<R> parser) : super.left(parser, _pattern);
  TrimParser.right(Parser<R> parser) : super.right(parser, _pattern);
}

TrimParser<R> _trim<R>(Parser<R> parser) => TrimParser<R>.complete(parser);
TrimParser<R> _trimLeft<R>(Parser<R> parser) => TrimParser<R>.left(parser);
TrimParser<R> _trimRight<R>(Parser<R> parser) => TrimParser<R>.right(parser);

Parser<R> trim<R>(Parser<R> parser) => _trim(parser);
Parser<R> trimLeft<R>(Parser<R> parser) => _trimLeft(parser);
Parser<R> trimRight<R>(Parser<R> parser) => _trimRight(parser);

extension ParserTrimExtension<R> on Parser<R> {
  Parser<R> trim() => _trim(this);
  Parser<R> trimLeft() => _trimLeft(this);
  Parser<R> trimRight() => _trimRight(this);

  Parser<R> t() => trim();
  Parser<R> tl() => trimLeft();
  Parser<R> tr() => trimRight();
}
