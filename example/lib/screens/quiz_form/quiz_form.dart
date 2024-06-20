import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leancode_forms_example/main.dart';
import 'package:leancode_forms_example/screens/form_page.dart';
import 'package:leancode_forms_example/screens/quiz_form/quiz_form_notifier.dart';
import 'package:leancode_forms_example/screens/quiz_form/quiz_form_state.dart';
import 'package:leancode_forms_example/widgets/form_text_field.dart';

/// This is an example of a form which is asynchronously validated after pressing the submit button.
/// Errors on the fields are set/cleared manually after the validation is complete.
class QuizFormScreen extends ConsumerWidget {
  const QuizFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formStatus = ref.watch(quizStateProvider).validationStatus;

    return FormPage(
      title: 'Quiz Form',
      child: Column(
        children: [
          const Text('What is the longest river in the world?'),
          FormTextField(
            stateProvider: ref
                .watch(quizFormNotifierProvider.notifier)
                .riverQuestionTextFieldProvider,
            trimOnUnfocus: true,
            translateError: validatorTranslator,
            hintText: 'Answer here',
          ),
          const SizedBox(height: 16),
          const Text('What is the highest mountain in the world?'),
          FormTextField(
            stateProvider: ref
                .watch(quizFormNotifierProvider.notifier)
                .mountQuestionTextFieldProvider,
            trimOnUnfocus: true,
            translateError: validatorTranslator,
            hintText: 'Answer here',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: ref.watch(quizStateProvider.notifier).submit,
            child: const Text('Send answers'),
          ),
          const SizedBox(height: 16),
          Text(formStatus.name),
        ],
      ),
    );
  }
}
