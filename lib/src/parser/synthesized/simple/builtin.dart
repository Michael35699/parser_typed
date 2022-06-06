import "dart:math";

import "package:parser_typed/parser.dart";

part "implementation.dart";

// BASIC
PrimitiveParser digit() => _digit();
PrimitiveParser digits() => _digits();

PrimitiveParser lowercase() => _lowercase();
PrimitiveParser uppercase() => _uppercase();

PrimitiveParser lowercaseGreek() => _lowercaseGreek();
PrimitiveParser uppercaseGreek() => _uppercaseGreek();

PrimitiveParser letter() => _letter();
PrimitiveParser letters() => _letters();

PrimitiveParser greek() => _greek();
PrimitiveParser greeks() => _greeks();

PrimitiveParser alphanum() => _alphanum();
PrimitiveParser alphanums() => _alphanums();

PrimitiveParser hex() => _hex();
PrimitiveParser hexes() => _hexes();

PrimitiveParser octal() => _octal();
PrimitiveParser octals() => _octals();

// STRING
Parser<String> string([String? pattern]) => pattern == null ? _string() : StringParser(pattern);
Parser<String> singleString() => _singleString();
Parser<String> doubleString() => _doubleString();

// CHAR
Parser<String> char([String? pattern]) => _char();
Parser<String> singleChar() => _singleChar();
Parser<String> doubleChar() => _doubleChar();

// INTEGER /DECIMAL
Parser<num> number() => _number();
Parser<int> integer() => _integer();
Parser<double> decimal() => _decimal();

// IDENTIFIER
PrimitiveParser identifier() => _identifier();
PrimitiveParser cIdentifier() => _cIdentifier();

// OPERATOR
PrimitiveParser operator() => _operator();
PrimitiveParser binaryMathOp() => _binaryMathOp();
PrimitiveParser preUnaryMathOp() => _preUnaryMathOp();
PrimitiveParser postUnaryMathOp() => _postUnaryMathOp();

// JSON NUMBER
Parser<num> completeNumberSlow() => _completeNumberSlow.build();
Parser<num> jsonNumberSlow() => _jsonNumberSlow.build();
// Parser completeNumber() => _completeNumber();
// Parser jsonNumber() => _jsonNumber();

// JSON STRING
// Parser jsonStringSlow() => _jsonStringSlow();
Parser jsonString() => _jsonString();
