import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
mixin NonNullableParser<R> on Parser<R> {
  @override
  @nonVirtual
  bool selfIsNullable(ParserBooleanCacheMap cache) => cache[this] = false;
}
