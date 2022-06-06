import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class OnSuccessParser<R extends Object?, O extends Object?> extends WrapParser<R, O> with PassRecognizer {
  @override
  final List<Parser<O>> children;
  final R value;
  @override
  Parser<O> get parser => children[0];

  OnSuccessParser(Parser<O> parser, this.value) : children = <Parser<O>>[parser];
  OnSuccessParser.empty(this.value) : children = <Parser<O>>[];

  @override
  Context<R> parseOn(Context<void> context, Handler handler) {
    Context<O> result = handler.parse(parser, context);

    return result.isSuccess //
        ? result.success(value)
        : result.cast();
  }

  @override
  OnSuccessParser<R, O> get empty => OnSuccessParser<R, O>.empty(value);
}

OnSuccessParser<R, O> _success<R, O>(Parser<O> parser, R value) => OnSuccessParser<R, O>(parser, value);
// OnSuccessParser<R, O> success<R, O>(Parser<O> parser, R value) => _success(parser, value);

extension ParserOnSuccessExtension<O> on Parser<O> {
  Parser<R> success<R extends Object?>(R value) => _success(this, value);
}

extension LazyParserOnSuccessExtension<O> on Lazy<Parser<O>> {
  Parser<R> success<R extends Object?>(R value) => this.reference().success(value);
}

extension StringOnSuccessExtension on String {
  Parser<R> success<R extends Object?>(R value) => this.parser().success(value);
}
