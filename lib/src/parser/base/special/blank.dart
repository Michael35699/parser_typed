import "package:meta/meta.dart";
import "package:parser_typed/parser.dart";

@optionalTypeArgs
class BlankParser<R extends Object?> extends SpecialParser<R> with NonNullableParser {
  static Expando<BlankParser<Object?>> _singletons = Expando<BlankParser<Object?>>();
  static BlankParser<R> _single<R>(Type key) => //
      (_singletons[key] ??= BlankParser<R>.generate()) as BlankParser<R>;

  factory BlankParser() => BlankParser._single(R);
  BlankParser.generate();

  @override
  Failure parseOn(Context<void> context, Handler handler) => context.failure("blank");

  @override
  int recognizeOn(String input, int index, Handler handler) => -1;
}

final BlankParser _singleton = BlankParser<dynamic>();
BlankParser blank() => _singleton;
