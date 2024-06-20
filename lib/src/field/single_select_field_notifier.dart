import 'package:leancode_forms/src/field/cubit/field_notifier.dart';

/// A specialization of [FieldNotifier] for a single choice of [V] value from List of [options].
class SingleSelectFieldNotifier<V, E extends Object>
    extends FieldNotifier<V?, E> {
  /// Creates a new [SingleSelectFieldNotifier].
  SingleSelectFieldNotifier({
    required super.initialValue,
    super.validator,
    required this.options,
  });

  /// List of options to select from.
  final List<V> options;

  /// Sets the value of the field to the [option].
  void select(V? option) => setValue(option);

  /// Resets selected value to the initial one.
  void clear() => reset();
}
