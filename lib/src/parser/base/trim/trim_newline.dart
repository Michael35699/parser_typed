import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class TrimNewlineParser<R extends Object?> extends TrimmingParser<R> {
  static const String _pattern = r"\s+";

  TrimNewlineParser.complete(Parser<R> parser) : super.complete(parser, _pattern, _pattern);
  TrimNewlineParser.left(Parser<R> parser) : super.left(parser, _pattern);
  TrimNewlineParser.right(Parser<R> parser) : super.right(parser, _pattern);
}

TrimNewlineParser<R> _trimNewline<R>(Parser<R> parser) => TrimNewlineParser<R>.complete(parser);
TrimNewlineParser<R> _trimNewlineLeft<R>(Parser<R> parser) => TrimNewlineParser<R>.left(parser);
TrimNewlineParser<R> _trimNewlineRight<R>(Parser<R> parser) => TrimNewlineParser<R>.right(parser);

Parser<R> trimNewline<R extends Object?>(Parser<R> parser) => _trimNewline(parser);
Parser<R> trimNewlineLeft<R extends Object?>(Parser<R> parser) => _trimNewlineLeft(parser);
Parser<R> trimNewlineRight<R extends Object?>(Parser<R> parser) => _trimNewlineRight(parser);

extension ParserTrimNewlineExtension<R> on Parser<R> {
  Parser<R> trimNewline() => _trimNewline(this);
  Parser<R> trimNewlineLeft() => _trimNewlineLeft(this);
  Parser<R> trimNewlineRight() => _trimNewlineRight(this);

  Parser<R> tnl() => trimNewline();
  Parser<R> tnlL() => trimNewlineLeft();
  Parser<R> tnlR() => trimNewlineRight();
}

extension LazyParserTrimNewlineExtension<R> on Lazy<Parser<R>> {
  Parser<R> trimNewline() => this.reference().trimNewline();
  Parser<R> trimNewlineLeft() => this.reference().trimNewlineLeft();
  Parser<R> trimNewlineRight() => this.reference().trimNewlineRight();

  Parser<R> tnl() => trimNewline();
  Parser<R> tnlL() => trimNewlineLeft();
  Parser<R> tnlR() => trimNewlineRight();
}

extension StringTrimNewlineExtension on String {
  Parser<String> trimNewline() => this.parser().trimNewline();
  Parser<String> trimNewlineLeft() => this.parser().trimNewlineLeft();
  Parser<String> trimNewlineRight() => this.parser().trimNewlineRight();

  Parser<String> tnl() => trimNewline();
  Parser<String> tnlL() => trimNewlineLeft();
  Parser<String> tnlR() => trimNewlineRight();
}
