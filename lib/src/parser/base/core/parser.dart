// ignore_for_file: deprecated_member_use_from_same_package

import "dart:collection";
import "dart:math" show min;

import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";
import "package:parser_typed/src/handler/packrat/quadratic/handler.dart";

@optionalTypeArgs
abstract class Parser<R> implements Pattern {
  static Never get never => throw Error();

  bool memoize = false;
  late final bool leftRecursive = isLeftRecursive();
  late final bool isTerminal = children.isEmpty;

  @Deprecated("Call the handler")
  Context<R> parseOn(Context<void> context, ParseHandler handler);
  @Deprecated("Call the handler")
  int recognizeOn(String input, int index, ParseHandler handler);

  Context<R> parse(String input, [int start = 0]) => QuadraticHandler().parse(this, Empty(input, start));
  int recognize(String input, [int start = 0]) => QuadraticHandler().recognize(this, input, start);
  bool accepts(String input, [int start = 0]) => recognize(input, start) >= 0;

  Context<R> run(String input) {
    QuadraticHandler handler = QuadraticHandler();
    Parser<R> built = build();
    Empty context = Empty(input.unindent(), index);
    Context<R> result = handler.parse(built, context);

    if (result is! Failure) {
      return result;
    }

    Failure longest = handler.failure(result);
    String formattedMessage = longest.generateFailureMessage();

    return longest.failure(formattedMessage);
  }

  R evaluate(String input, {R Function()? except}) {
    Context<R> result = run(input);
    if (result.isFailure) {
      if (except != null) {
        return except();
      }
      throw Exception(result.message);
    }
    return result.value;
  }

  Parser<R> cloneSelf(ParserCacheMap cache);
  Parser<R> clone([ParserCacheMap? cache]) {
    cache ??= ParserCacheMap();
    Parser clone = cache[this] ??= cloneSelf(cache) //
      ..memoize = memoize;

    return clone as Parser<R>;
  }

  Parser<R> transformChildren(TransformFunction function, ParserCacheMap cache);
  Parser<R> transform(TransformFunction handler, [ParserCacheMap? cache]) {
    cache ??= ParserCacheMap();
    Parser<R> p = (cache[this] ??= handler<R>(transformChildren(handler, cache))) as Parser<R>;

    return p;
  }

  Parser<R> replace(Parser target, Parser result) =>
      transform(<R>(Parser<R> it) => it == target ? result as Parser<R> : it);

  Parser get base;
  List<Parser> get children;

  Return captureGeneric<Return>(Return Function<R>() function) => function<R>();

  bool selfIsNullable(ParserBooleanCacheMap cache);
  bool isNullable([ParserBooleanCacheMap? cache]) {
    cache ??= ParserBooleanCacheMap();
    bool nullable = cache[this] ??= selfIsNullable(cache);

    return nullable;
  }

  bool isLeftRecursive() {
    Iterable<Parser> toAdd = firstChildren;
    Queue<Parser> parsers = Queue<Parser>()..addAll(toAdd);
    Set<Parser> visited = <Parser>{...toAdd};

    while (parsers.isNotEmpty) {
      Parser current = parsers.removeFirst();
      if (current == this) {
        return true;
      }

      current.firstChildren.where(visited.add).forEach(parsers.add);
    }

    return false;
  }

  List<Parser> get firstChildren {
    Parser<R> self = this;
    if (self is SequentialParser) {
      int i = 0;
      List<Parser> children = self.children;

      return <Parser>[
        for (; i < children.length && children[i].isNullable(); i++) children[i],
        if (i < children.length) children[i],
      ];
    }
    return children;
  }

  @override
  Iterable<ParserMatch<R>> allMatches(String string, [int start = 0]) sync* {
    int index = start;
    while (index < string.length) {
      ParserMatch<R>? previousMatch;
      while (previousMatch == null && index < string.length) {
        previousMatch = matchAsPrefix(string, index++);
      }

      if (previousMatch != null) {
        yield previousMatch;
        int end = previousMatch.end;
        index = end == index - 1 ? end + 1 : end;
      }
    }
  }

