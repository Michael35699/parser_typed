import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class FlatParser<R extends Object?> extends PrimitiveParser with WrapTransform<String> {
  @override
  final List<Parser<R>> children;
  @override
  Parser<R> get parser => children[0];

  FlatParser(Parser<R> parser) : children = <Parser<R>>[parser];
  FlatParser.empty() : children = <Parser<R>>[];

  @override
  Context<int> call(String input, int index, Handler handler) {
    int end = handler.recognize(parser, input, index);
    if (end < 0) {
      return fail("Flat failure. If this is seen, then it is recommended "
          "that an error message is attached via the `.failure` method.");
    }
    return succeed(end);
  }

  @override
  FlatParser<R> get empty => FlatParser<R>.empty();

  @override
  Parser get base => parser;
}

FlatParser<R> _flat<R>(Parser<R> parser) => FlatParser<R>(parser);
Parser<String> flat<R>(Parser<R> parser) => _flat(parser);

extension ParserFlatExtension<R> on Parser<R> {
  Parser<String> flat() => _flat(this);
}

extension LazyParserFlatExtension<R> on Lazy<Parser<R>> {
  Parser<String> flat() => this.reference().flat();
}

extension StringParserFlatExtension on String {
  Parser<String> flat() => this.parser().flat();
}
