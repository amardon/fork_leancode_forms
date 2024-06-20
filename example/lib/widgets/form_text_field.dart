import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leancode_forms/leancode_forms.dart';
import 'package:leancode_forms_example/cubits/focusable_text_field_cubit.dart';
import 'package:leancode_forms_example/main.dart';
import 'package:leancode_forms_example/widgets/app_text_field.dart';

class FormTextField<E extends Object> extends ConsumerWidget {
  const FormTextField({
    super.key,
    required StateNotifierProvider<TextFieldNotifier<ValidationError>,
            FieldState<String, ValidationError>>
        stateProvider,
    required ErrorTranslator<ValidationError> translateError,
    TextEditingController? controller,
    VoidCallback? onUnfocus,
    ValueChanged<String>? onFieldSubmitted,
    bool? trimOnUnfocus,
    String? labelText,
    String? hintText,
    bool canSetToInitial = false,
  })  : _stateProvider = stateProvider,
        _translateError = translateError,
        _controller = controller,
        _onUnfocus = onUnfocus,
        _onFieldSubmitted = onFieldSubmitted,
        _trimOnUnfocus = trimOnUnfocus,
        _labelText = labelText,
        _hintText = hintText,
        _canSetToInitial = canSetToInitial;

  final StateNotifierProvider<TextFieldNotifier<ValidationError>,
      FieldState<String, ValidationError>> _stateProvider;
  final ErrorTranslator<ValidationError> _translateError;
  final TextEditingController? _controller;
  final VoidCallback? _onUnfocus;
  final ValueChanged<String>? _onFieldSubmitted;
  final bool? _trimOnUnfocus;
  final String? _labelText;
  final String? _hintText;
  final bool _canSetToInitial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reader = ref.read(_stateProvider.notifier);
    final watcher = ref.watch(_stateProvider);
    return AppTextField(
      key: key,
      onChanged: reader.getValueSetter(),
      onUnfocus: _onUnfocus,
      onFieldSubmitted: _onFieldSubmitted,
      setValue: reader.setValue,
      trimOnUnfocus: _trimOnUnfocus ?? false,
      errorText: watcher.error != null ? _translateError(watcher.error!) : null,
      initialValue: watcher.value,
      controller: _controller,
      labelText: _labelText,
      hintText: _hintText,
      suffix: watcher.isValidating
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(),
            )
          : null,
      onSetToInitial: _canSetToInitial
          ? () {
              reader.clear();
              return watcher.value;
            }
          : null,
    );
  }
}

class FocusableFormTextField<E extends Object> extends ConsumerWidget {
  const FocusableFormTextField({
    super.key,
    required StateNotifierProvider<FocusableTextFieldNotifier<ValidationError>,
            FieldState<String, ValidationError>>
        stateProvider,
    required ErrorTranslator<ValidationError> translateError,
    TextEditingController? controller,
    VoidCallback? onUnfocus,
    ValueChanged<String>? onFieldSubmitted,
    bool? trimOnUnfocus,
    String? labelText,
    String? hintText,
  })  : _stateProvider = stateProvider,
        _translateError = translateError,
        _controller = controller,
        _onUnfocus = onUnfocus,
        _onFieldSubmitted = onFieldSubmitted,
        _trimOnUnfocus = trimOnUnfocus,
        _labelText = labelText,
        _hintText = hintText,
        super();

  final StateNotifierProvider<FocusableTextFieldNotifier<ValidationError>,
      FieldState<String, ValidationError>> _stateProvider;
  final ErrorTranslator<ValidationError> _translateError;
  final TextEditingController? _controller;
  final VoidCallback? _onUnfocus;
  final ValueChanged<String>? _onFieldSubmitted;
  final bool? _trimOnUnfocus;
  final String? _labelText;
  final String? _hintText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reader = ref.read(_stateProvider.notifier);
    final watcher = ref.watch(_stateProvider);
    return AppTextField(
      key: key,
      onChanged: reader.getValueSetter(),
      onUnfocus: _onUnfocus,
      onFieldSubmitted: _onFieldSubmitted,
      setValue: reader.setValue,
      trimOnUnfocus: _trimOnUnfocus ?? false,
      errorText: watcher.error != null ? _translateError(watcher.error!) : null,
      initialValue: watcher.value,
      controller: _controller,
      focusNode: reader.focusNode,
      labelText: _labelText,
      hintText: _hintText,
      suffix: watcher.isValidating
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(),
            )
          : null,
    );
  }
}
