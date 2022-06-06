import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class ExceptParser<R extends Object?> extends WrapParser<R, R> {
  @override
  final List<Parser> children;
  Parser<void> get delimiter => children[0];
  @override
  Parser<R> get parser => children[1] as Parser<R>;

  ExceptParser(Parser<R> parser, Parser<void> delimiter) : children = <Parser>[delimiter, parser];
  ExceptParser.empty() : children = <Parser>[];

  @override
  Context<R> parseOn(Context<void> context, ParseHandler handler) {
    int delimit = handler.recognize(delimiter, context.input, context.index);

    return delimit > -1 //
        ? context.failure("Unexpected delimiter")
        : handler.parse(parser, context);
  }

  @override
  int recognizeOn(String input, int index, ParseHandler handler) =>
      handler.recognize(delimiter, input, index) > -1 ? -1 : handler.recognize(parser, input, index);

  @override
  ExceptParser<R> get empty => ExceptParser<R>.empty();
}

ExceptParser<R> _except<R>(Parser<R> parser, Parser<void> delimiter) => ExceptParser<R>(parser, delimiter);
ExceptParser<R> except<R extends Object?>(Parser<R> parser, Parser<void> delimiter) => _except(parser, delimiter);

extension ParserExceptExtension<R> on Parser<R> {
  Parser<R> except(Parser<void> delimiter) => _except(this, delimiter);
}

extension LazyParserExceptExtension<R> on Lazy<Parser<R>> {
  Parser<R> except(Parser<void> delimiter) => this.reference().except(delimiter);
}

extension StringExceptExtension on String {
  Parser<String> except(Parser<void> delimiter) => this.parser().except(delimiter);
}
