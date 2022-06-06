import "package:parser_typed/src/handler/packrat/quadratic/classes.dart";

typedef ParsingMemoizationMap = Expando<ParsingSubMap>;
typedef ParsingSubMap = Map<int, ParsingMemoizationEntry>;

typedef RecognizingMemoizationMap = Expando<RecognizingSubMap>;
typedef RecognizingSubMap = Map<int, RecognizingMemoizationEntry>;
