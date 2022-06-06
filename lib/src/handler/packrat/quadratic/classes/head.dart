import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class Head<R extends Object?> {
  final Parser<R> parser;
  final Set<Parser> involvedSet;
  final Set<Parser> evaluationSet;

  Head({required this.parser, required this.involvedSet, required this.evaluationSet});
}
