import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leancode_forms/leancode_forms.dart';
import 'package:leancode_forms_example/main.dart';
import 'package:leancode_forms_example/screens/simple_form/simple_form_page.dart';

void main() {
  blocTest<SimpleFormNotifier, FormGroupState>(
    'sets email when setValue is called',
    build: SimpleFormNotifier.new,
    act: (cubit) => cubit.email.setValue('john@email.com'),
    verify: (cubit) {
      expect(cubit.email.state.value, 'john@email.com');
    },
  );

  blocTest<SimpleFormNotifier, FormGroupState>(
    'sets ValidationErrors.emailTaken when email is taken',
    build: SimpleFormNotifier.new,
    act: (cubit) => cubit.email.setValue('john@email.com'),
    wait: const Duration(seconds: 2),
    verify: (cubit) async {
      expect(cubit.email.state.error, ValidationError.emailTaken);
    },
  );

  blocTest<SimpleFormNotifier, FormGroupState>(
    'should not have any errors before submit method invoked',
    build: SimpleFormNotifier.new,
    verify: (cubit) {
      expect(cubit.email.state.error, null);
      expect(cubit.firstName.state.error, null);
      expect(cubit.lastName.state.error, null);
    },
  );

  blocTest<SimpleFormNotifier, FormGroupState>(
    'validates fields and sets errors after submit method invoked',
    build: SimpleFormNotifier.new,
    act: (cubit) => cubit.validate(),
    verify: (cubit) {
      expect(cubit.email.state.error, ValidationError.empty);
      expect(cubit.firstName.state.error, ValidationError.empty);
      expect(cubit.lastName.state.error, ValidationError.empty);
    },
  );
}
