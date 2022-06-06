import "package:parser_typed/parser.dart";

typedef ParsingMemoizationMap = Expando<ParsingSubMap>;
typedef ParsingSubMap = Map<int, Context<dynamic>>;

typedef RecognizingMemoizationMap = Expando<RecognizingSubMap>;
typedef RecognizingSubMap = Map<int, int>;
