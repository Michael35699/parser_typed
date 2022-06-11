import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
abstract class CombinatorParser<R, C> extends Parser<R> {
  @override
  abstract final List<Parser<C>> children;
  late final int childrenLength = children.length;

  CombinatorParser<R, C> get empty;

  @override
  @nonVirtual
  Parser get base => this;

  @nonVirtual
  @override
  CombinatorParser<R, C> cloneSelf(ParserCacheMap cache) {
    CombinatorParser<R, C> clone = cache[this] = empty;
    for (int i = 0; i < childrenLength; i++) {
      clone.children.add(children[i].clone(cache));
    }

    return clone;
  }

  @nonVirtual
  @override
  CombinatorParser<R, C> transformChildren(TransformFunction function, ParserCacheMap cache) {
    cache[this] = this;
    for (int i = 0; i < childrenLength; i++) {
      children[i] = children[i].transform(function, cache);
    }

    return this;
  }

  @override
  bool selfIsNullable(ParserBooleanCacheMap cache) {
    bool nullable = cache[this] = false;
    for (int i = 0; !nullable && i < children.length; i++) {
      nullable |= children[i].isNullable(cache);
    }
    return nullable;
  }
}