  @override
  ParserMatch<R>? matchAsPrefix(String string, [int start = 0]) {
    int end = QuadraticHandler().recognize(this, string, start);
    if (end < 0) {
      return null;
    }

    List<String> results = <String>[string, string.substring(start, end), string.substring(end)];
    ParserMatch<R> match = ParserMatch<R>(input: string, start: start, end: end, pattern: this, results: results);

    return match;
  }

  @override
  String toString() => "$runtimeType";

  Iterable<Parser> get traverse sync* {
    Set<Parser> traversed = Set<Parser>.identity()..add(this);
    Queue<Parser> parsers = Queue<Parser>()..add(this);

    while (parsers.isNotEmpty) {
      Parser current = parsers.removeFirst();

      yield current;

      for (Parser child in current.children) {
        if (traversed.add(child)) {
          parsers.add(child);
        }
      }
    }
  }

  Set<Parser> get pool => traverse.toSet();

  static Iterable<Parser> rules(Parser root) sync* {
    for (Parser parser in root.build().traverse) {
      if (parser != root &&
          parser.memoize &&
          !parser.isTerminal &&
          (parser is WrapParser ? !parser.parser.isTerminal : parser is! WrapParser)) {
        yield parser;
      }
    }
  }

  static String generateAsciiTree(Parser parser, {Map<Parser, String>? marks}) {
    Parser built = parser.build();
    int counter = 0;
    Map<Parser, int> rules = <Parser, int>{for (Parser p in Parser.rules(built)) p: ++counter};
    StringBuffer buffer = StringBuffer("\n");
    Expando<bool> expando = Expando<bool>();

    for (Parser p in rules.keys.where(marks?.keys.contains ?? (Parser p) => true)) {
      buffer
        ..writeln("(rule#${rules[p]})")
        ..writeln(_generateAsciiTree(expando, rules, p, "", isLast: true, level: 0, marks: marks));
    }

    return buffer.toString().trimRight();
  }

  static String _generateAsciiTree(
    Expando<bool> built,
    Map<Parser, int> rules,
    Parser parser,
    String indent, {
    required bool isLast,
    required int level,
    Map<Parser, String>? marks,
  }) {
    StringBuffer buffer = StringBuffer();

    block:
    {
      String marker = isLast ? "└─" : "├─";

      buffer
        ..write(indent)
        ..write(marker);

      if (level > 0 && rules.containsKey(parser)) {
        buffer
          ..write(" (rule#${rules[parser]})")
          ..writeln();

        break block;
      }

      if (built[parser] != null) {
        buffer.writeln("...");

        break block;
      }

      built[parser] = true;
      buffer
        ..write(" $parser")
        ..write((marks?.containsKey(parser) ?? false) ? "  <--  '${marks![parser]}'" : "")
        ..writeln();

      List<Parser> children = parser.children.toList();
      if (children.isNotEmpty) {
        String newIndent = "$indent${isLast ? "   " : "│  "}";
        for (int i = 0; i < children.length; i++) {
          buffer.write(_generateAsciiTree(
            built,
            rules,
            children[i],
            newIndent,
            isLast: i == children.length - 1,
            level: level + 1,
            marks: marks,
          ));
        }
      }
      built[parser] = null;
    }

    return buffer.toString();
  }
}

Parser<R> parser<R>(Parser<R> item) => item;

extension _UnindentExtension on String {
  String unindent() {
    String removed = replaceAll("\r", "");
    List<String> lines = removed.split("\n");
    int indentCount = lines //
        .map((String line) => line.trimRight())
        .where((String line) => line.isNotEmpty)
        .map((String l) => l.length - l.trimLeft().length)
        .reduce(min);

    String unindented = lines //
        .map((String e) => e.trim().isEmpty ? e : e.substring(indentCount))
        .join("\n");

    return unindented;
  }
}
