import 'package:flutter_riverpod/flutter_riverpod.dart';

class SetsAndRepsEditorNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void setEditing(bool isEditing) {
    state = isEditing;
  }
}

final setsAndRepsEditorProvider =
    NotifierProvider<SetsAndRepsEditorNotifier, bool>(
        SetsAndRepsEditorNotifier.new);
