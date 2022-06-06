import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

mixin WrapTransform<R> on Parser<R> {
  Parser get parser;
  WrapTransform<R> get empty;

  @nonVirtual
  @override
  WrapTransform<R> cloneSelf(ParserCacheMap cache) {
    WrapTransform<R> clone = cache[this] = empty;
    for (int i = 0; i < children.length; i++) {
      clone.children.add(children[i].clone(cache));
    }

    return clone;
  }

  @nonVirtual
  @override
  WrapTransform<R> transformChildren(TransformFunction function, ParserCacheMap cache) {
    cache[this] = this;
    for (int i = 0; i < children.length; i++) {
      children[i] = children[i].transform(function, cache);
    }

    return this;
  }

  @override
  bool selfIsNullable(ParserBooleanCacheMap cache) => cache[this] = parser.isNullable(cache);
}
