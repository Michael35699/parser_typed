import "dart:collection";

import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class ReferenceParser<R> extends Parser<R> with LazyLoad<R>, CannotParse<R> {
  static final HashMap<Lazy<Parser>, ReferenceParser<Object?>> _thunkMap =
      HashMap<Lazy<Parser>, ReferenceParser<Object?>>();

  @override
  final Lazy<Parser<R>> lazyParser;
  static ReferenceParser<dynamic> dynamicFactory(Lazy<Parser> parser) =>
      _thunkMap[parser] ??= ReferenceParser<dynamic>._(parser);

  factory ReferenceParser(Lazy<Parser<R>> lazyParser) =>
      (_thunkMap[lazyParser] ??= ReferenceParser<R>._(lazyParser)) as ReferenceParser<R>;

  ReferenceParser._(this.lazyParser);
  ReferenceParser.eager(Parser<R> parser) //
      : lazyParser = (() => throw UnsupportedError("Eager has been called.")) {
    computed = parser;
  }

  @override
  LazyLoad<R> eager(Parser<R> parser) => ReferenceParser<R>.eager(parser);
}

ReferenceParser<R> reference<R>(Lazy<Parser<R>> lazyParser) => ReferenceParser<R>(lazyParser);

extension FakeReferenceExtension<R> on Parser<R> {
  Parser<R> operator -() => this;
}

extension ReferenceExtension<R> on Lazy<Parser<R>> {
  ReferenceParser<R> reference() => ReferenceParser<R>(this);
  ReferenceParser<R> $() => reference();
  ReferenceParser<R> get ref => reference();

  ReferenceParser<R> operator -() => reference();
}
