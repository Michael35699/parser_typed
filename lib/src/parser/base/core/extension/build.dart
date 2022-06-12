import "package:parser_typed/parser.dart";

extension ParserBuildExtension<R> on Parser<R> {
  Parser<R> build() {
    Parser<R> clone = this.clone();

    return clone.transform(<R>(Parser<R> parser) {
      if (parser is ReferenceParser<R>) {
        return parser.computed..memoize = true;
      }
      return parser;
    });
  }
}
