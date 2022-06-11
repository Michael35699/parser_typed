import "package:parser_typed/parser.dart";

extension ParserPseudoIterableExtension<O> on Parser<O> {
  Parser<R> notNull<R extends Object>() => map((O result) => result! as R);
  Parser<R> cast<R>() => map((O result) => result as R);

  Parser<R> whereType<R>() => bind((O r) => r is R //
      ? success(r)
      : failure("`whereType` call failure"));
}

extension LazyParserPseudoIterableExtension<O> on Lazy<Parser<O>> {
  Parser<R> notNull<R extends Object>() => this.reference().notNull();
  Parser<R> cast<R>() => this.reference().cast();
  Parser<R> whereType<R>() => this.reference().whereType();
}
