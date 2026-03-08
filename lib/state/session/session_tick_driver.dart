import 'dart:async';

abstract class SessionTickDriver {
  void start({required Duration interval, required void Function() onTick});
  void stop();
  void dispose();
}

class TimerSessionTickDriver implements SessionTickDriver {
  Timer? _timer;

  @override
  void start({required Duration interval, required void Function() onTick}) {
    stop();
    _timer = Timer.periodic(interval, (_) => onTick());
  }

  @override
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    stop();
  }
}
