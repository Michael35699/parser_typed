import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

mixin LazyLoad<R> on Parser<R> {
  abstract final Lazy<Parser<R>> lazyParser;
  late Parser<R> computed = lazyParser();

  @nonVirtual
  @override
  List<Parser> get children => <Parser>[computed];

  @nonVirtual
  @override
  LazyLoad<R> cloneSelf(ParserCacheMap cloned) => eager(computed.clone(cloned));

  @nonVirtual
  @override
  LazyLoad<R> transformChildren(TransformFunction handler, ParserCacheMap cache) =>
      this..computed = computed.transform(handler, cache);

  LazyLoad<R> eager(Parser<R> parser);

  @override
  bool selfIsNullable(ParserBooleanCacheMap cache) => computed.isNullable(cache);

  @override
  Parser get base => computed.base;
}
