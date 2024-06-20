import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leancode_forms/leancode_forms.dart';
import 'package:leancode_forms_example/main.dart';

final quizFormNotifierProvider =
    StateNotifierProvider<QuizFormNotifier, FormGroupState>((ref) {
  return QuizFormNotifier(ref: ref);
});

class QuizFormNotifier extends FormGroupNotifier {
  QuizFormNotifier({
    required this.ref,
  }) {
    registerFields([
      ref.watch(riverQuestionTextFieldProvider.notifier),
      ref.watch(mountQuestionTextFieldProvider.notifier),
    ]);
  }

  final Ref ref;

  final riverQuestionTextFieldProvider = StateNotifierProvider<
      TextFieldNotifier<ValidationError>,
      FieldState<String, ValidationError>>((ref) {
    return TextFieldNotifier<ValidationError>();
  });

  final mountQuestionTextFieldProvider = StateNotifierProvider<
      TextFieldNotifier<ValidationError>,
      FieldState<String, ValidationError>>((ref) {
    return TextFieldNotifier<ValidationError>();
  });
}
