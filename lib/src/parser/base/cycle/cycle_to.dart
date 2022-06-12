import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class CycleToParser<R> extends CyclicParser<R> {
  @override
  final num min = 0;
  @override
  late num max = double.infinity;

  @override
  final List<Parser> children;

  @override
  Parser<R> get parser => children[0] as Parser<R>;
  Parser<void> get delimiter => children[1];

  CycleToParser(Parser<R> parser, Parser<void> delimiter) : children = <Parser>[parser, delimiter];
  CycleToParser.empty() : children = <Parser>[];

  @override
  Context<List<R>> parseOn(Context<void> context, ParseHandler handler) {
    String input = context.input;

    List<R> results = <R>[];
    Context<R> ctx = context.empty();
    if (handler.recognize(delimiter, input, context.index) > 0) {
      return context.failure("Unexpected delimiter.");
    }

    ctx = handler.parse(parser, ctx);
    if (ctx.isFailure) {
      return ctx.failure();
    }
    if (ctx.isSuccess) {
      results.add(ctx.value);
    }

    while (true) {
      if (handler.recognize(delimiter, input, ctx.index) > 0) {
        return ctx.success(results);
      }

      Context<R> inner = handler.parse(parser, ctx);
      if (inner.isFailure) {
        return ctx.success(results);
      }
      if (inner.isSuccess) {
        results.add(inner.value);
      }

      ctx = inner;
    }
  }

  @override
  int recognizeOn(String input, int index, ParseHandler handler) {
    if (handler.recognize(delimiter, input, index) > 0) {
      return -1;
    }
    int position = handler.recognize(parser, input, index);
    if (position < 0) {
      return position;
    }
    while (true) {
      if (handler.recognize(delimiter, input, position) > 0) {
        return position;
      }
      int inner = handler.recognize(parser, input, position);
      if (inner < 0) {
        return position;
      }

      position = inner;
    }
  }

  @override
  CycleToParser<R> get empty => CycleToParser<R>.empty();
}

CycleToParser<R> _cycleTo<R>(Parser<R> parser, Parser<void> delimiter) => CycleToParser<R>(parser, delimiter);
Parser<List<R>> cycleTo<R>(Parser<R> parser, Parser<void> delimiter) => _cycleTo(parser, delimiter);

extension ParserCycleToExtension<R> on Parser<R> {
  Parser<List<R>> cycleTo(Parser delimiter) => _cycleTo(this, parser(delimiter));
  Parser<List<R>> to(Parser delimiter) => cycleTo(delimiter);
}
