import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class CycleRangeParser<R> extends CyclicParser<R> {
  @override
  final List<Parser<R>> children;
  @override
  final num min;
  @override
  final num max;

  @override
  Parser<R> get parser => children[0];

  CycleRangeParser(Parser<R> parser, this.min, this.max) : children = <Parser<R>>[parser];
  CycleRangeParser.empty(this.min, this.max) : children = <Parser<R>>[];

  @override
  CycleRangeParser<R> get empty => CycleRangeParser<R>.empty(min, max);

  @override
  Context<List<R>> parseOn(Context<void> context, ParseHandler handler) {
    List<R> results = <R>[];

    Context<R> ctx = context.empty();
    while (results.length < min) {
      Context<R> inner = handler.parse(parser, ctx);
      if (inner.isFailure) {
        return inner.failure();
      }
      if (inner.isSuccess) {
        results.add(inner.value);
      }
      ctx = inner;
    }
    while (results.length < max) {
      Context<R> inner = handler.parse(parser, ctx);
      if (inner.isFailure) {
        return ctx.success(results);
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
    int position = index;
    int count = 0;
    while (count < min) {
      position = handler.recognize(parser, input, position);
      if (position < 0) {
        return position;
      }
      count++;
    }
    while (count < max) {
      int inner = handler.recognize(parser, input, position);
      if (inner < 0) {
        return position;
      }
      count++;
      position = inner;
    }

    return position;
  }
}

CycleRangeParser<R> _cycleRange<R>(Parser<R> parser, num min, [num? max]) => //
    CycleRangeParser<R>(parser, min, max ?? double.infinity);
Parser<List<R>> cycleRange<R>(Parser<R> parser, num min, [num? max]) => _cycleRange(parser, min, max);

extension ParserCycleRangeExtension<R> on Parser<R> {
  Parser<List<R>> range(num min, [num? max]) => _cycleRange(this, min, max);
}

extension LazyParserCycleRangeExtension<R> on Lazy<Parser<R>> {
  Parser<List<R>> range(num min, [num? max]) => this.reference().range(min, max);
}

extension StringCycleRangeExtension on String {
  Parser<List<String>> range(num min, [num? max]) => this.parser().range(min, max);
}
