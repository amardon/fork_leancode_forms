import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leancode_forms/leancode_forms.dart';
import 'package:leancode_forms_example/cubits/password_field_cubit.dart';
import 'package:leancode_forms_example/main.dart';
import 'package:leancode_forms_example/screens/form_page.dart';
import 'package:leancode_forms_example/widgets/form_password_field.dart';
import 'package:leancode_forms_example/widgets/form_switch_field.dart';
import 'package:leancode_forms_example/widgets/form_text_field.dart';

/// This is an example of a form with a password/repeat password fields.
/// In this form repeatPassword field is validated according to value in the password field.
class PasswordFormScreen extends ConsumerWidget {
  const PasswordFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameTextFieldProvider =
        ref.watch(passwordFormProvider.notifier).usernameTextFieldProvider;
    return FormPage(
      title: 'Password Form',
      child: Column(
        children: [
          //This field starts to be validated as soon as it loses focus for the first time
          FormTextField(
            stateProvider: usernameTextFieldProvider,
            onUnfocus: () {
              ref.read(usernameTextFieldProvider.notifier)
                ..setAutovalidate(true)
                ..validate();
            },
            translateError: validatorTranslator,
            labelText: 'Username',
            hintText: 'Enter your username',
          ),
          const SizedBox(height: 16),
          FormSwitchField(
            stateProvider:
                ref.watch(passwordFormProvider.notifier).switchFieldProvider,
            labelText: 'Repeat password should be 10 characters long',
          ),
          const SizedBox(height: 16),
          FormPasswordField(
            stateProvider: ref
                .watch(passwordFormProvider.notifier)
                .passwordTextFieldProvider,
            translateError: (error) => validatorTranslator(error.first),
            labelText: 'Password',
            hintText: 'Enter your password',
          ),
          const SizedBox(height: 16),
          FormTextField(
            stateProvider: ref
                .watch(passwordFormProvider.notifier)
                .repeatPasswordTextFieldProvider,
            translateError: validatorTranslator,
            labelText: 'Repeat Password',
            hintText: 'Repeat your password',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: ref.read(passwordFormProvider.notifier).submit,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

final passwordFormProvider =
    StateNotifierProvider<PasswordFormNotifier, FormGroupState>((ref) {
  return PasswordFormNotifier(ref: ref);
});

class PasswordFormNotifier extends FormGroupNotifier {
  PasswordFormNotifier({
    required this.ref,
  }) {
    registerFields([
      ref.watch(usernameTextFieldProvider.notifier),
      ref.watch(switchFieldProvider.notifier),
      ref.watch(passwordTextFieldProvider.notifier),
      ref.watch(repeatPasswordTextFieldProvider.notifier),
    ]);
  }

  final Ref ref;

  final usernameTextFieldProvider = StateNotifierProvider<
      TextFieldNotifier<ValidationError>,
      FieldState<String, ValidationError>>((ref) {
    return TextFieldNotifier(
      validator: filled(ValidationError.empty) &
          atLeastLength(5, ValidationError.toShort),
    );
  });

  final switchFieldProvider = StateNotifierProvider<
      BooleanFieldNotifier<ValidationError>,
      FieldState<bool, ValidationError>>((ref) {
    return BooleanFieldNotifier();
  });

  final passwordTextFieldProvider = StateNotifierProvider<PasswordFieldNotifier,
      FieldState<String, List<ValidationError>>>((ref) {
    return PasswordFieldNotifier(
      numberRequired: true,
      specialCharRequired: true,
      upperCaseRequired: true,
      lowerCaseRequired: true,
    );
  });

  late final repeatPasswordTextFieldProvider = StateNotifierProvider<
      TextFieldNotifier<ValidationError>,
      FieldState<String, ValidationError>>((ref) {
    return TextFieldNotifier(
      validator: passwordMatch(
        ref.watch(passwordTextFieldProvider.notifier),
        ValidationError.doesNotMatch,
      ),
    )..subscribeToFields([
        ref.watch(switchFieldProvider.notifier),
        ref.watch(passwordTextFieldProvider.notifier),
      ]);
  });

  Validator<String?, E> passwordMatch<E extends Object>(
    PasswordFieldNotifier passwordCubit,
    E message,
  ) =>
      (value) {
        if (value != passwordCubit.state.value) {
          return message;
        }
        return null;
      };

  void submit() {
    if (validate()) {
      debugPrint('Username: ${ref.read(usernameTextFieldProvider).value}');
      debugPrint('Switch field: ${ref.read(switchFieldProvider).value}');
      debugPrint('Password: ${ref.read(passwordTextFieldProvider).value}');
      debugPrint(
        'Repeated password: ${ref.read(repeatPasswordTextFieldProvider).value}',
      );
    } else {
      debugPrint('Form is invalid');
      debugPrint('Username: ${ref.read(usernameTextFieldProvider).value}');
      debugPrint('Switch field: ${ref.read(switchFieldProvider).value}');
      debugPrint('Password: ${ref.read(passwordTextFieldProvider).value}');
      debugPrint(
        'Repeated password: ${ref.read(repeatPasswordTextFieldProvider).value}',
      );
    }
  }
}
