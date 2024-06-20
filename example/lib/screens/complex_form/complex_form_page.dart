import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leancode_forms_example/main.dart';
import 'package:leancode_forms_example/screens/complex_form/complex_form_notifier.dart';
import 'package:leancode_forms_example/screens/form_page.dart';
import 'package:leancode_forms_example/widgets/form_dropdown_field.dart';
import 'package:leancode_forms_example/widgets/form_text_field.dart';

/// This is an example of a simple form with two fields.
/// The form is validated ONLY when the submit button is pressed.
class ComplexFormScreen extends ConsumerWidget {
  const ComplexFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typeProvider = ref.watch(complexFormProvider.notifier).typeProvider;
    return FormPage(
      title: 'Complex Form',
      child: SingleChildScrollView(
        child: Column(
          children: [
            FormDropDownField(
              stateProvider: typeProvider,
              labelBuilder: (value) => value.name,
              translateError: validatorTranslator,
              labelText: 'Subform Type',
              hintText: 'Select subform type',
            ),
            Builder(
              builder: (context) {
                final type = ref.watch(typeProvider).value;

                return switch (type) {
                  SubformType.human => const HumanSubform(),
                  SubformType.dog => const DogSubform(),
                  _ => const SizedBox(),
                };
              },
            ),
            ElevatedButton(
              onPressed: ref.read(complexFormProvider.notifier).submit,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class HumanSubform extends ConsumerWidget {
  const HumanSubform({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        FormDropDownField(
          stateProvider: ref
              .watch(humanSubFormProvider.notifier)
              .genderSelectFieldProvider,
          labelBuilder: (value) => value.name,
          translateError: validatorTranslator,
          labelText: 'Gender',
          hintText: 'Select gender',
          canSetToInitial: true,
        ),
        const SizedBox(height: 16),
        FormTextField(
          stateProvider:
              ref.watch(humanSubFormProvider.notifier).ageTextFieldProvider,
          translateError: validatorTranslator,
          labelText: 'Age',
          hintText: 'Enter human age',
        ),
      ],
    );
  }
}

class DogSubform extends ConsumerWidget {
  const DogSubform({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        FormDropDownField(
          stateProvider:
              ref.watch(dogSubFormProvider.notifier).breedSelectFieldProvider,
          labelBuilder: (value) => value.name,
          translateError: validatorTranslator,
          labelText: 'Breed',
          hintText: 'Select breed',
        ),
        const SizedBox(height: 16),
        FormTextField(
          stateProvider:
              ref.watch(dogSubFormProvider.notifier).ageTextFieldProvider,
          translateError: validatorTranslator,
          labelText: 'Age',
          hintText: 'Enter dog age',
        ),
      ],
    );
  }
}
