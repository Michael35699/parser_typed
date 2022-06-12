import "dart:math";

import "package:parser_typed/parser.dart";

Parser<String> _token(String one, [String? two, String? three, String? four, String? five]) {
  List<Parser<String>> parsers = <String?>[one, two, three, four, five] //
      .whereType<String>()
      .map((String e) => e.parser())
      .toList();

  return choice(parsers).trim();
}

Parser<String> addOp = _token("+", "add");
Parser<String> subOp = _token("-", "sub");
Parser<String> mulOp = _token("*", "mul");
Parser<String> divOp = _token("/", "div");
Parser<String> modOp = _token("%", "mod");
Parser<String> fDivOp = _token("~/", "fdiv");
Parser<String> negOp = _token("-", "neg");
Parser<String> powOp = _token("^", "pow");

Parser<num> infix() => _add.ref;
Parser<num> _add() =>
    (_add.ref & addOp & _multi.ref).action<num>((num l, void _, num r) => l + r) |
    (_add.ref & subOp & _multi.ref).action<num>((num l, void _, num r) => l - r) |
    _multi.ref;

Parser<num> _multi() =>
    (_multi.ref & mulOp & _unary.ref).action<num>((num l, void _, num r) => l * r) |
    (_multi.ref & divOp & _unary.ref).action<num>((num l, void _, num r) => l / r) |
    (_multi.ref & modOp & _unary.ref).action<num>((num l, void _, num r) => l % r) |
    (_multi.ref & fDivOp & _unary.ref).action<num>((num l, void _, num r) => l ~/ r) |
    _unary.ref;

Parser<num> _unary() =>
    _power.ref | //
    (negOp & _unary.ref).action<num>((void _, num v) => -v);

Parser<num> _power() =>
    (_atomic.ref & powOp & _power.ref).action<num>((num l, void _, num r) => pow(l, r)) | //
    _atomic.ref;

Parser<num> _atomic() =>
    "0".urng("9").plus().flat().map<num>(int.parse).message("Expected a number") | //
    ("(".t() & _add.ref & ")".t()).action<num>((void l, num v, void r) => v);

Parser<num> postfix() => _postfix.ref;
Parser<num> _postfix() =>
    (_postfix.ref & _postfix.ref.t() & addOp).action<num>((num l, num r, void o) => l + r) |
    (_postfix.ref & _postfix.ref.t() & subOp).action<num>((num l, num r, void o) => l - r) |
    (_postfix.ref & _postfix.ref.t() & mulOp).action<num>((num l, num r, void o) => l * r) |
    (_postfix.ref & _postfix.ref.t() & divOp).action<num>((num l, num r, void o) => l / r) |
    (_postfix.ref & _postfix.ref.t() & modOp).action<num>((num l, num r, void o) => l % r) |
    (_postfix.ref & _postfix.ref.t() & fDivOp).action<num>((num l, num r, void o) => l ~/ r) |
    (_postfix.ref & _postfix.ref.t() & powOp).action<num>((num l, num r, void o) => pow(l, r)) |
    "0".urng("9").plus().flat().map<num>(num.parse).message("Expected a number");

Parser<num> prefix() => _prefix.ref;
Parser<num> _prefix() =>
    (addOp & _prefix.ref.t() & _prefix.ref).action<num>((void o, num l, num r) => l + r) |
    (subOp & _prefix.ref.t() & _prefix.ref).action<num>((void o, num l, num r) => l - r) |
    (mulOp & _prefix.ref.t() & _prefix.ref).action<num>((void o, num l, num r) => l * r) |
    (divOp & _prefix.ref.t() & _prefix.ref).action<num>((void o, num l, num r) => l / r) |
    (modOp & _prefix.ref.t() & _prefix.ref).action<num>((void o, num l, num r) => l % r) |
    (fDivOp & _prefix.ref.t() & _prefix.ref).action<num>((void o, num l, num r) => l ~/ r) |
    (powOp & _prefix.ref.t() & _prefix.ref).action<num>((void o, num l, num r) => pow(l, r)) |
    "0".urng("9").plus().flat().map<num>(num.parse).message("Expected a number");
