import "package:parser_typed/parser.dart";

extension TransformExtension<R> on Parser<R> {
  Parser<R> transformType<ParserType extends Parser<Object?>>(Parser<R> Function<R>(ParserType target) function) =>
      transform(<R>(Parser<R> target) {
        if (target is ParserType) {
          return function(target as ParserType);
        }
        return target;
      });
}
