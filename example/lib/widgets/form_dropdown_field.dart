import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leancode_forms/leancode_forms.dart';
import 'package:leancode_forms_example/widgets/app_dropdown_field.dart';

class FormDropDownField<T, E extends Object> extends ConsumerWidget {
  const FormDropDownField({
    super.key,
    required StateNotifierProvider<SingleSelectFieldNotifier<T, E>,
            FieldState<T?, E>>
        stateProvider,
    required String Function(T) labelBuilder,
    required ErrorTranslator<E> translateError,
    String? labelText,
    String? hintText,
    bool canSetToInitial = false,
  })  : _stateProvider = stateProvider,
        _labelBuilder = labelBuilder,
        _translateError = translateError,
        _labelText = labelText,
        _hintText = hintText,
        _canSetToInitial = canSetToInitial,
        super();

  final StateNotifierProvider<SingleSelectFieldNotifier<T, E>,
      FieldState<T?, E>> _stateProvider;
  final String Function(T) _labelBuilder;
  final ErrorTranslator<E> _translateError;
  final String? _labelText;
  final String? _hintText;
  final bool _canSetToInitial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reader = ref.read(_stateProvider.notifier);
    final watcher = ref.watch(_stateProvider);
    return AppDropdownField(
      value: watcher.value,
      options: reader.options,
      onChanged: reader.select,
      labelBuilder: _labelBuilder,
      label: _labelText,
      hint: _hintText,
      errorText: watcher.error != null ? _translateError(watcher.error!) : null,
      onSetToInitial: _canSetToInitial ? reader.clear : null,
      onEmpty: () => reader.select(null),
    );
  }
}
