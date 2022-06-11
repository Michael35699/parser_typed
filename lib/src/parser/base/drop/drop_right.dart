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
  Parser<R> dropRight(Object right) => _dropRight(this, parser(right));
  Parser<R> suffix(Object right) => dropRight(right);

  Parser<R> operator <<(Object right) => dropRight(right);
}

extension LazyParserDropRightExtension<R> on Lazy<Parser<R>> {
  Parser<R> dropRight(Object right) => this.reference().dropRight(right);
  Parser<R> suffix(Object right) => dropRight(right);

  Parser<R> operator <<(Object right) => dropRight(right);
}

extension StringDropRightExtension on String {
  Parser<String> dropRight(Object right) => this.parser().dropRight(right);
  Parser<String> suffix(Object right) => dropRight(right);

  Parser<String> operator <<(Object right) => dropRight(right);
}
