import "package:parser_typed/parser.dart";

Parser<R> _debug<R>(Parser<R> root) {
  int i = -1;
  Parser<R> transformed = root.clone().transform(<O>(Parser<O> target) {
    if (target is CannotDebugParser<O>) {
      return target;
    }

    return target.cc(<R, I>(ParseFunction<R, I> continuation, Context<I> context) {
      i++;
      String indent = "  " * i;
      print("$indent$target");
      Context<R> result = continuation(context);
      print("$indent $result");
      i--;

      return result;
    }, (RecognizeFunction continuation, int index) {
      i++;
      String indent = "  " * i;
      print("$indent$target");
      int result = continuation(index);
      print("$indent $result");
      i--;

      return result;
    });
  });
  return transformed;
}

extension ParserDebugExtension<R> on Parser<R> {
  Parser<R> debug() => _debug(this);
}

extension LazyParserDebugExtension<R> on Lazy<Parser<R>> {
  Parser<R> debug() => _debug(this.reference());
}

extension StringDebugExtension on String {
  Parser<String> debug() => _debug(this.parser());
}
