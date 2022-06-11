import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class OptionalParser<R> extends WrapParser<R?, R> with NullableParser {
  @override
  final List<Parser<R>> children;
  @override
  Parser<R> get parser => children[0];

  OptionalParser(Parser<R> parser) : children = <Parser<R>>[parser];
  OptionalParser.empty() : children = <Parser<R>>[];

  @override
  Context<R?> parseOn(Context<void> context, ParseHandler handler) {
    Context<R> result = handler.parse(parser, context);
    if (result.isFailure) {
      return context.success(null);
    }
    return result;
  }

  @override
  int recognizeOn(String input, int index, ParseHandler handler) {
    int result = handler.recognize(parser, input, index);
    return result < 0 ? index : result;
  }

  @override
  OptionalParser<R> get empty => OptionalParser<R>.empty();
}

OptionalParser<R> _optional<R>(Parser<R> parser) => OptionalParser<R>(parser);
Parser<R?> optional<R>(Parser<R> parser) => _optional(parser);

extension ParserOptionalExtension<R> on Parser<R> {
  Parser<R?> optional() => _optional(this);
}

extension LazyParserOptionalExtension<R> on Lazy<Parser<R>> {
  Parser<R?> optional() => this.reference().optional();
}

extension StringOptionalExtension<R> on String {
  Parser<String?> optional() => this.parser().optional();
}
