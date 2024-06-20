import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leancode_forms/leancode_forms.dart';

class FormSwitchField<E extends Object> extends ConsumerWidget {
  const FormSwitchField({
    super.key,
    required StateNotifierProvider<FieldNotifier<bool, E>, FieldState<bool, E>>
        stateProvider,
    String? labelText,
  })  : _stateProvider = stateProvider,
        _labelText = labelText,
        super();

  final StateNotifierProvider<FieldNotifier<bool, E>, FieldState<bool, E>>
      _stateProvider;
  final String? _labelText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_labelText != null) Flexible(child: Text(_labelText!)),
        Switch(
          value: ref.watch(_stateProvider).value,
          onChanged: ref.read(_stateProvider.notifier).getValueSetter(),
        ),
      ],
    );
  }
}
