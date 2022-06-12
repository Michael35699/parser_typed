import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class ActionParser<R, O> extends WrapParser<R, O> with PassRecognizer {
  @override
  final List<Parser<O>> children;
  final ActionFunction actionFunction;

  @override
  Parser<O> get parser => children[0];

  ActionParser(Parser<O> child, this.actionFunction) : children = <Parser<O>>[child];
  ActionParser.empty(this.actionFunction) : children = <Parser<O>>[];

  @override
  Context<R> parseOn(Context<void> context, ParseHandler handler) {
    Context<O> resultContext = handler.parse(parser, context);

    /// Late as if it is called immediately, it will throw on [Failure<O>] and [Empty<O>]
    /// Therefore, it will only be initialized whenever it's confirmed that it is a success.
    late O result = resultContext.value;

    return resultContext.isSuccess
        ? parser.base is SequenceParser && result is List
            ? resultContext.success(Function.apply(actionFunction, result) as R)
            : resultContext.success(Function.apply(actionFunction, <O>[result]) as R)
        : resultContext.cast();
  }

  @override
  ActionParser<R, O> get empty => ActionParser<R, O>.empty(actionFunction);
}

extension ParserActionExtension<O> on Parser<O> {
  Parser<R> action<R extends Object?>(ActionFunction function) => ActionParser<R, O>(this, function);
}
