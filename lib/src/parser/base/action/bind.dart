import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class BindParser<R extends Object?, O extends Object?> extends WrapParser<R, O> {
  @override
  final List<Parser<O>> children;
  final BindFunction<R, O> bindFunction;

  @override
  Parser<O> get parser => children[0];

  BindParser(Parser<O> child, this.bindFunction) : children = <Parser<O>>[child];
  BindParser.empty(this.bindFunction) : children = <Parser<O>>[];

  @override
  Context<R> parseOn(Context<void> context, Handler handler) {
    Context<O> resultContext = handler.parse(parser, context);

    return resultContext.isSuccess //
        ? handler.parse(bindFunction(resultContext.value), resultContext)
        : resultContext.cast();
  }

  @override
  int recognizeOn(String input, int index, Handler handler) {
    Context<void> context = Empty(input, index);
    Context<R> result = parseOn(context, handler);

    return result.isFailure ? -1 : result.index;
  }

  @override
  BindParser<R, O> get empty => BindParser<R, O>.empty(bindFunction);
}

extension ParserBindExtension<O> on Parser<O> {
  Parser<R> bind<R extends Object?>(BindFunction<R, O> function) => BindParser<R, O>(this, function);
}

extension LazyParserBindExtension<O> on Lazy<Parser<O>> {
  Parser<R> bind<R extends Object?>(BindFunction<R, O> function) => this.reference().bind(function);
}

extension StringBindExtension on String {
  // Parser<R> bind<R >(BindFunction<R, String> function) => this.parser().bind(function);
}
