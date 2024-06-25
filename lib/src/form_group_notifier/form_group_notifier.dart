import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:leancode_forms/src/field/cubit/field_notifier.dart';
import 'package:leancode_forms/src/utils/disposable.dart';
import 'package:leancode_forms/src/utils/extensions/stream_extensions.dart';
import 'package:rxdart/rxdart.dart';

/// A parent of multiple [FieldNotifier]s. Manages group validation and tracks changes
/// as well as cleans up needed resources.
///
/// A form is a tree which can be recursively defined:
///   1. A form is the root of its own form tree
///   2. A form has direct leaves, which are fields
///   3. A form can have subtrees, which are forms (called subforms)
///
/// Most methods broadcast to all subforms.
///
/// Introducing cycles in forms is not supported and not checked against (most likely will cause a stack overflow somewhere).
class FormGroupNotifier extends StateNotifier<FormGroupState> with Disposable {
  /// Creates a new [FormGroupNotifier].
  FormGroupNotifier({
    this.debugName = '',
    this.validateAll = false,
  }) : super(const FormGroupState()) {
    addDisposable(_fieldsController.close);
    addDisposable(_fieldsStatusController.close);
    addDisposable(() => _onFieldsChangeSubscription?.cancel());
    addDisposable(() => _onFieldsStatusChangeSubscription?.cancel());
    addDisposable(
      stream
          .map(
            (event) => (
              fields: event.fields,
              subforms: event.subforms,
            ),
          )
          .distinct()
          .listen(_onFieldsChanged)
          .cancel,
    );
    addDisposable(
      onValuesChangedStream.listen((_) => _onFieldsStateChanged()).cancel,
    );
    addDisposable(
      onStatusChangedStream.listen((_) => _onFieldsStatusChanged()).cancel,
    );
    addDisposable(() => Future.wait(state.subforms.map((e) => e.dispose())));
  }

  /// A debug label for this form. Not significant to the form.
  final String debugName;

  /// When true, whenever any field changes, all other fields get
  /// their validator called if they have autovalidate enabled.
  final bool validateAll;

  List<dynamic> _initialFieldsState = <dynamic>[];

  StreamSubscription<dynamic>? _onFieldsChangeSubscription;
  final _fieldsController = StreamController<dynamic>.broadcast();

  /// Emits when any of the leaf fields have their value changed.
  Stream<void> get onValuesChangedStream => _fieldsController.stream;

  StreamSubscription<FieldStatus>? _onFieldsStatusChangeSubscription;
  final _fieldsStatusController = StreamController<FieldStatus>.broadcast();

  /// Emits when any of the leaf fields have their status changed.
  Stream<FieldStatus> get onStatusChangedStream =>
      _fieldsStatusController.stream;

  Future<void> _onFieldsChanged(
    ({
      List<FieldNotifier<dynamic, dynamic>> fields,
      Set<FormGroupNotifier> subforms,
    }) data,
  ) async {
    await _onFieldsChangeSubscription?.cancel();
    await _onFieldsStatusChangeSubscription?.cancel();
    final (:fields, :subforms) = data;

    _onFieldsChangeSubscription = Rx.merge<dynamic>(
      fields.map(
        (field) {
          return field.stream
              .map<dynamic>((state) => state.value)
              .distinctWithFirst(field.state.value);
        },
      ).followedBy(
        subforms.map((e) => e.onValuesChangedStream),
      ),
    ).listen(_fieldsController.add);

    _onFieldsStatusChangeSubscription = Rx.merge<FieldStatus>(
      fields.map(
        (field) {
          return field.stream
              .map<FieldStatus>((state) => state.status)
              .distinctWithFirst(field.state.status);
        },
      ).followedBy(
        subforms.map((e) => e.onStatusChangedStream),
      ),
    ).listen(_fieldsStatusController.add);
  }

  /// Takes ownership of registered fields. Will dispose all cubits.
  /// Fields are expected to be filled with initial states.
  void registerFields(List<FieldNotifier<dynamic, dynamic>> fields) {
    state = FormGroupState(
      wasModified: state.wasModified,
      fields: fields,
      subforms: state.subforms,
      validationEnabled: state.validationEnabled,
    );

    addDisposable(() => fields.map((e) => e.dispose()));

    _initialFieldsState = getFieldValues();
    // inform that the fields have changed
    _fieldsController.add(null);
  }

  /// Returns a list of all field values.
  @visibleForTesting
  List<dynamic> getFieldValues() {
    return state.fields.map<dynamic>((f) => f.state.value).toList();
  }

  /// Recursively calls validate on all subforms/fields if `state.validationEnabled` is true.
  /// [enableAutovalidate] can enable autovalidate on this form.
  ///
  /// Returns the result of validate calls, or always `true` if `state.validationEnabled` is false.
  bool validate({bool enableAutovalidate = true}) {
    if (enableAutovalidate) {
      setAutovalidate(true);
    }
    if (!state.validationEnabled) {
      return true;
    }

    // Eager list to prevent short circuits, all fields should be called with validate
    return [
      for (final field in state.fields) field.validate(),
      for (final subform in state.subforms)
        subform.validate(enableAutovalidate: enableAutovalidate),
    ].every((e) => e);
  }

