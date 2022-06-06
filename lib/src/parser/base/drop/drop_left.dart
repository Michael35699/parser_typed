import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class DropLeftParser<R extends Object?> extends CombinatorParser<R, dynamic> with SequentialParser<R, dynamic> {
  @override
  final List<Parser> children;

  Parser<void> get left => children[0];
  Parser<R> get parser => children[1] as Parser<R>;

  DropLeftParser(Parser<void> left, Parser<R> parser) : children = <Parser>[left, parser];
  DropLeftParser.empty() : children = <Parser>[];

  @override
  Context<R> parseOn(Context<void> context, ParseHandler handler) {
    Context<void> _left = handler.parse(left, context);
    if (_left.isFailure) {
      return _left.failure();
    }
    return handler.parse(parser, _left);
  }

  @override
  int recognizeOn(String input, int index, ParseHandler handler) {
    int _left = handler.recognize(left, input, index);
    if (_left < 0) {
      return _left;
    }
    return handler.recognize(parser, input, _left);
  }

  @override
  DropLeftParser<R> get empty => DropLeftParser<R>.empty();
}

DropLeftParser<R> _dropLeft<R>(Parser<void> left, Parser<R> parser) => DropLeftParser<R>(left, parser);

extension ParserDropLeftExtension<R> on Parser<R> {
  Parser<R> dropLeft(Object left) => _dropLeft(parser(left), this);
  Parser<R> prefix(Object left) => dropLeft(left);

  Parser<Object?> operator >>(Object self) => parser(self).dropLeft(this);
}

extension LazyParserDropLeftExtension<R> on Lazy<Parser<R>> {
  Parser<R> dropLeft(Object left) => this.reference().dropLeft(left);
  Parser<R> prefix(Object left) => dropLeft(left);

  Parser<Object?> operator >>(Object self) => parser(self).dropLeft(this);
}

extension StringDropLeftExtension on String {
  Parser<String> dropLeft(Object left) => this.parser().dropLeft(left);
  Parser<String> prefix(Object left) => dropLeft(left);

  Parser<Object?> operator >>(Object self) => parser(self).dropLeft(this);
}
