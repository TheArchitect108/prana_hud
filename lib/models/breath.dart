import 'dart:async';

enum BreathStatus { initial, inhaling, exhaling, stopped }

class Breath {
  int length;

  int ratio;

  Breath({this.length, this.ratio});

  // When we started breathing.
  DateTime begin;

  // When the last inhale started.
  DateTime _lastInhale;

  // When the last exhale started.
  DateTime _lastExhale;

  // Inhale Length

  int _inhaleLength;

  // Exhale Length

  int _exhaleLength;

  BreathStatus _status = BreathStatus.initial;

  Timer _inhaleDelay;
  Timer _exhaleDelay;

  int totalCycles = 0;

  void startBreath() async {
    //
    _inhaleLength = (length * (1 / (ratio + 1))).ceil();
    _exhaleLength = (length * (ratio / (ratio + 1))).floor();

    // Conditionally start inhale or exhale based
    // on synchronized time.
    begin = DateTime.now().toUtc();

    await Future.delayed(Duration(milliseconds: (1000 - begin.millisecond)));
    var secondsSince =
        (begin.hour * 60 * 60) + (begin.minute * 60) + (begin.second);
    if (secondsSince % length == 0) {
      _inhale();
    } else if (secondsSince % length < _inhaleLength) {
      var len = _inhaleLength - (secondsSince % length);
      _inhale(partialBreath: len);
    } else if (secondsSince % length >= _inhaleLength) {
      var len = length - (secondsSince % length);
      _exhale(partialBreath: len);
    }
  }

  void stopBreath() {
    _status = BreathStatus.stopped;
  }

  void setBreath({int newLength, int newRatio}) {
    stopBreath();
    if (newLength == null || newLength == 0) {
    } else {
      length = newLength;
    }

    if (newRatio == null || newRatio == 0) {
    } else {
      ratio = newRatio;
    }
    startBreath();
  }

  void _inhale({int partialBreath = 0}) async {
    _status = BreathStatus.inhaling;
    if (partialBreath != 0) {
      _lastInhale = DateTime.now()
          .subtract(Duration(seconds: _inhaleLength - partialBreath));
      if (_inhaleDelay != null && _inhaleDelay.isActive) _inhaleDelay.cancel();
      _inhaleDelay = new Timer(Duration(seconds: partialBreath), () {
        if (_status != BreathStatus.stopped) _exhale();
      });
    } else {
      _lastInhale = DateTime.now();
      if (_inhaleDelay != null && _inhaleDelay.isActive) _inhaleDelay.cancel();
      _inhaleDelay = new Timer(Duration(seconds: _inhaleLength), () {
        if (_status != BreathStatus.stopped) _exhale();
      });
    }
  }

  void _exhale({int partialBreath = 0}) async {
    _status = BreathStatus.exhaling;
    if (partialBreath != 0) {
      _lastExhale = DateTime.now()
          .subtract(Duration(seconds: _exhaleLength - partialBreath));
      if (_exhaleDelay != null && _exhaleDelay.isActive) _exhaleDelay.cancel();
      _exhaleDelay = new Timer(Duration(seconds: partialBreath), () {
        if (_status != BreathStatus.stopped) _inhale();
      });
    } else {
      _lastExhale = DateTime.now();
      if (_exhaleDelay != null && _exhaleDelay.isActive) _exhaleDelay.cancel();
      _exhaleDelay = new Timer(Duration(seconds: _exhaleLength), () {
        if (_status != BreathStatus.stopped) _inhale();
      });
    }
    totalCycles++;
  }

  // Allows asynchronous status updates
  BreathUpdate statusUpdate() {
    switch (_status) {
      case BreathStatus.inhaling:
        Duration diff = DateTime.now().difference(_lastInhale);
        // percentage of breath complete = progress for return
        return BreathUpdate(
            progress: diff.inMilliseconds / (_inhaleLength * 1000),
            status: _status);
        break;
      case BreathStatus.exhaling:
        Duration diff = DateTime.now().difference(_lastExhale);
        // percentage of breath complete = progress for return
        return BreathUpdate(
            progress: 1 - diff.inMilliseconds / (_exhaleLength * 1000),
            status: _status);
        break;
      case BreathStatus.initial:
        return BreathUpdate(progress: 1, status: _status);
        break;
      case BreathStatus.stopped:
        return BreathUpdate(progress: 1, status: _status);
        break;
    }
  }
}

// Simple data structure for status and progress
class BreathUpdate {
  BreathStatus status;
  double progress;
  BreathUpdate({this.status, this.progress});
}
