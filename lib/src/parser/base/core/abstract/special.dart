import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
abstract class SpecialParser<R extends Object?> extends Parser<R> with ChildlessParser<R> {}
