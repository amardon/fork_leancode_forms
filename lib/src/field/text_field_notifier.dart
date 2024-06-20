import 'package:leancode_forms/src/field/cubit/field_notifier.dart';

/// A specialization of [FieldNotifier] for a [String] value.
class TextFieldNotifier<E extends Object> extends FieldNotifier<String, E> {
  /// Creates a new [TextFieldNotifier].
  TextFieldNotifier({
    super.initialValue = '',
    super.validator,
    super.asyncValidator,
    super.asyncValidationDebounce,
  });

  /// Clears the value of the field.
  void clear() => reset();
}
