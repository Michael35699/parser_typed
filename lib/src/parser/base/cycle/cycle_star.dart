import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class CycleStarParser<R> extends CyclicParser<R> with NullableParser {
  @override
  final num min = 0;
  @override
  final num max = double.infinity;

  @override
  final List<Parser<R>> children;

  @override
  Parser<R> get parser => children[0];

  CycleStarParser(Parser<R> parser) : children = <Parser<R>>[parser];
  CycleStarParser.empty() : children = <Parser<R>>[];

  @override
  Context<List<R>> parseOn(Context<void> context, ParseHandler handler) {
    List<R> results = <R>[];
    Context<R> ctx = context.empty();
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
    int position = index;
    while (true) {
      int inner = handler.recognize(parser, input, position);
      if (inner < 0) {
        return position;
      }
      position = inner;
    }
  }

  @override
  CycleStarParser<R> get empty => CycleStarParser<R>.empty();
}

CycleStarParser<R> cycleStar<R>(Parser<R> parser) => CycleStarParser<R>(parser);
Parser<List<R>> _cycleStar<R>(Parser<R> parser) => cycleStar(parser);

extension ParserCycleStarExtension<R> on Parser<R> {
  Parser<List<R>> cycleStar() => _cycleStar(this);
  Parser<List<R>> star() => cycleStar();
}
