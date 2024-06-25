import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:leancode_forms/leancode_forms.dart';

/// This is an example of custom text field created for an app.
/// It's created in order to show how to use [FieldNotifier] with custom fields.
class AppTextField extends HookWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.onChanged,
    this.onUnfocus,
    this.onFieldSubmitted,
    required this.setValue,
    this.trimOnUnfocus = false,
    this.labelText,
    this.hintText,
    this.errorText,
    this.suffix,
    this.onSetToInitial,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onUnfocus;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String> setValue;
  final bool trimOnUnfocus;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final Widget? suffix;
  final String Function()? onSetToInitial;

  @override
  Widget build(BuildContext context) {
    final textEditingController =
        controller ?? useTextEditingController(text: initialValue);
    final focusNode = this.focusNode ?? useFocusNode();

    useEffect(
      () {
        void listener() {
          if (!focusNode.hasFocus) {
            onUnfocus?.call();
            if (trimOnUnfocus) {
              final trimmedValue = textEditingController.text.trim();
              textEditingController.text = trimmedValue;
              setValue(trimmedValue);
            }
          }
        }

        focusNode.addListener(listener);
        return () => focusNode.removeListener(listener);
      },
      [],
    );

    return Row(
      children: [
        Flexible(
          child: TextFormField(
            autocorrect: false,
            focusNode: focusNode,
            controller: textEditingController,
            onChanged: onChanged,
            onTapOutside: (_) => focusNode.unfocus(),
            onFieldSubmitted: onFieldSubmitted,
            decoration: InputDecoration(
              labelText: labelText,
              hintText: hintText,
              errorText: errorText,
              suffix: suffix,
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {
            textEditingController.clear();
            setValue('');
          },
          child: const Text('Empty'),
        ),
        if (onSetToInitial case final onSetToInitial?) ...[
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => textEditingController.text = onSetToInitial(),
            child: const Text('Set to initial'),
          ),
        ],
      ],
    );
  }
}
