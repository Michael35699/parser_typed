import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class ChoiceParser<R extends Object?> extends CombinatorParser<R, R> {
  @override
  final List<Parser<R>> children;

  ChoiceParser(this.children) {
    if (children.isEmpty) {
      throw ArgumentError("A choice parser should have at least one parser!");
    }
  }
  ChoiceParser.empty() : children = <Parser<R>>[];

  @override
  Context<R> parseOn(Context<void> context, ParseHandler handler) {
    for (int i = 0; i < childrenLength; i++) {
      Context<R> result = handler.parse(children[i], context);
      if (result.isSuccess) {
        return result;
      }
      if (result.isFailure) {
        handler.failure(result.failure());
      }
    }

    return handler.longestFailure.failure();
  }

  @override
  int recognizeOn(String input, int index, ParseHandler handler) {
    for (int i = 0; i < childrenLength; i++) {
      int result = handler.recognize(children[i], input, index);
      if (result >= 0) {
        return result;
      }
    }
    return -1;
  }

  @override
  ChoiceParser<R> get empty => ChoiceParser<R>.empty();
}

ChoiceParser<R> choice<R extends Object?>(List<Parser<R>> parsers) => ChoiceParser<R>(parsers);

extension ChoiceBuilderExtension on ChoiceParser<R> Function<R extends Object?>(List<Parser<R>> parsers) {
  ChoiceParser<R> builder<R extends Object?>(Iterable<Parser<R>> Function() builderFn) => this(builderFn().toList());
}

extension IterableChoiceExtension<E> on List<Parser<E>> {
  ChoiceParser<E> choice() => ChoiceParser<E>(this);
}

extension ParserChoiceExtension<R> on Parser<R> {
  Parser<Object?> operator /(Object other) {
    Parser self = this;
    Parser resolved = Parser.resolve(other);

    return ChoiceParser(<Parser>[
      if (self is ChoiceParser) ...self.children else self,
      if (resolved is ChoiceParser) ...resolved.children else resolved,
    ]);
  }

  Parser<R> operator |(Parser<R> other) {
    Parser<R> self = this;
    return ChoiceParser<R>(<Parser<R>>[
      if (self is ChoiceParser<R>) ...self.children else self,
      if (other is ChoiceParser<R>) ...other.children else other,
    ]);
  }
}

extension LazyParserChoiceExtension<R> on Lazy<Parser<R>> {
  Parser<Object?> operator /(Object other) => Parser.resolve(this) / Parser.resolve(other);
  Parser<R> operator |(Parser<R> other) => this.reference() | other;
}

extension StringChoiceExtension on String {
  Parser<Object?> operator /(Object other) => this.parser() / parser(other);
  Parser<String> operator |(String other) => this.parser() | other.parser();
}
