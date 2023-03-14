import 'dart:async';

class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({required this.duration});

  void run(void Function() action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(duration, action);
  }
}
