import "package:parser_typed/parser.dart";
import "package:parser_typed/src/handler/packrat/quadratic/classes.dart";

class MemoizationEntry<Type1, Type2> {
  Object value;

  MemoizationEntry(this.value) : assert(value is Type1 || value is Type2, "Valid types");
}

typedef RecognizingMemoizationEntry = MemoizationEntry<int, RecognizingLeftRecursion>;
typedef ParsingMemoizationEntry = MemoizationEntry<Context<dynamic>, ParsingLeftRecursion>;
