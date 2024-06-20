import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leancode_forms/src/field/cubit/field_notifier.dart';
/*
/// Listens to the given [field] and rerenders the child using [builder].
class FieldBuilder<T, E extends Object> extends ConsumerWidget {
  /// Creates a new [FieldBuilder].
  const FieldBuilder({
    super.key,
    required this.field,
    required this.child,
  });

  /// The [FieldNotifier] to listen to.
  final FieldNotifier<T, E> field;

  /// The builder to use to build the child.
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(field)
    return BlocBuilder<FieldNotifier<T, E>, FieldState<T, E>>(
      bloc: field,
      builder: builder,
    );
  }
}
*/

/// Translates an error to a string.
typedef ErrorTranslator<E extends Object> = String Function(E);
