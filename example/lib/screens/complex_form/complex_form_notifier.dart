import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leancode_forms/leancode_forms.dart';
import 'package:leancode_forms_example/main.dart';
import 'package:rxdart/rxdart.dart';

final complexFormProvider =
    StateNotifierProvider<ComplexFormNotifier, FormGroupState>((ref) {
  return ComplexFormNotifier(ref: ref);
});

final humanSubFormProvider =
    StateNotifierProvider<HumanSubformNotifier, FormGroupState>((ref) {
  return HumanSubformNotifier(ref: ref);
});

final dogSubFormProvider =
    StateNotifierProvider<DogSubformNotifier, FormGroupState>((ref) {
  return DogSubformNotifier(ref: ref);
});

class ComplexFormNotifier extends FormGroupNotifier {
  ComplexFormNotifier({
    required this.ref,
  }) {
    registerFields([
      ref.watch(typeProvider.notifier),
    ]);
    addDisposable(
      ref
          .watch(typeProvider.notifier)
          .stream
          .map((event) => event.value)
          .distinct()
          .debounceTime(const Duration(milliseconds: 500))
          .listen(_onTypeUpdated)
          .cancel,
    );
  }

  final Ref ref;

  final typeProvider = StateNotifierProvider<
      SingleSelectFieldNotifier<SubformType, ValidationError>,
      FieldState<SubformType?, ValidationError>>((ref) {
    return SingleSelectFieldNotifier<SubformType, ValidationError>(
      options: SubformType.values,
      initialValue: null,
    );
  });

  SubformType? subformType;

  Future<void> _onTypeUpdated(SubformType? type) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    subformType = type;

    if (type == SubformType.human) {
      addSubform(ref.watch(humanSubFormProvider.notifier));
    } else {
      ref.watch(humanSubFormProvider.notifier).resetAll();
      await removeSubform(
        ref.watch(humanSubFormProvider.notifier),
        close: false,
      );
    }
    if (type == SubformType.dog) {
      addSubform(ref.watch(dogSubFormProvider.notifier));
    } else {
      ref.watch(dogSubFormProvider.notifier).resetAll();
      await removeSubform(ref.watch(dogSubFormProvider.notifier), close: false);
    }
  }

  void submit() {
    final humanSubForm = ref.read(humanSubFormProvider.notifier);
    final dogSubForm = ref.read(dogSubFormProvider.notifier);
    if (validate()) {
      debugPrint('Form is valid!');
      debugPrint(
        'Gender ${ref.read(humanSubForm.genderSelectFieldProvider).value}',
      );
      debugPrint(
        'Human age ${ref.read(humanSubForm.ageTextFieldProvider).value}',
      );
      debugPrint(
        'Breed ${ref.read(dogSubForm.breedSelectFieldProvider).value}',
      );
      debugPrint(
        'Dog age ${ref.read(dogSubForm.ageTextFieldProvider).value}',
      );
    } else {
      debugPrint('Form is invalid!');
      debugPrint(
        'Gender ${ref.read(humanSubForm.genderSelectFieldProvider).value}',
      );
      debugPrint(
        'Human age ${ref.read(humanSubForm.ageTextFieldProvider).value}',
      );
      debugPrint(
        'Breed ${ref.read(dogSubForm.breedSelectFieldProvider).value}',
      );
      debugPrint(
        'Dog age ${ref.read(dogSubForm.ageTextFieldProvider).value}',
      );
    }
  }
}

class HumanSubformNotifier extends FormGroupNotifier {
  HumanSubformNotifier({
    required this.ref,
  }) {
    registerFields([
      ref.watch(genderSelectFieldProvider.notifier),
      ref.watch(ageTextFieldProvider.notifier),
    ]);
  }

  final Ref ref;

  final genderSelectFieldProvider = StateNotifierProvider<
      SingleSelectFieldNotifier<Gender, ValidationError>,
      FieldState<Gender?, ValidationError>>((ref) {
    return SingleSelectFieldNotifier<Gender, ValidationError>(
      initialValue: Gender.male,
      options: Gender.values,
    );
  });

  final ageTextFieldProvider = StateNotifierProvider<
      TextFieldNotifier<ValidationError>,
      FieldState<String, ValidationError>>((ref) {
    return TextFieldNotifier<ValidationError>(
      validator: filled(ValidationError.empty),
    );
  });
}

class DogSubformNotifier extends FormGroupNotifier {
  DogSubformNotifier({required this.ref}) {
    registerFields([
      ref.watch(breedSelectFieldProvider.notifier),
      ref.watch(ageTextFieldProvider.notifier),
    ]);
  }

  final Ref ref;

  final breedSelectFieldProvider = StateNotifierProvider<
      SingleSelectFieldNotifier<Breed, ValidationError>,
      FieldState<Breed?, ValidationError>>((ref) {
    return SingleSelectFieldNotifier<Breed, ValidationError>(
      initialValue: null,
      options: Breed.values,
      validator: (value) {
        if (value == null) {
          return ValidationError.empty;
        }
        return null;
      },
    );
  });

  final ageTextFieldProvider = StateNotifierProvider<
      TextFieldNotifier<ValidationError>,
      FieldState<String, ValidationError>>((ref) {
    return TextFieldNotifier<ValidationError>(
      validator: filled(ValidationError.empty),
    );
  });
}

enum SubformType {
  dog,
  human,
}

enum Gender {
  male,
  female,
}

enum Breed {
  beagle,
  bulldog,
  chihuahua,
  dachshund,
  dalmatian,
  germanShepherd,
  goldenRetriever,
  greatDane,
  husky,
  labrador,
  poodle,
  pug,
  rottweiler,
  terrier,
}
