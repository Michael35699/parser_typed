import "dart:collection";

import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class TrimmingParser<R extends Object?> extends WrapParser<R, R> {
  static final Map<String, Pattern> _savedPatterns = HashMap<String, Pattern>();
  static Pattern? resolvePattern(String? pattern) =>
      pattern == null ? null : _savedPatterns[pattern] ??= RegExp(pattern);

  @override
  final List<Parser> children;
  final String? left;
  final String? right;

  Pattern? get leftPattern => resolvePattern(left);
  Pattern? get rightPattern => resolvePattern(right);

  @override
  Parser<R> get parser => children[0] as Parser<R>;

  TrimmingParser.complete(Parser<R> parser, this.left, this.right) //
      : children = <Parser>[parser];
  TrimmingParser.left(Parser<R> parser, this.left)
      : children = <Parser>[parser],
        right = null;
  TrimmingParser.right(Parser<R> parser, this.right)
      : children = <Parser>[parser],
        left = null;
  TrimmingParser.empty(this.left, this.right) : children = <Parser>[];

  @override
  Context<R> parseOn(Context<void> context, ParseHandler handler) {
    String input = context.input;

    int beginningIndex = context.index;
    int start = leftPattern?.matchAsPrefix(input, beginningIndex)?.end ?? context.index;
    Context<void> insert = context.empty(start);
    Context<R> result = handler.parse(parser, insert);
    if (result.isFailure) {
      return result;
    }

    int endingIndex = result.index;
    int end = rightPattern?.matchAsPrefix(input, endingIndex)?.end ?? endingIndex;

    return result.replaceIndex(end);
  }

  @override
  int recognizeOn(String input, int index, ParseHandler handler) {
    int start = leftPattern?.matchAsPrefix(input, index)?.end ?? index;
    int result = handler.recognize(parser, input, start);
    if (result < 0) {
      return result;
    }
    return rightPattern?.matchAsPrefix(input, result)?.end ?? result;
  }

  @override
  TrimmingParser<R> get empty => TrimmingParser<R>.empty(left, right);
}
