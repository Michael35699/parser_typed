// ignore_for_file: deprecated_member_use_from_same_package

import "package:parser_typed/parser.dart";
import "package:parser_typed/src/handler/packrat/linear/typedef.dart";

class LinearHandler extends Handler {
  @override
  Failure longestFailure = const Failure("Base failure", "", -1);

  @override
  Failure failure(Failure ctx) => longestFailure = _determineFailure(ctx, longestFailure);
  Failure _determineFailure(Failure ctx, Failure? longestFailure) {
    if (longestFailure == null) {
      return ctx;
    }
    const String memoError = "seed";

    if (ctx.message == memoError) {
      return longestFailure;
    } else if (longestFailure.message == memoError) {
      return ctx;
    }

    if (ctx.artificial ^ longestFailure.artificial) {
      return ctx.artificial ? ctx : longestFailure;
    }

    return ctx.index > longestFailure.index ? ctx : longestFailure;
  }

  final ParsingMemoizationMap parsingMap = ParsingMemoizationMap();

  Context<R> parseMemoized<I, R>(Parser<R> parser, Context<I> context) {
    int index = context.index;
    ParsingSubMap subMap = parsingMap[parser] ??= ParsingSubMap.new();
    Context<R>? entry = subMap[index] as Context<R>?;
    if (entry == null) {
      if (parser.leftRecursive) {
        subMap[index] = context.failure("seed");
        Context<R> ctx = subMap[index] = parser.parseOn(context, this);
        if (ctx.isFailure) {
          return ctx;
        }

        while (true) {
          Context<R> inner = parser.parseOn(context, this);
          if (inner.isFailure || inner.index <= ctx.index) {
            return ctx;
          }
          ctx = subMap[index] = inner;
        }
      } else {
        return entry = subMap[index] = parser.parseOn(context, this);
      }
    } else {
      return entry;
    }
  }

  @override
  Context<R> parse<I, R>(Parser<R> parser, Context<I> context) => //
      context.isFailure
          ? context.failure()
          : parser.memoize //
              ? parseMemoized(parser, context)
              : parser.parseOn(context, this);

  final RecognizingMemoizationMap recognizingMap = RecognizingMemoizationMap();

  int recognizeMemoized<R>(Parser<R> parser, String input, int index) {
    RecognizingSubMap subMap = recognizingMap[parser] ??= RecognizingSubMap.new();
    int? saved = subMap[index];

    if (saved == null) {
      if (parser.leftRecursive) {
        subMap[index] = -1;
        int res = subMap[index] = parser.recognizeOn(input, index, this);
        if (res < 0) {
          return res;
        }

        while (true) {
          int inner = parser.recognizeOn(input, index, this);
          if (inner < 0 || inner <= res) {
            return res;
          }
          res = subMap[index] = inner;
        }
      } else {
        return saved = subMap[index] = parser.recognizeOn(input, index, this);
      }
    } else {
      return saved;
    }
  }

  @override
  int recognize<R>(Parser<R> parser, String input, int index) => //
      index < 0
          ? index
          : parser.memoize //
              ? recognizeMemoized(parser, input, index)
              : parser.recognizeOn(input, index, this);
}
