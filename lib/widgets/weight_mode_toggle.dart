import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/user_preferences.dart';
import 'package:frontend/providers/user_preferences_provider.dart';

class WeightModeToggle extends ConsumerWidget {
  const WeightModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPreferences = ref.watch(userPreferencesProvider);

    return userPreferences.when(data: ((data) {
      return ToggleButtons(
          onPressed: ((index) {
            WeightMode newWeightMode =
                index == 0 ? WeightMode.pounds : WeightMode.kilograms;
            ref
                .read(userPreferencesProvider.notifier)
                .setWeightMode(newWeightMode);
          }),
          isSelected: [
            data.weightMode == WeightMode.pounds,
            data.weightMode == WeightMode.kilograms
          ],
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ),
          fillColor: Theme.of(context).colorScheme.secondary,
          selectedColor: Theme.of(context).colorScheme.onSecondary,
          selectedBorderColor: Theme.of(context).colorScheme.secondary,
          constraints: const BoxConstraints(minHeight: 40, minWidth: 80),
          children: const [Text('Pounds'), Text('Kilograms')]);
    }), error: ((error, stackTrace) {
      return Center(child: Text(error.toString()));
    }), loading: (() {
      return ToggleButtons(
        isSelected: const [false, false],
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
        fillColor: Theme.of(context).colorScheme.secondary,
        selectedColor: Theme.of(context).colorScheme.onSecondary,
        selectedBorderColor: Theme.of(context).colorScheme.secondary,
        constraints: const BoxConstraints(minHeight: 40, minWidth: 80),
        children: const [Text('Pounds'), Text('Kilograms')],
      );
    }));
  }
}
