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

extension LazyParserTrimExtension<R> on Lazy<Parser<R>> {
  Parser<R> trim() => this.reference().trim();
  Parser<R> trimLeft() => this.reference().trimLeft();
  Parser<R> trimRight() => this.reference().trimRight();

  Parser<R> t() => trim();
  Parser<R> tl() => trimLeft();
  Parser<R> tr() => trimRight();
}

extension StringTrimExtension on String {
  Parser<String> trim() => this.parser().trim();
  Parser<String> trimLeft() => this.parser().trimLeft();
  Parser<String> trimRight() => this.parser().trimRight();

  Parser<String> t() => trim();
  Parser<String> tl() => trimLeft();
  Parser<String> tr() => trimRight();
}
