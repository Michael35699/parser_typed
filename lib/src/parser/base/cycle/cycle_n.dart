import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class CycleNParser<R> extends CyclicParser<R> {
  @override
  late final num min = count;
  @override
  late final num max = count;
  final int count;

  @override
  final List<Parser<R>> children;

  @override
  Parser<R> get parser => children[0];

  CycleNParser(Parser<R> parser, this.count) : children = <Parser<R>>[parser];
  CycleNParser.empty(this.count) : children = <Parser<R>>[];

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
    for (int i = 1; i < count; i++) {
      Context<R> inner = handler.parse(parser, ctx);
      if (inner.isFailure) {
        return inner.failure();
      }
      if (inner.isSuccess) {
        results.add(inner.value);
      }
      ctx = inner;
    }

    return ctx.success(results);
  }

  @override
  int recognizeOn(String input, int index, ParseHandler handler) {
    int position = handler.recognize(parser, input, index);
    if (position < 0) {
      return position;
    }
    for (int i = 1; i < count; i++) {
      position = handler.recognize(parser, input, position);
      if (position < 0) {
        break;
      }
    }
    return position;
  }

  @override
  CycleNParser<R> get empty => CycleNParser.empty(count);
}

CycleNParser<R> _cycleN<R>(Parser<R> parser, int count) => CycleNParser<R>(parser, count);
Parser<List<R>> cycleN<R>(Parser<R> parser, int count) => _cycleN(parser, count);

extension ParserCycleNExtension<R> on Parser<R> {
  Parser<List<R>> cycleN(int count) => _cycleN(this, count);
  Parser<List<R>> n(int count) => cycleN(count);
  Parser<List<R>> times(int count) => cycleN(count);
  Parser<List<R>> operator *(int count) => cycleN(count);
}
