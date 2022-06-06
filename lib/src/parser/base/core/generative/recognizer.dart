import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class RecognizerParser extends PrimitiveParser with ChildlessParser {
  final RecognizerPredicate predicate;

  RecognizerParser(this.predicate);

  @override
  Context<int> call(String input, int index, ParseHandler handler) => predicate(input, index, succeed, fail);
}

PrimitiveParser recognizer(RecognizerPredicate predicate) => RecognizerParser(predicate);

extension RecognizerFunctionExtension on PrimitiveParser Function(RecognizerPredicate) {
  PrimitiveParser nonEmpty(RecognizerPredicate predicate, {String message = "Unexpected end of input"}) =>
      recognizer((String input, int index, RecognizeSuccess success, RecognizeFailure failure) {
        if (index < input.length) {
          return predicate(input, index, success, failure);
        }
        return failure(message);
      });
}
