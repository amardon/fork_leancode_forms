import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leancode_forms_example/main.dart';
import 'package:leancode_forms_example/screens/form_page.dart';
import 'package:leancode_forms_example/screens/simple_form/simple_form_notifier.dart';
import 'package:leancode_forms_example/widgets/form_text_field.dart';

/// This is an example of a simple form with two basic fields and one field with async validation.
/// The form is validated ONLY when the submit button is pressed.
class SimpleFormScreen extends ConsumerWidget {
  const SimpleFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormPage(
      title: 'Simple Form',
      child: SingleChildScrollView(
        child: Column(
          children: [
            FormTextField(
              stateProvider: ref
                  .watch(simpleFormNotifierProvider.notifier)
                  .firstNameNotifierProvider,
              translateError: validatorTranslator,
              labelText: 'First Name',
              hintText: 'Enter your first name',
              canSetToInitial: true,
            ),
            FormTextField(
              stateProvider: ref
                  .watch(simpleFormNotifierProvider.notifier)
                  .lastNameNotifierProvider,
              translateError: validatorTranslator,
              labelText: 'Last Name',
              hintText: 'Enter your last name',
              canSetToInitial: true,
            ),
            FormTextField(
              stateProvider: ref
                  .watch(simpleFormNotifierProvider.notifier)
                  .emailNotifierProvider,
              translateError: validatorTranslator,
              labelText: 'Email',
              hintText: 'Enter your email',
            ),
            ElevatedButton(
              onPressed: ref.read(simpleFormNotifierProvider.notifier).submit,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
