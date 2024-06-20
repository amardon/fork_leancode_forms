import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leancode_forms_example/main.dart';
import 'package:leancode_forms_example/screens/quiz_form/quiz_form_notifier.dart';

enum ValidationStatus {
  inProgress,
  valid,
  invalid,
  none,
}

class QuizState {
  QuizState({this.validationStatus = ValidationStatus.none});

  final ValidationStatus validationStatus;
}

class QuizStateNotifier extends StateNotifier<QuizState> {
  QuizStateNotifier({
    required this.ref,
  }) : super(QuizState());

  final Ref ref;

  Future<void> submit() async {
    state = QuizState(validationStatus: ValidationStatus.inProgress);
    debugPrint('Validation in progress...');

    final quizForm = ref.read(quizFormNotifierProvider.notifier);
    final result = await quizValidation(
      ref.read(quizForm.riverQuestionTextFieldProvider).value,
      ref.read(quizForm.mountQuestionTextFieldProvider).value,
    );

    ref.read(quizForm.riverQuestionTextFieldProvider.notifier).setError(
          result.$1 ? null : ValidationError.invalidAnswer,
        );
    ref.read(quizForm.mountQuestionTextFieldProvider.notifier).setError(
          result.$2 ? null : ValidationError.invalidAnswer,
        );

    if (result.$1 && result.$2) {
      state = QuizState(validationStatus: ValidationStatus.valid);
      debugPrint('Validation successful!');
    } else {
      state = QuizState(validationStatus: ValidationStatus.invalid);
      debugPrint('Validation failed!');
    }
  }

  Future<(bool, bool)> quizValidation(String answer1, String answer2) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return (answer1 == 'Nile', answer2 == 'Everest');
  }
}

final quizStateProvider =
    StateNotifierProvider<QuizStateNotifier, QuizState>((ref) {
  return QuizStateNotifier(ref: ref);
});
