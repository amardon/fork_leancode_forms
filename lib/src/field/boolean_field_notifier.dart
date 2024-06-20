import 'package:leancode_forms/src/field/cubit/field_notifier.dart';

/// A specialization of [FieldNotifier] for a [bool] value.
class BooleanFieldNotifier<E extends Object> extends FieldNotifier<bool, E> {
  /// Creates a new [BooleanFieldNotifier].
  BooleanFieldNotifier({
    super.initialValue = false,
    super.validator,
    super.asyncValidator,
    super.asyncValidationDebounce,
  });
}
