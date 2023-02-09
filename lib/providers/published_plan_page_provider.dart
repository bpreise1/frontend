import 'package:flutter_riverpod/flutter_riverpod.dart';

class PublishedPlanPageNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void update() {
    state = !state;
  }
}

final publishedPlanPageProvider =
    NotifierProvider<PublishedPlanPageNotifier, bool>(
        PublishedPlanPageNotifier.new);
