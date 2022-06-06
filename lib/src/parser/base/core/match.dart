import "package:parser_typed/src/parser/base/core/parser.dart";

class ParserMatch<R extends Object?> implements Match {
  @override
  final String input;
  @override
  final int start;
  @override
  final int end;
  @override
  final Parser<R> pattern;
  final List<String> results;

  const ParserMatch({
    required this.input,
    required this.start,
    required this.end,
    required this.pattern,
    required this.results,
  });

  @override
  String? operator [](int group) => group > results.length ? null : results[group];

  @override
  String? group(int group) => this[group];

  @override
  int get groupCount => 1;

  @override
  List<String?> groups(List<int> groupIndices) => <String?>[for (int i in groupIndices) this[i]];

  @override
  String toString() => results.toString();
}
