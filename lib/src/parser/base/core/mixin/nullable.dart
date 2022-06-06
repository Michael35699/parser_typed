import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
mixin NullableParser<R> on Parser<R> {
  @override
  @nonVirtual
  bool selfIsNullable(ParserBooleanCacheMap cache) => cache[this] = true;
}
