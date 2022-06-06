import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class PositiveLookaheadParser<R extends Object?> extends WrapParser<void, R> {
  @override
  final List<Parser<R>> children;
  @override
  Parser<R> get parser => children[0];

  PositiveLookaheadParser(Parser<R> parser) : children = <Parser<R>>[parser];
  PositiveLookaheadParser.empty() : children = <Parser<R>>[];

  @override
  Context<void> parseOn(Context<void> context, ParseHandler handler) {
    if (handler.recognize(parser, context.input, context.index) >= 0) {
      return context.success(null);
    }
    return context.failure("Positive lookahead failure");
  }

  @override
  int recognizeOn(String input, int index, ParseHandler handler) => //
      handler.recognize(parser, input, index) >= 0 ? index : -1;

  @override
  PositiveLookaheadParser<R> get empty => PositiveLookaheadParser<R>.empty();
}

PositiveLookaheadParser<R> _positiveLookahead<R>(Parser<R> parser) => PositiveLookaheadParser<R>(parser);
Parser<void> and<R>(Parser<R> parser) => _positiveLookahead(parser);

extension ParserPositiveLookaheadExtension<R> on Parser<R> {
  Parser<void> positiveLookahead() => _positiveLookahead(this);
  Parser<void> and() => positiveLookahead();
}

extension LazyParserPositiveLookaheadExtension<R> on Lazy<Parser<R>> {
  Parser<void> positiveLookahead() => this.reference().positiveLookahead();
  Parser<void> and() => positiveLookahead();
}

extension StringPositiveLookaheadExtension on String {
  Parser<void> positiveLookahead() => this.parser().positiveLookahead();
  Parser<void> and() => positiveLookahead();
}
