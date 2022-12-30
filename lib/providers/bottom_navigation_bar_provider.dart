import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomNavigationBarNotifier extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void setNavigationBarIndex(int index) {
    state = index;
  }
}

final bottomNavigationBarProvider =
    NotifierProvider<BottomNavigationBarNotifier, int>(
        BottomNavigationBarNotifier.new);
