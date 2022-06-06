import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class BetweenParser<R extends Object?> extends CombinatorParser<R, dynamic> with SequentialParser<R, dynamic> {
  @override
  final List<Parser> children;

  Parser<void> get left => children[0];
  Parser<R> get parser => children[1] as Parser<R>;
  Parser<void> get right => children[2];

  BetweenParser(Parser<R> parser, Parser<void> left, Parser<void> right) : children = <Parser>[left, parser, right];
  BetweenParser.empty() : children = <Parser>[];

  @override
  Context<R> parseOn(Context<void> context, Handler handler) {
    Context<void> _left = handler.parse(left, context);
    if (_left.isFailure) {
      return _left.failure();
    }
    Context<R> _parser = handler.parse(parser, _left);
    if (_parser.isFailure) {
      return _parser.failure();
    }
    Context<void> _right = handler.parse(right, _parser);
    if (_right.isFailure) {
      return _right.failure();
    }
    return _right.success(_parser.value);
  }

  @override
  int recognizeOn(String input, int index, Handler handler) {
    int _left = handler.recognize(left, input, index);
    if (_left < 0) {
      return _left;
    }
    int _parser = handler.recognize(parser, input, _left);
    if (_parser < 0) {
      return _parser;
    }
    int _right = handler.recognize(right, input, _parser);
    if (_right < 0) {
      return _right;
    }

    return _right;
  }

  @override
  BetweenParser<R> get empty => BetweenParser<R>.empty();
}

BetweenParser<R> _between<R>(Parser<R> parser, Parser<void> left, Parser<void> right) =>
    BetweenParser<R>(parser, left, right);

Parser<R> between<R extends Object?>(Parser<R> parser, Parser<void> left, Parser<void> right) =>
    _between<R>(parser, left, right);

extension ParserBetweenExtension<R> on Parser<R> {
  Parser<R> between(Object left, Object right) => _between(this, parser(left), parser(right));
}

extension LazyParserBetweenExtension<R> on Lazy<Parser<R>> {
  Parser<R> between(Object left, Object right) => this.reference().between(left, right);
}

extension StringParserBetweenExtension on String {
  Parser<String> between(Object left, Object right) => this.parser().between(left, right);
}
