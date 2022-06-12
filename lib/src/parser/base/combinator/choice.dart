import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class ChoiceParser<R> extends CombinatorParser<R, R> {
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

ChoiceParser<R> choice<R>(List<Parser<R>> parsers) => ChoiceParser<R>(parsers);

extension ChoiceBuilderExtension on ChoiceParser<R> Function<R>(List<Parser<R>> parsers) {
  ChoiceParser<R> builder<R>(Iterable<Parser<R>> Function() builderFn) => this(builderFn().toList());
}

extension IterableChoiceExtension<E> on List<Parser<E>> {
  ChoiceParser<E> choice() => ChoiceParser<E>(this);
}

extension ParserChoiceExtension<R> on Parser<R> {
  Parser<Object?> operator /(Parser<Object?> other) => ChoiceParser(<Parser>[
        if (this is ChoiceParser) ...children else this,
        if (other is ChoiceParser) ...other.children else other,
      ]);

  Parser<R> operator |(Parser<R> other) {
    Parser<R> self = this;
    return ChoiceParser<R>(<Parser<R>>[
      if (self is ChoiceParser<R>) ...self.children else self,
      if (other is ChoiceParser<R>) ...other.children else other,
    ]);
  }
}
