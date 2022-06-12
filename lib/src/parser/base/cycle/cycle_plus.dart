import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class CyclePlusParser<R> extends CyclicParser<R> {
  @override
  final num min = 1;
  @override
  final num max = double.infinity;

  @override
  final List<Parser<R>> children;

  @override
  Parser<R> get parser => children[0];

  CyclePlusParser(Parser<R> parser) : children = <Parser<R>>[parser];
  CyclePlusParser.empty() : children = <Parser<R>>[];

  @override
  Context<List<R>> parseOn(Context<void> context, ParseHandler handler) {
    Context<R> ctx = handler.parse(parser, context);
    if (ctx.isFailure) {
      return ctx.failure();
    }
    List<R> results = <R>[];
    if (ctx.isSuccess) {
      results.add(ctx.value);
    }
    while (true) {
      Context<R> inner = handler.parse(parser, ctx);
      if (inner.isFailure) {
        return ctx.success(results);
      }
      ctx = inner;
      if (ctx.isSuccess) {
        results.add(ctx.value);
      }
    }
  }

  @override
  int recognizeOn(String input, int index, ParseHandler handler) {
    int position = handler.recognize(parser, input, index);
    if (position < 0) {
      return position;
    }
    while (true) {
      int inner = handler.recognize(parser, input, position);
      if (inner < 0) {
        return position;
      }
      position = inner;
    }
  }

  @override
  CyclePlusParser<R> get empty => CyclePlusParser<R>.empty();
}

CyclePlusParser<R> _cyclePlus<R>(Parser<R> parser) => CyclePlusParser<R>(parser);
Parser<List<R>> cyclePlus<R>(Parser<R> parser) => _cyclePlus(parser);

extension ParserCyclePlusExtension<R> on Parser<R> {
  Parser<List<R>> cyclePlus() => _cyclePlus(this);
  Parser<List<R>> plus() => cyclePlus();
}
