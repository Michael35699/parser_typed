// ignore_for_file: deprecated_member_use_from_same_package

import "dart:collection";

import "package:parser_typed/src/context.dart";
import "package:parser_typed/src/handler/abstract/handler.dart";
import "package:parser_typed/src/handler/packrat/quadratic/classes.dart";
import "package:parser_typed/src/handler/packrat/quadratic/typedef.dart";
import "package:parser_typed/src/parser.dart";

int index = 0;

extension on int {
  RecognizingMemoizationEntry entry() => RecognizingMemoizationEntry(this);
}

extension on Context<dynamic> {
  ParsingMemoizationEntry entry() => ParsingMemoizationEntry(this);
}

extension on ParsingLeftRecursion {
  ParsingMemoizationEntry entry() => ParsingMemoizationEntry(this);
}

extension on RecognizingLeftRecursion {
  RecognizingMemoizationEntry entry() => RecognizingMemoizationEntry(this);
}

class QuadraticHandler extends Handler {
  @override
  Failure longestFailure = const Failure("Base failure", "", -1);

  @override
  Failure failure(Failure ctx) => (longestFailure = _determineFailure(ctx, longestFailure)).failure();
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

  final Map<int, Head> heads = <int, Head>{};

  final ParsingMemoizationMap parserMemoizationMap = ParsingMemoizationMap();
  final Queue<ParsingLeftRecursion> parsingCallStack = Queue<ParsingLeftRecursion>();

  ParsingMemoizationEntry? parseRecall<I, R>(Parser<R> parser, int index, Context<I> context) {
    ParsingMemoizationEntry? entry = (parserMemoizationMap[parser] ??= ParsingSubMap.new())[index];
    Head? head = heads[index];

    // If the head is not being grown, return the memoized result.
    if (head == null || !head.evaluationSet.contains(parser)) {
      return entry;
    }

    // If the current parser is not a part of the head and is not evaluated yet,
    // Add a failure to it.
    if (entry == null || !<Parser>{...head.involvedSet, head.parser}.contains(parser)) {
      return context.failure("seed").entry();
    }

    // Remove the current parser from the head's evaluation set.
    head.evaluationSet.remove(parser);
    entry.value = parser.parseOn(context, this);

    return entry;
  }

  Context<R> parseLeftRecursiveResult<R extends Object?>(Parser<R> parser, int index, ParsingMemoizationEntry entry) {
    ParsingLeftRecursion<R> leftRecursion = entry.value as ParsingLeftRecursion<R>;
    Head<Object?> head = leftRecursion.head!;
    Context<R> seed = leftRecursion.seed;

    /// If the rule of the parser is not the one being parsed,
    /// return the seed.
    if (head.parser != parser) {
      return seed;
    }

    /// Since it is the parser, assign it to the seed.
    Context<R> seedContext = entry.value = seed;
    if (seedContext.isFailure) {
      return seedContext;
    }

    heads[index] = head;

    /// "Grow the seed."
    for (;;) {
      head.evaluationSet.addAll(head.involvedSet);
      Context<R> result = parser.parseOn(seedContext.empty(index), this);
      if (result.isFailure || result.index <= seedContext.index) {
        break;
      }
      entry.value = result;
    }
    heads.remove(index);

    return entry.value as Context<R>;
  }

  Context<R> parseMemoized<I, R>(Parser<R> parser, Context<I> context) {
    int index = context.index;

    ParsingMemoizationEntry? entry = parseRecall(parser, index, context);
    if (entry == null) {
      ParsingSubMap subMap = parserMemoizationMap[parser] ??= ParsingSubMap.new();
      if (parser.isTerminal || !parser.leftRecursive) {
        Context<R> ans = parser.parseOn(context, this);
        subMap[index] = ans.entry();

        return ans;
      } else {
        ParsingLeftRecursion<R> leftRecursion = ParsingLeftRecursion<R>(
          seed: context.failure("seed"),
          parser: parser,
          head: null,
        );

        parsingCallStack.addFirst(leftRecursion);

        entry = subMap[index] = leftRecursion.entry();
        Context<R> ans = parser.parseOn(context, this);

        parsingCallStack.removeFirst();

        if (leftRecursion.head != null) {
          leftRecursion.seed = ans;

          return parseLeftRecursiveResult(parser, index, entry);
        } else {
          entry.value = ans;

          return ans;
        }
      }
    } else {
      Object result = entry.value;

      if (result is ParsingLeftRecursion<R>) {
        Head head = result.head ??= Head<R>(parser: parser, evaluationSet: <Parser>{}, involvedSet: <Parser>{});
        for (ParsingLeftRecursion left in parsingCallStack.takeWhile((ParsingLeftRecursion lr) => lr.head != head)) {
          head.involvedSet.add(left.parser);
          left.head = head;
        }

        return result.seed;
      } else if (result is Context<R>) {
        return result;
      }
      Parser.never;
    }
  }

