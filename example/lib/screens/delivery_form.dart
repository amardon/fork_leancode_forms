import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leancode_forms/leancode_forms.dart';
import 'package:leancode_forms_example/main.dart';
import 'package:leancode_forms_example/screens/form_page.dart';
import 'package:leancode_forms_example/widgets/form_dropdown_field.dart';
import 'package:leancode_forms_example/widgets/form_text_field.dart';

/// This is an example of a form with dynamically added subforms.
class DeliveryListFormScreen extends ConsumerWidget {
  const DeliveryListFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormPage(
      title: 'Delivery List Form',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...ref.watch(deliveryListFormProvider).subforms.map(
                  (e) => ConsumerSubform(
                    key: ValueKey(e.hashCode),
                    form: e as ConsumerSubformNotifier,
                    onRemove: ref
                        .read(deliveryListFormProvider.notifier)
                        .removeConsumer,
                  ),
                ),
            ElevatedButton(
              onPressed:
                  ref.read(deliveryListFormProvider.notifier).addConsumer,
              child: const Text('Add Consumer'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: ref.read(deliveryListFormProvider.notifier).submit,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class ConsumerSubform extends ConsumerWidget {
  const ConsumerSubform({
    super.key,
    required this.form,
    required this.onRemove,
  });

  final ConsumerSubformNotifier form;
  final ValueChanged<ConsumerSubformNotifier> onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Consumer'),
            IconButton(
              onPressed: () => onRemove(form),
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FormTextField(
          stateProvider: form.emailTextFieldProvider,
          translateError: validatorTranslator,
          labelText: 'Email',
          hintText: 'Enter consumer email',
        ),
        const SizedBox(height: 16),
        FormDropDownField(
          stateProvider: form.countrySelectFieldProvider,
          labelBuilder: (country) => country!.name,
          translateError: validatorTranslator,
          labelText: 'Country',
          hintText: 'Select consumer country',
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

final deliveryListFormProvider =
    StateNotifierProvider<DeliveryListFormNotifier, FormGroupState>((ref) {
  return DeliveryListFormNotifier(ref: ref);
});

class DeliveryListFormNotifier extends FormGroupNotifier {
  DeliveryListFormNotifier({
    required this.ref,
  });

  final Ref ref;

  final deliveryList = <ConsumerSubformNotifier>{};

  void addConsumer() {
    final consumerForm = ConsumerSubformNotifier(ref: ref);
    addSubform(consumerForm);
    deliveryList.add(consumerForm);
  }

  void removeConsumer(ConsumerSubformNotifier form) {
    removeSubform(form);
    deliveryList.remove(form);
  }

  void submit() {
    if (validate()) {
      for (final consumer in deliveryList) {
        debugPrint(
          'Consumer email: ${ref.read(consumer.emailTextFieldProvider).value}',
        );
        debugPrint(
          'Consumer country: ${ref.read(consumer.countrySelectFieldProvider).value}',
        );
      }
      debugPrint('Form is valid');
    } else {
      debugPrint('Form is invalid');
    }
  }
}

class ConsumerSubformNotifier extends FormGroupNotifier {
  ConsumerSubformNotifier({
    required this.ref,
  }) {
    registerFields([
      ref.watch(emailTextFieldProvider.notifier),
      ref.watch(countrySelectFieldProvider.notifier),
    ]);
  }

  final Ref ref;

  final emailTextFieldProvider = StateNotifierProvider<
      TextFieldNotifier<ValidationError>,
      FieldState<String, ValidationError>>((ref) {
    return TextFieldNotifier(
      validator: filled(ValidationError.empty),
    );
  });

  final countrySelectFieldProvider = StateNotifierProvider<
      SingleSelectFieldNotifier<Country?, ValidationError>,
      FieldState<Country?, ValidationError>>((ref) {
    return SingleSelectFieldNotifier<Country?, ValidationError>(
      initialValue: null,
      options: Country.values,
      validator: (country) {
        if (country == null) {
          return ValidationError.empty;
        }
        return null;
      },
    );
  });
}

enum Country {
  usa,
  canada,
  mexico,
}
