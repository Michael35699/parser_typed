part of "builtin.dart";

// BASIC
PrimitiveParser _digit() => "[0-9]".r();
PrimitiveParser _digits() => "[0-9]+".r();

PrimitiveParser _lowercase() => "[a-z]".r();
PrimitiveParser _uppercase() => "[A-Z]".r();

PrimitiveParser _lowercaseGreek() => "[α-ω]".r();
PrimitiveParser _uppercaseGreek() => "[Α-Ω]".r();

PrimitiveParser _letter() => "[A-Za-z]".r();
PrimitiveParser _letters() => "[A-Za-z]+".r();

PrimitiveParser _greek() => "[Α-Ωα-ω]".r();
PrimitiveParser _greeks() => "[Α-Ωα-ω]+".r();

PrimitiveParser _alphanum() => "[0-9A-Fa-f]".r();
PrimitiveParser _alphanums() => "[0-9A-Fa-f]+".r();

PrimitiveParser _hex() => "[0-9A-Fa-f]".r();
PrimitiveParser _hexes() => "[0-9A-Fa-f]+".r();

PrimitiveParser _octal() => "[0-7]".r();
PrimitiveParser _octals() => "[0-7]+".r();

Parser<String> _delimitedStar(String delimiter) => //
    (r"\" & any() | delimiter.not() & any()).star().flat().between(delimiter, delimiter);
Parser<String> _delimitedSingle(String delimiter) => //
    (r"\" & any() | delimiter.not() & any()).flat().between(delimiter, delimiter);

// STRING
Parser<String> _string() => _singleString() | _doubleString();
Parser<String> _singleString() => _delimitedStar("'").message("Expected single-string literal");
Parser<String> _doubleString() => _delimitedStar('"').message("Expected double-string literal");

// CHAR
Parser<String> _char() => _singleChar() | _doubleChar();
Parser<String> _singleChar() => _delimitedSingle("'");
Parser<String> _doubleChar() => _delimitedSingle('"');

// INTEGER /DECIMAL
Parser<num> _number() => r"""(?:[0-9]*\.[0-9]+)|(?:[0-9]+)""".r().map(num.parse);
Parser<int> _integer() => "[0-9]+".r().map(int.parse);
Parser<double> _decimal() => r"[0-9]*\.[0-9]+".r().map(double.parse);

// IDENTIFIER
PrimitiveParser _identifier() => r"[A-Za-zΑ-Ωα-ω\_\$\:][A-Za-zΑ-Ωα-ω0-9\_\$\-]*".r();
PrimitiveParser _cIdentifier() => r"[A-Za-z\_\$\:][A-Za-z0-9\_\$]*".r();

// OPERATOR
PrimitiveParser _operator() => r"[<>=!\/&^%+\-#*~]+".r();
PrimitiveParser _binaryMathOp() => r"[+\-*\/%^]|(?:~/)".r();
PrimitiveParser _preUnaryMathOp() => "√".r();
PrimitiveParser _postUnaryMathOp() => "!".r();

// JSON NUMBER

Parser<int> __sign() => "-".p().map((String r) => r == "-" ? -1 : 1).failure(1);
Parser<int> __whole() => "[0-9]+".r().action(int.parse);
Parser<double> __fraction() => r"\.[0-9]+".r().map((String result) => double.parse("0$result")).failure(0);
Parser<String> __eMark() => "[Ee]".r();
Parser<String> __eSign() => "[+-]".r().failure("+");
Parser<num> __power() => (__eMark.ref & __eSign.ref & __whole.ref)
    .action<int>((void _, String s, int v) => pow(10, s == "-" ? -v : v))
    .failure(1);
Parser<num> __base() => (__whole.ref & __fraction.ref).action<num>((num w, num f) => w + f);
Parser<num> _completeNumberSlow() => (__base.ref & __power.ref).action((num b, num p) => b * p);
Parser<num> _jsonNumberSlow() => (__sign.ref & __base.ref & __power.ref).action((num s, num b, num p) => s * b * p);

void experiment() {
  Parser<num> parser = jsonNumberSlow().debug();

  print(parser.recognize("-3.14e-0"));
}

// Parser _completeNumber() => r"(?<b>[0-9]+)(?:\.(?<f>[0-9]+))?(?:[eE](?<s>[+-]?)(?<e>[0-9]+))?".r.map(
//       $named(({String b = "0", String? f, String? s, String? e}) {
//         num base = int.parse(b) + (f == null ? 0 : double.parse("0.$f"));
//         num exp = e == null ? 1 : pow(10, s == "-" ? -1 : 1 * int.parse(e));

//         return base * exp;
//       }),
//     );

// Parser _jsonNumber() => r"(?<n>-)?(?<b>[0-9]+)(?:\.(?<f>[0-9]+))?(?:[eE](?<s>[+-]?)(?<e>[0-9]+))?".r.map(
//       $named(({String? n, String b = "0", String? f, String? s, String? e}) {
//         int sign = n == "-" ? -1 : 1;
//         num base = int.parse(b) + (f == null ? 0 : double.parse("0.$f"));
//         int expSign = s == "-" ? -1 : 1;
//         num exp = e == null ? 1 : pow(10, expSign * int.parse(e));

//         return sign * base * exp;
//       }),
//     );

Parser __controlCharBody() => '"' / r"\" / "/" / "b" / "f" / "n" / "r" / "t" / (hex * 4);
Parser __controlChar() => string(r"\") & __controlCharBody.ref;
Parser __stringAvoid() => string('"') / __controlChar.ref;
Parser __stringChar() => __controlChar.ref | ~__stringAvoid.ref >> any();
Parser _jsonString() => '"' & __stringChar.ref.star() & '"';

// Parser _jsonString() => r"""(")((?:(?:(?=\\)\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4}))|[^"\\\0-\x1F\x7F]+)*)(")""".r();
