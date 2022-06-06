// ignore_for_file: avoid_field_initializers_in_const_classes, avoid_positional_boolean_parameters

import "package:meta/meta.dart";
import "package:parser_typed/src/context/empty.dart";
import "package:parser_typed/src/context/failure.dart";
import "package:parser_typed/src/context/success.dart";

@immutable
abstract class Context<R extends Object?> {
  final String input;
  final int index;

  const Context(this.input, this.index);

  bool get isSuccess => this is Success<R>;
  bool get isFailure => this is Failure;
  bool get isEmpty => this is Empty;

  Context<R> replaceIndex(int index);
  Context<R> replaceInput(String input);
  Context<R> inherit<I extends Object?>(Context<I> context);

  @pragma("vm:prefer-inline")
  Success<O> success<O extends Object?>(O result, [int? index]) => //
      Success<O>(result, input, index ?? this.index);

  @pragma("vm:prefer-inline")
  Failure failure([String? message, bool artificial = false]) => //
      (artificial ? Failure.artificial : Failure.new)(message ?? this.message, input, index);

  @pragma("vm:prefer-inline")
  Empty empty([int? index]) => Empty(input, index ?? this.index);

  @pragma("vm:prefer-inline")
  Context<O> cast<O extends Object?>() => this as Context<O>;

  R get value;
  String get message;

  /// Counts all the newline tokens up until [index], adding 1.
  int get line => "$input ".substring(0, index + 1).split("\n").length;

  /// Gets the current line of [index], then counts all the characters until the latest newline OR beginning of input.
  int get column => "$input ".substring(0, index + 1).split("\n").last.length;

  String get location => "$line:$column";
}

extension FailureExtension on Failure Function([String? message, bool artificial]) {
  Failure artificial([String? message]) => this(message, true);
}
