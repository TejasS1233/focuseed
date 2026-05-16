enum SoftFocusOutcome { stunted, reducedGrowth, fullGrowth }

class SessionService {
  int calculateGrowthStage(int durationSeconds, {String mode = 'soft'}) {
    final adjusted = mode == 'hard' ? (durationSeconds * 1.5).toInt() : durationSeconds;
    if (adjusted >= 14400) return 5;
    if (adjusted >= 7200) return 4;
    if (adjusted >= 3600) return 3;
    if (adjusted >= 1800) return 2;
    if (adjusted >= 900) return 1;
    return 0;
  }

  SoftFocusOutcome evaluateSoftFocusOutcome({
    required int setDuration,
    required int actualDuration,
  }) {
    final ratio = actualDuration / setDuration;
    if (ratio < 0.5) return SoftFocusOutcome.stunted;
    if (ratio < 1.0) return SoftFocusOutcome.reducedGrowth;
    return SoftFocusOutcome.fullGrowth;
  }

  String generateId() => DateTime.now().microsecondsSinceEpoch.toString();
}
