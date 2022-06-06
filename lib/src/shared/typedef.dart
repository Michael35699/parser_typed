import "package:parser_typed/parser.dart";

typedef ParserBooleanCacheMap = Expando<bool>;
typedef ParserCacheMap = Expando<Parser>;
typedef TransformFunction = Parser<R> Function<R extends Object?>(Parser<R> target);
typedef DynamicTransformFunction = Parser Function(Parser target);
typedef Recognizer = Parser<String>;

typedef ParseSuccess<R> = Context<R> Function(R result, int index);
typedef ParseFailure<R> = Context<R> Function(String message);
typedef ParserPredicate<R> = Context<R> Function(
    String input, int index, ParseSuccess<R> success, ParseFailure<R> failure);

typedef RecognizeSuccess = Context<int> Function(int index);
typedef RecognizeFailure = Context<int> Function(String message);
typedef RecognizerPredicate = Context<int> Function(
    String input, int index, RecognizeSuccess success, RecognizeFailure failure);

typedef Lazy<T> = T Function();

typedef ActionFunction = Function;
typedef MapFunction<R, O> = R Function(O result);
typedef FilterFunction<O> = bool Function(O result);
typedef BindFunction<R, O> = Parser<R> Function(O result);
typedef ThenFunction<R, O> = Context<R> Function(Context<O> result);
typedef FlatMapFunction<R, O> = Context<R> Function(O result);

typedef ParseContinuationFunction = Context<R> Function<R, I>(ParseFunction<R, I> continuation, Context<I> context);
typedef ParseFunction<R, I> = Context<R> Function(Context<I> context);
typedef RecognizeContinuationFunction = int Function(RecognizeFunction continuation, int index);
typedef RecognizeFunction = int Function(int);
