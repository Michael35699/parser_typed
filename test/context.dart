import "package:parser_typed/parser.dart";
import "package:test/test.dart";

void main() {
  const Context<dynamic> base = Empty();

  group("conversion", () {
    test("empty", () {
      Context<Never> converted = base.empty();
      expect(converted, isA<Empty>());
      converted = converted.success("").empty();
      expect(converted, isA<Empty>());
      expect(() => converted.value, throwsA(isA<UnsupportedError>()));
    });
    test("success", () {
      Context<Object?> converted = base.empty();
      expect(converted, isA<Empty>());
      converted = converted.success("yes", 12);
      expect(converted, isA<Success>());
      converted as Success;
      expect(converted.value, "yes");
      expect(converted.index, 12);
    });
    test("failure", () {
      Context<Never> converted = base.empty();
      expect(converted, isA<Empty>());
      converted = converted.failure("in-test");
      expect(converted, isA<Failure>());
      converted as Failure;
      expect(converted.message, "in-test");
      converted = converted.failure(converted.generateFailureMessage());

      late String message = """
in-test
 --> 1:1
  |
1 |  ·
  |  ^
  |""";
      expect(converted.message.trimRight(), message);
    });
  });
  group("predicates", () {
    test("empty", () {
      Context<Never> converted = base.empty();
      expect(converted, isA<Empty>());
      expect(converted.isFailure, isFalse);
      expect(converted.isSuccess, isFalse);
      expect(converted.isEmpty, isTrue);
    });
    test("success", () {
      Context<Object?> converted = base.success("yes");
      expect(converted, isA<Success>());
      expect(converted.isFailure, isFalse);
      expect(converted.isSuccess, isTrue);
      expect(converted.isEmpty, isFalse);
    });
    test("failure", () {
      Context<Never> converted = base.failure("in-test");
      expect(converted, isA<Failure>());
      expect(converted.isFailure, isTrue);
      expect(converted.isSuccess, isFalse);
      expect(converted.isEmpty, isFalse);
    });
  });
}
