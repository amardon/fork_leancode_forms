import 'package:flutter/material.dart';
import 'package:leancode_forms/leancode_forms.dart';

class FocusableTextFieldNotifier<E extends Object>
    extends TextFieldNotifier<E> {
  FocusableTextFieldNotifier({
    super.initialValue,
    super.validator,
    super.asyncValidator,
    super.asyncValidationDebounce,
  });

  /// Focuses the field.
  void focus() => focusNode.requestFocus();

  /// The focus node of the field.
  final focusNode = FocusNode();
}
