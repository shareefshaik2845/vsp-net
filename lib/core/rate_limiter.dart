class RateLimiter {
  final Duration _minInterval;
  DateTime _lastAttempt = DateTime(2000);
  int _consecutiveFailures = 0;

  RateLimiter({Duration? minInterval})
      : _minInterval = minInterval ?? const Duration(seconds: 2);

  bool get canAttempt {
    final elapsed = DateTime.now().difference(_lastAttempt);
    if (elapsed < _minInterval) return false;
    if (_consecutiveFailures >= 3) {
      final wait = Duration(seconds: 5 * (_consecutiveFailures - 2));
      if (elapsed < wait) return false;
    }
    return true;
  }

  void recordAttempt({bool success = false}) {
    _lastAttempt = DateTime.now();
    if (success) {
      _consecutiveFailures = 0;
    } else {
      _consecutiveFailures++;
    }
  }

  int get consecutiveFailures => _consecutiveFailures;

  Duration get retryAfter {
    if (_consecutiveFailures < 3) return _minInterval;
    final remaining = _minInterval * (_consecutiveFailures - 2);
    final elapsed = DateTime.now().difference(_lastAttempt);
    final wait = remaining - elapsed;
    return wait > Duration.zero ? wait : Duration.zero;
  }
}
