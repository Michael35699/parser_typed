import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
mixin ChildlessParser<R> on Parser<R> {
  @nonVirtual
  @override
  ChildlessParser<R> cloneSelf(ParserCacheMap cache) => this;

  @nonVirtual
  @override
  ChildlessParser<R> transformChildren(TransformFunction function, ParserCacheMap cache) => this;

  @nonVirtual
  @override
  List<Parser> get children => <Parser>[];

  @override
  Parser get base => this;
}
