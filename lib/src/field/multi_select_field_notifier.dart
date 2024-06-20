import 'package:leancode_forms/src/field/cubit/field_notifier.dart';

/// A specialization of [FieldNotifier] for a multiple choice of [V] values.
class MultiSelectFieldNotifier<V, E extends Object>
    extends FieldNotifier<Set<V>, E> {
  /// Creates a new [MultiSelectFieldNotifier].
  MultiSelectFieldNotifier({
    required super.initialValue,
    super.validator,
    required this.options,
  });

  /// List of options to select from.
  final List<V> options;

  /// Toggles the given [value].
  void toggleElement(V value) {
    if (state.value.contains(value)) {
      removeValue(value);
    } else {
      addValue(value);
    }
  }

  /// Adds the given [value].
  void addValue(V value) {
    setValue(Set<V>.from(state.value)..add(value));
  }

  /// Removes the given [value].
  void removeValue(V value) {
    setValue(Set<V>.from(state.value)..remove(value));
  }

  /// Resets selected values to the initial value.
  void clear() => reset();
}
