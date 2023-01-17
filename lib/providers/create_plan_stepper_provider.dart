import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreatePlanStepperNotifier extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void setCreatePlanStepperIndex(int index) {
    state = index;
  }
}

final createPlanStepperProvider =
    NotifierProvider<CreatePlanStepperNotifier, int>(
        CreatePlanStepperNotifier.new);