  @override
  Context<R> parse<I, R>(Parser<R> parser, Context<I> context) => //
      context.isFailure
          ? context.failure()
          : parser.memoize //
              ? parseMemoized(parser, context)
              : parser.parseOn(context, this);

  final RecognizingMemoizationMap recognizingMemoizationMap = RecognizingMemoizationMap();
  final Queue<RecognizingLeftRecursion> recognizingCallStack = Queue<RecognizingLeftRecursion>();

  RecognizingMemoizationEntry? recognizeRecall<R>(Parser<R> parser, String input, int index) {
    RecognizingMemoizationEntry? entry = (recognizingMemoizationMap[parser] ??= RecognizingSubMap.new())[index];
    Head? head = heads[index];

    // If the head is not being grown, return the memoized result.
    if (head == null || !head.evaluationSet.contains(parser)) {
      return entry;
    }

    // If the current parser is not a part of the head and is not evaluated yet,
    // Add a failure to it.
    if (entry == null && !head.involvedSet.union(<Parser>{head.parser}).contains(parser)) {
      return RecognizingMemoizationEntry(-1);
    }

    // Remove the current parser from the head's evaluation set.
    head.evaluationSet.remove(parser);
    entry?.value = parser.recognizeOn(input, index, this);

    return entry;
  }

  int recognizeLeftRecursiveResult<R>(Parser<R> parser, String input, int index, RecognizingMemoizationEntry entry) {
    RecognizingLeftRecursion<R> leftRecursion = entry.value as RecognizingLeftRecursion<R>;
    Head<R> head = leftRecursion.head!;
    int seed = leftRecursion.seed;

    /// If the rule of the parser is not the one being parsed,
    /// return the seed.
    if (head.parser != parser) {
      return seed;
    }

    /// Since it is the parser, assign it to the seed.
    entry.value = seed;
    if (seed < 0) {
      return seed;
    }

    heads[index] = head;

    /// "Grow the seed."
    for (;;) {
      head.evaluationSet.addAll(head.involvedSet);
      int result = parser.recognizeOn(input, index, this);
      if (result < 0 || result <= seed) {
        break;
      }
      entry.value = result;
    }
    heads.remove(index);

    return entry.value as int;
  }

  int recognizeMemoized<R>(Parser<R> parser, String input, int index) {
    Queue<RecognizingLeftRecursion> stack = recognizingCallStack;
    RecognizingMemoizationEntry? entry = recognizeRecall(parser, input, index);

    if (entry == null) {
      RecognizingSubMap subMap = recognizingMemoizationMap[parser] ??= RecognizingSubMap.new();
      if (parser.isTerminal || !parser.leftRecursive) {
        int result = parser.recognizeOn(input, index, this);
        subMap[index] = result.entry();

        return result;
      } else {
        RecognizingLeftRecursion<R> leftRecursion = RecognizingLeftRecursion<R>(seed: -1, parser: parser, head: null);
        stack.addFirst(leftRecursion);
        entry = subMap[index] = leftRecursion.entry();
        int ans = parser.recognizeOn(input, index, this);
        stack.removeFirst();

        if (leftRecursion.head != null) {
          leftRecursion.seed = ans;

          return recognizeLeftRecursiveResult(parser, input, index, entry);
        } else {
          entry.value = ans;

          return ans;
        }
      }
    } else {
      Object result = entry.value;

      if (result is RecognizingLeftRecursion<R>) {
        Head<R> head = result.head ??= Head<R>(parser: parser, evaluationSet: <Parser>{}, involvedSet: <Parser>{});
        for (RecognizingLeftRecursion left in stack.takeWhile((RecognizingLeftRecursion lr) => lr.head != head)) {
          head.involvedSet.add(left.parser);
          left.head = head;
        }

        return result.seed;
      } else if (result is int) {
        return result;
      }
      Parser.never;
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
