import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class NegativeLookaheadParser<R extends Object?> extends WrapParser<void, R> {
  @override
  final List<Parser<R>> children;
  @override
  Parser<R> get parser => children[0];

  NegativeLookaheadParser(Parser<R> parser) : children = <Parser<R>>[parser];
  NegativeLookaheadParser.empty() : children = <Parser<R>>[];

  @override
  Context<void> parseOn(Context<void> context, Handler handler) {
    if (handler.recognize(parser, context.input, context.index) < 0) {
      return context.success(null);
    }
    return context.failure("Negative lookahead failure");
  }

  @override
  int recognizeOn(String input, int index, Handler handler) => //
      handler.recognize(parser, input, index) >= 0 ? -1 : index;

  @override
  NegativeLookaheadParser<R> get empty => NegativeLookaheadParser<R>.empty();
}

NegativeLookaheadParser<R> _negativeLookahead<R>(Parser<R> parser) => NegativeLookaheadParser<R>(parser);
Parser<void> not<R>(Parser<R> parser) => _negativeLookahead(parser);

extension ParserNegativeLookaheadExtension<R> on Parser<R> {
  Parser<void> negativeLookahead() => _negativeLookahead(this);
  Parser<void> not() => negativeLookahead();
  Parser<void> operator ~() => negativeLookahead();
}

extension LazyParserNegativeLookaheadExtension<R> on Lazy<Parser<R>> {
  Parser<void> negativeLookahead() => this.reference().negativeLookahead();
  Parser<void> not() => negativeLookahead();
  Parser<void> operator ~() => negativeLookahead();
}

extension StringNegativeLookaheadExtension on String {
  Parser<void> negativeLookahead() => this.parser().negativeLookahead();
  Parser<void> not() => negativeLookahead();
  Parser<void> operator ~() => negativeLookahead();
}
