import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leancode_forms/leancode_forms.dart';
import 'package:leancode_forms_example/main.dart';

final simpleFormNotifierProvider =
    StateNotifierProvider<SimpleFormNotifier, FormGroupState>((ref) {
  return SimpleFormNotifier(ref: ref);
});

class SimpleFormNotifier extends FormGroupNotifier {
  SimpleFormNotifier({
    required this.ref,
  }) {
    registerFields([
      ref.watch(firstNameNotifierProvider.notifier),
      ref.watch(lastNameNotifierProvider.notifier),
      ref.watch(emailNotifierProvider.notifier),
    ]);
  }
  final Ref ref;

  final firstNameNotifierProvider = StateNotifierProvider<
      TextFieldNotifier<ValidationError>,
      FieldState<String, ValidationError>>((ref) {
    return TextFieldNotifier(
      initialValue: 'John',
      validator: filled(ValidationError.empty),
    );
  });

  final lastNameNotifierProvider = StateNotifierProvider<
      TextFieldNotifier<ValidationError>,
      FieldState<String, ValidationError>>((ref) {
    return TextFieldNotifier(
      initialValue: 'Doe',
      validator: filled(ValidationError.empty),
    );
  });

  //A field with async validation
  final emailNotifierProvider = StateNotifierProvider<
      TextFieldNotifier<ValidationError>,
      FieldState<String, ValidationError>>((ref) {
    //Async validator
    Future<ValidationError?> onEmailChanged(String value) async {
      final takenEmail = ['john@email.com', 'jack@email.com'];
      await Future<void>.delayed(const Duration(milliseconds: 700));
      return takenEmail.contains(value) ? ValidationError.emailTaken : null;
    }

    return TextFieldNotifier(
      validator: filled(ValidationError.empty),
      asyncValidator: onEmailChanged,
      asyncValidationDebounce: const Duration(milliseconds: 500),
    );
  });

  void submit() {
    //Change to true to enable autovalidation of each field after pressing submit.
    if (validate(enableAutovalidate: false)) {
      debugPrint('First name: ${ref.watch(firstNameNotifierProvider).value}');
      debugPrint('Last name: ${ref.watch(lastNameNotifierProvider).value}');
      debugPrint('Email: ${ref.watch(emailNotifierProvider).value}');
    } else {
      debugPrint('Form is invalid');
    }
  }
}
