import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class SequenceParser<R> extends CombinatorParser<List<R>, R> {
  @override
  final List<Parser<R>> children;

  SequenceParser(this.children) {
    if (children.isEmpty) {
      throw ArgumentError("A sequence parser should have at least one parser!");
    }
  }
  SequenceParser.empty() : children = <Parser<R>>[];

  @override
  Context<List<R>> parseOn(Context<void> context, ParseHandler handler) {
    List<R> results = <R>[];

    Context<void> ctx = context;
    for (int i = 0; i < childrenLength; i++) {
      Context<R> inner = handler.parse(children[i], ctx);
      if (inner.isFailure) {
        return inner.failure();
      }

      results.add(inner.value);
      ctx = inner;
    }

    return ctx.success(results);
  }

  @override
  int recognizeOn(String input, int index, ParseHandler handler) {
    int position = index;
    for (int i = 0; i < childrenLength; i++) {
      position = handler.recognize(children[i], input, position);
      if (position < 0) {
        break;
      }
    }
    return position;
  }

  @override
  SequenceParser<R> get empty => SequenceParser<R>.empty();
}

SequenceParser<R> sequence<R>(List<Parser<R>> parsers) => SequenceParser<R>(parsers);

extension SequenceBuilderExtension on SequenceParser<R> Function<R>(List<Parser<R>> parsers) {
  SequenceParser<R> builder<R>(Iterable<Parser<R>> Function() builderFn) => this(builderFn().toList());
}

extension IterableSequenceExtension<E> on List<Parser<E>> {
  Parser<List<E>> sequence() => SequenceParser<E>(this);
}

extension ParserSequenceExtension<R> on Parser<R> {
  // Parser<List<Object?>> operator &(Parser<Object?> other) => SequenceParser<Object?>(<Parser>[
  //       if (this is SequenceParser) ...children else this,
  //       if (other is SequenceParser) ...other.children else other,
  //     ]);

  SequenceParser<R> operator +(Parser<R> other) => SequenceParser<R>(<Parser<R>>[this, other]);
}

extension SequenceParserSequenceExtension<R> on SequenceParser<R> {
  SequenceParser<R> operator +(Parser<R> other) => SequenceParser<R>(<Parser<R>>[...children, other]);
}
