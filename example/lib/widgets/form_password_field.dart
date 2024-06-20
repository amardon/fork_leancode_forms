import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leancode_forms/leancode_forms.dart';
import 'package:leancode_forms_example/cubits/password_field_cubit.dart';
import 'package:leancode_forms_example/main.dart';
import 'package:leancode_forms_example/widgets/app_text_field.dart';

class FormPasswordField extends ConsumerWidget {
  const FormPasswordField({
    super.key,
    required StateNotifierProvider<PasswordFieldNotifier,
            FieldState<String, List<ValidationError>>>
        stateProvider,
    required ErrorTranslator<List<ValidationError>> translateError,
    TextEditingController? controller,
    String? labelText,
    String? hintText,
  })  : _stateProvider = stateProvider,
        _translateError = translateError,
        _controller = controller,
        _labelText = labelText,
        _hintText = hintText,
        super();

  final StateNotifierProvider<PasswordFieldNotifier,
      FieldState<String, List<ValidationError>>> _stateProvider;
  final ErrorTranslator<List<ValidationError>> _translateError;
  final TextEditingController? _controller;
  final String? _labelText;
  final String? _hintText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reader = ref.read(_stateProvider.notifier);
    final watcher = ref.watch(_stateProvider);
    return AppTextField(
      onChanged: reader.getValueSetter(),
      setValue: reader.setValue,
      errorText: (watcher.error?.isNotEmpty ?? false)
          ? _translateError(watcher.error!)
          : null,
      initialValue: watcher.value,
      controller: _controller,
      labelText: _labelText,
      hintText: _hintText,
    );
  }
}
