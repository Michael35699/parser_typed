import "package:parser_typed/parser.dart";

mixin SequentialParser<R, C> on CombinatorParser<R, C> {
  @override
  bool selfIsNullable(ParserBooleanCacheMap cache) {
    bool nullable = cache[this] = true;
    for (int i = 0; nullable && i < children.length; i++) {
      nullable &= children[i].isNullable(cache);
    }
    return nullable;
  }
}
