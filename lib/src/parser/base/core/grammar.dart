import "package:parser_typed/parser.dart";

abstract class ParserGrammar<R> extends Parser<R> {
  Parser<R> get entry;

  @override
  Parser<R> get base => entry;

  @override
  List<Parser> get children => entry.children;

  @override
  Context<R> parseOn(Context<void> context, ParseHandler handler) => handler.parse(base, context);

  @override
  int recognizeOn(String input, int index, ParseHandler handler) => handler.recognize(base, input, index);

  @override
  bool selfIsNullable(ParserBooleanCacheMap cache) => entry.isNullable(cache);

  @override
  Parser<R> cloneSelf(ParserCacheMap cache) => entry.clone(cache);

  @override
  Parser<R> transformChildren(TransformFunction function, ParserCacheMap cache) => entry.transform(function, cache);
}
