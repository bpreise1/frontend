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
          selectedBorderColor: Colors.red,
          children: const [Text('Pounds'), Text('Kilograms')]);
    }), error: ((error, stackTrace) {
      return const SizedBox.shrink();
    }), loading: (() {
      return ToggleButtons(
        isSelected: const [false, false],
        children: const [Text('Pounds'), Text('Kilograms')],
      );
    }));
  }
}
