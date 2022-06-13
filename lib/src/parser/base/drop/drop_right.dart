import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class DropRightParser<R> extends CombinatorParser<R, dynamic> with SequentialParser<R, dynamic> {
  @override
  final List<Parser> children;

  Parser<R> get parser => children[0] as Parser<R>;
  Parser<void> get right => children[1];

  DropRightParser(Parser<R> parser, Parser<void> right) : children = <Parser>[parser, right];
  DropRightParser.empty() : children = <Parser>[];

  @override
  Context<R> parseOn(Context<void> context, ParseHandler handler) {
    Context<R> _parser = handler.parse(parser, context);
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
  int recognizeOn(String input, int index, ParseHandler handler) {
    int _parser = handler.recognize(parser, input, index);
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
  DropRightParser<R> get empty => DropRightParser<R>.empty();
}

DropRightParser<R> _dropRight<R>(Parser<R> parser, Parser<void> right) => DropRightParser<R>(parser, right);

extension ParserDropRightExtension<R> on Parser<R> {
  Parser<R> dropRight(Parser right) => _dropRight(this, right);
  Parser<R> suffix(Parser right) => dropRight(right);
  Parser<R> postfix(Parser right) => dropRight(right);

  Parser<R> operator <<(Parser right) => dropRight(right);
}
