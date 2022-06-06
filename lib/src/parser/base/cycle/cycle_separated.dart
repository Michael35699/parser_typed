import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class CycleSeparatedParser<R extends Object?> extends CyclicParser<R> {
  @override
  final num min = 0;
  @override
  late num max = double.infinity;

  @override
  final List<Parser> children;

  @override
  Parser<R> get parser => children[0] as Parser<R>;
  Parser<void> get separator => children[1];

  CycleSeparatedParser(Parser<R> parser, Parser<void> separator) : children = <Parser>[parser, separator];
  CycleSeparatedParser.empty() : children = <Parser>[];

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
      int nextIndex = handler.recognize(separator, ctx.input, ctx.index);
      if (nextIndex < 0) {
        return ctx.success(results);
      }
      Context<R> inner2 = handler.parse(parser, ctx.empty(nextIndex));
      if (inner2.isFailure) {
        return ctx.success(results);
      }
      if (inner2.isSuccess) {
        results.add(inner2.value);
      }

      ctx = inner2;
    }
  }

  @override
  int recognizeOn(String input, int index, ParseHandler handler) {
    int position = handler.recognize(parser, input, index);
    if (position < 0) {
      return position;
    }
    while (true) {
      int pos1 = handler.recognize(separator, input, position);
      if (pos1 < 0) {
        return position;
      }
      int pos2 = handler.recognize(parser, input, pos1);
      if (pos2 < 0) {
        return position;
      }

      position = pos2;
    }
  }

  @override
  CycleSeparatedParser<R> get empty => CycleSeparatedParser<R>.empty();
}

CycleSeparatedParser<R> _cycleSeparated<R>(Parser<R> parser, Parser<void> separator) =>
    CycleSeparatedParser<R>(parser, separator);
Parser<List<R>> cycleSeparated<R>(Parser<R> parser, Parser<void> separator) => _cycleSeparated(parser, separator);

extension ParserCycleSeparatedExtension<R> on Parser<R> {
  Parser<List<R>> cycleSeparated(Object separator) => _cycleSeparated(this, parser(separator));
  Parser<List<R>> separated(Object separator) => cycleSeparated(separator);
  Parser<List<R>> operator %(Object separator) => cycleSeparated(separator);
}

extension LazyParserCycleSeparatedExtension<R> on Lazy<Parser<R>> {
  Parser<List<R>> cycleSeparated(Object separator) => this.reference().separated(separator);
  Parser<List<R>> separated(Object separator) => cycleSeparated(separator);
  Parser<List<R>> operator %(Object separator) => cycleSeparated(separator);
}

extension StringCycleSeparatedExtension on String {
  Parser<List<String>> cycleSeparated(Object separator) => this.parser().separated(separator);
  Parser<List<String>> separated(Object separator) => cycleSeparated(separator);
  Parser<List<String>> operator %(Object separator) => cycleSeparated(separator);
}
