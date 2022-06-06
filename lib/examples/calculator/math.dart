import "dart:math";

import "package:parser_typed/parser.dart" as parser;

parser.Parser<String> _token(String one, [String? two, String? three, String? four, String? five]) {
  List<parser.Parser<String>> parsers = <String?>[one, two, three, four, five] //
      .whereType<String>()
      .map((String e) => e.parser())
      .toList();

  return parser.choice(parsers).trim();
}

parser.Parser<String> addOp = _token("+", "add");
parser.Parser<String> subOp = _token("-", "sub");
parser.Parser<String> mulOp = _token("*", "mul");
parser.Parser<String> divOp = _token("/", "div");
parser.Parser<String> modOp = _token("%", "mod");
parser.Parser<String> fDivOp = _token("~/", "fdiv");
parser.Parser<String> negOp = _token("-", "neg");
parser.Parser<String> powOp = _token("^", "pow");

parser.Parser<num> infix() => _add.ref;
parser.Parser<num> _add() =>
    (_add.ref & addOp & _multi.ref).action<num>((num l, void _, num r) => l + r) |
    (_add.ref & subOp & _multi.ref).action<num>((num l, void _, num r) => l - r) |
    _multi.ref;

parser.Parser<num> _multi() =>
    (_multi.ref & mulOp & _unary.ref).action<num>((num l, void _, num r) => l * r) |
    (_multi.ref & divOp & _unary.ref).action<num>((num l, void _, num r) => l / r) |
    (_multi.ref & modOp & _unary.ref).action<num>((num l, void _, num r) => l % r) |
    (_multi.ref & fDivOp & _unary.ref).action<num>((num l, void _, num r) => l ~/ r) |
    _unary.ref;

parser.Parser<num> _unary() =>
    _power.ref | //
    (negOp & _unary.ref).action<num>((void _, num v) => -v);

parser.Parser<num> _power() =>
    (_atomic.ref & powOp & _power.ref).action<num>((num l, void _, num r) => pow(l, r)) | //
    _atomic.ref;

parser.Parser<num> _atomic() =>
    "0".urng("9").plus().flat().map<num>(int.parse).message("Expected a number") | //
    ("(".t() & _add.ref & ")".t()).action<num>((void l, num v, void r) => v);

parser.Parser<num> postfix() => _postfix.ref;
parser.Parser<num> _postfix() =>
    (_postfix.ref & _postfix.ref.t() & addOp).action<num>((num l, num r, void o) => l + r) |
    (_postfix.ref & _postfix.ref.t() & subOp).action<num>((num l, num r, void o) => l - r) |
    (_postfix.ref & _postfix.ref.t() & mulOp).action<num>((num l, num r, void o) => l * r) |
    (_postfix.ref & _postfix.ref.t() & divOp).action<num>((num l, num r, void o) => l / r) |
    (_postfix.ref & _postfix.ref.t() & modOp).action<num>((num l, num r, void o) => l % r) |
    (_postfix.ref & _postfix.ref.t() & fDivOp).action<num>((num l, num r, void o) => l ~/ r) |
    (_postfix.ref & _postfix.ref.t() & powOp).action<num>((num l, num r, void o) => pow(l, r)) |
    "0".urng("9").plus().flat().map<num>(num.parse).message("Expected a number");

parser.Parser<num> prefix() => _prefix.ref;
parser.Parser<num> _prefix() =>
    (addOp & _prefix.ref.t() & _prefix.ref).action<num>((void o, num l, num r) => l + r) |
    (subOp & _prefix.ref.t() & _prefix.ref).action<num>((void o, num l, num r) => l - r) |
    (mulOp & _prefix.ref.t() & _prefix.ref).action<num>((void o, num l, num r) => l * r) |
    (divOp & _prefix.ref.t() & _prefix.ref).action<num>((void o, num l, num r) => l / r) |
    (modOp & _prefix.ref.t() & _prefix.ref).action<num>((void o, num l, num r) => l % r) |
    (fDivOp & _prefix.ref.t() & _prefix.ref).action<num>((void o, num l, num r) => l ~/ r) |
    (powOp & _prefix.ref.t() & _prefix.ref).action<num>((void o, num l, num r) => pow(l, r)) |
    "0".urng("9").plus().flat().map<num>(num.parse).message("Expected a number");