  /// Marks all leaf fields as readonly.
  void markReadOnly() {
    for (final field in state.fields) {
      field.markReadOnly();
    }
    for (final subform in state.subforms) {
      subform.markReadOnly();
    }
  }

  /// Unmarks all leaf fields as readonly.
  void unmarkReadOnly() {
    for (final field in state.fields) {
      field.unmarkReadOnly();
    }
    for (final subform in state.subforms) {
      subform.unmarkReadOnly();
    }
  }

  /// Sets autovalidate on all leaf fields.
  // ignore: avoid_positional_boolean_parameters
  void setAutovalidate(bool autovalidate) {
    for (final field in state.fields) {
      field.setAutovalidate(autovalidate);
    }
    for (final subform in state.subforms) {
      subform.setAutovalidate(autovalidate);
    }
  }

  /// Resets all leaf fields to their initial states.
  void resetAll() {
    for (final field in state.fields) {
      field.reset();
    }
    for (final subform in state.subforms) {
      subform.resetAll();
    }
  }

  /// Clears all errors on all leaf fields.
  void clearErrors() {
    for (final field in state.fields) {
      field.clearErrors();
    }
    for (final subform in state.subforms) {
      subform.clearErrors();
    }
  }

  /// Adds a subform to the current form.
  /// If [form] was already added as a subform this is a noop.
  void addSubform(FormGroupNotifier form) {
    state = FormGroupState(
      wasModified: state.wasModified,
      fields: state.fields,
      subforms: {...state.subforms, form},
      validationEnabled: state.validationEnabled,
    );
  }

  /// Removes and disposes an owned subform.
  /// If [form] was not a subform this is a noop.
  Future<void> removeSubform(
    FormGroupNotifier form, {
    bool close = true,
  }) async {
    if (state.subforms.contains(form)) {
      state = FormGroupState(
        wasModified: state.wasModified,
        fields: state.fields,
        subforms: {...state.subforms}..remove(form),
        validationEnabled: state.validationEnabled,
      );
      if (close) {
        await form.dispose();
      }
    }
  }

  /// Calls validate on all fields with autovalidate on.
  void validateWithAutovalidate() {
    for (final field in state.fields) {
      if (field.state.autovalidate) {
        field.validate();
      }
    }
    for (final subform in state.subforms) {
      subform.validateWithAutovalidate();
    }
  }

  /// Changes optionality of this form. When `validationEnabled` is set to false,
  /// all errors are cleared.
  // ignore: avoid_positional_boolean_parameters
  void setValidationEnabled(bool validationEnabled) {
    if (validationEnabled == state.validationEnabled) {
      return;
    }
    state = FormGroupState(
      wasModified: state.wasModified,
      fields: state.fields,
      subforms: state.subforms,
      validationEnabled: validationEnabled,
    );
    if (validationEnabled) {
      validateWithAutovalidate();
    } else {
      clearErrors();
    }
  }

  void _onFieldsStateChanged() {
    final subformsWereModified = state.subforms.any(
      (subform) => subform.state.wasModified,
    );
    late final fieldsWereModified = !const DeepCollectionEquality()
        .equals(_initialFieldsState, getFieldValues());

    if (validateAll) {
      validateWithAutovalidate();
    }

    state = FormGroupState(
      wasModified: subformsWereModified || fieldsWereModified,
      fields: state.fields,
      subforms: state.subforms,
      validationEnabled: state.validationEnabled,
    );
  }

  void _onFieldsStatusChanged() {
    final subformsIsValidating = state.subforms.any(
      (subform) => subform.state.validating,
    );

    final fieldsAreValidating = state.fields.any(
      (field) => field.state.isInProgress,
    );

    state = FormGroupState(
      wasModified: state.wasModified,
      fields: state.fields,
      subforms: state.subforms,
      validationEnabled: state.validationEnabled,
      validating: fieldsAreValidating || subformsIsValidating,
    );
  }

  @override
  Future<void> dispose() async {
    await disposeDisposables();
    return super.dispose();
  }
}

/// The state of a [FormGroupNotifier].
class FormGroupState with EquatableMixin {
  /// Creates a new [FormGroupState].
  const FormGroupState({
    this.wasModified = false,
    this.fields = const [],
    this.subforms = const {},
    this.validationEnabled = true,
    this.validating = false,
  });

  /// wasModified is true when any of the field values differ since the
  /// last `registerFields` or when any of the subforms has wasModified=true.
  final bool wasModified;

  /// List of all registered fields by this form.
  final List<FieldNotifier<dynamic, dynamic>> fields;

  /// Set of registered subforms. Reference equality is assumed.
  final Set<FormGroupNotifier> subforms;

  /// If false, validators are not ran and `validate` always returns true.
  final bool validationEnabled;

  /// Returns true if fields are currently being validated.
  final bool validating;

  /// List of this form's fields including subforms' fields.
  Iterable<FieldNotifier<dynamic, dynamic>> get allFields =>
      fields.followedBy(subforms.expand((e) => e.state.allFields));

  /// Map of all validation errors (including subfroms') grouped by fields
  Map<FieldNotifier<dynamic, dynamic>, dynamic> get validationErrors => {
        for (final field in allFields)
          if (field.state.validationError case final error?) field: error,
      };

  @override
  List<Object?> get props => [
        wasModified,
        fields,
        subforms,
        validationEnabled,
        validating,
      ];
}
