import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
abstract class CyclicParser<R extends Object?> extends WrapParser<List<R>, R> {
  abstract final num min;
  abstract final num max;
}
