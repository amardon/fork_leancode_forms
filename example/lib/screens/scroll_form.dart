import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leancode_forms/leancode_forms.dart';
import 'package:leancode_forms_example/cubits/focusable_text_field_cubit.dart';
import 'package:leancode_forms_example/main.dart';
import 'package:leancode_forms_example/screens/form_page.dart';
import 'package:leancode_forms_example/utils/extensions/iterable_extensions.dart';
import 'package:leancode_forms_example/widgets/form_text_field.dart';

class ScrollFormScreen extends ConsumerWidget {
  const ScrollFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(failedSubmitProvider, (a, newState) {
      if (newState is SubmitFailedWithErrors) {
        final scrollFormCubit = ref.read(scrollFormProvider.notifier);
        final fields = [
          scrollFormCubit.firstFieldProvider,
          scrollFormCubit.secondFieldProvider,
          scrollFormCubit.thirdFieldProvider,
        ];
        final errorField =
            fields.firstWhereOrNull((field) => ref.read(field).isInvalid);
        if (errorField != null) {
          ref.read(errorField.notifier).focus();
        }
      }
      ref.read(failedSubmitProvider.notifier).state = null;
    });

    final scrollForm = ref.watch(scrollFormProvider.notifier);
    return FormPage(
      title: 'Scroll Form',
      child: SingleChildScrollView(
        child: Column(
          children: [
            FocusableFormTextField(
              stateProvider: scrollForm.firstFieldProvider,
              translateError: validatorTranslator,
              labelText: 'First field',
              hintText: 'Write here...',
              onFieldSubmitted: (_) =>
                  ref.read(scrollForm.secondFieldProvider.notifier).focus(),
            ),
            const SizedBox(height: 260),
            FocusableFormTextField(
              stateProvider: scrollForm.secondFieldProvider,
              translateError: validatorTranslator,
              labelText: 'Second field',
              hintText: 'Write here...',
              onFieldSubmitted: (_) =>
                  ref.read(scrollForm.thirdFieldProvider.notifier).focus(),
            ),
            const SizedBox(height: 260),
            FocusableFormTextField(
              stateProvider: scrollForm.thirdFieldProvider,
              translateError: validatorTranslator,
              labelText: 'Third field',
              hintText: 'Write here...',
            ),
            const SizedBox(height: 260),
            ElevatedButton(
              onPressed: ref.read(scrollFormProvider.notifier).submit,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

final failedSubmitProvider = StateProvider<ScrollFormCubitEvent?>((ref) {
  return;
});

final scrollFormProvider =
    StateNotifierProvider<ScrollFormNotifier, FormGroupState>((ref) {
  return ScrollFormNotifier(ref: ref);
});

class ScrollFormNotifier extends FormGroupNotifier {
  ScrollFormNotifier({
    required this.ref,
  }) {
    registerFields([
      ref.watch(firstFieldProvider.notifier),
      ref.watch(secondFieldProvider.notifier),
      ref.watch(thirdFieldProvider.notifier),
    ]);
  }

  final Ref ref;

  final firstFieldProvider = StateNotifierProvider<
      FocusableTextFieldNotifier<ValidationError>,
      FieldState<String, ValidationError>>((ref) {
    return FocusableTextFieldNotifier<ValidationError>(
      validator: filled(ValidationError.empty),
    );
  });

  final secondFieldProvider = StateNotifierProvider<
      FocusableTextFieldNotifier<ValidationError>,
      FieldState<String, ValidationError>>((ref) {
    return FocusableTextFieldNotifier<ValidationError>(
      validator: filled(ValidationError.empty),
    );
  });

  final thirdFieldProvider = StateNotifierProvider<
      FocusableTextFieldNotifier<ValidationError>,
      FieldState<String, ValidationError>>((ref) {
    return FocusableTextFieldNotifier<ValidationError>(
      validator: filled(ValidationError.empty),
    );
  });

  void submit() {
    if (validate()) {
      debugPrint('Submit successful');
    } else {
      ref.read(failedSubmitProvider.notifier).state =
          const SubmitFailedWithErrors();
    }
  }
}

sealed class ScrollFormCubitEvent {}

class SubmitFailedWithErrors implements ScrollFormCubitEvent {
  const SubmitFailedWithErrors();
}
