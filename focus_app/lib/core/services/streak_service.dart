import '../db/database.dart';
import '../db/daos/session_dao.dart';
import '../db/daos/achievement_dao.dart';

class StreakService {
  final SessionDao _sessionDao;
  final AchievementDao _achievementDao;

  StreakService(AppDatabase db)
      : _sessionDao = SessionDao(db),
        _achievementDao = AchievementDao(db);

  Future<int> calculateStreak(String userId) async {
    final sessions = await _sessionDao.getSessionsByUser(userId);
    if (sessions.isEmpty) return 0;

    final sorted = sessions
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    final uniqueDays = <DateTime>{};
    for (final s in sorted) {
      final day = DateTime(s.startTime.year, s.startTime.month, s.startTime.day);
      uniqueDays.add(day);
    }

    final sortedDays = uniqueDays.toList()..sort((a, b) => b.compareTo(a));
    return _consecutiveDays(sortedDays);
  }

  int _consecutiveDays(List<DateTime> sortedDays) {
    if (sortedDays.isEmpty) return 0;

    int streak = 1;
    for (int i = 0; i < sortedDays.length - 1; i++) {
      final diff = sortedDays[i].difference(sortedDays[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  Future<List<Achievement>> checkAndUnlock(String userId) async {
    final unlocked = <Achievement>[];
    final sessions = await _sessionDao.getSessionsByUser(userId);
    final totalSeconds = await _sessionDao.getTotalSecondsForUser(userId);
    final streak = await calculateStreak(userId);

    final candidates = [
      _Candidate('first_session', 'First Session', 'Complete your first focus session',
          sessions.length >= 1),
      _Candidate('five_sessions', 'Dedicated', 'Complete 5 focus sessions',
          sessions.length >= 5),
      _Candidate('ten_sessions', 'Focused Mind', 'Complete 10 focus sessions',
          sessions.length >= 10),
      _Candidate('hour_total', 'One Hour', 'Accumulate 1 hour of focus',
          totalSeconds >= 3600),
      _Candidate('five_hours', 'Deep Work', 'Accumulate 5 hours of focus',
          totalSeconds >= 18000),
      _Candidate('ten_hours', 'Unstoppable', 'Accumulate 10 hours of focus',
          totalSeconds >= 36000),
      _Candidate('streak_3', 'Consistent', 'Maintain a 3-day streak',
          streak >= 3),
      _Candidate('streak_7', 'Week Warrior', 'Maintain a 7-day streak',
          streak >= 7),
      _Candidate('streak_30', 'Monthly Master', 'Maintain a 30-day streak',
          streak >= 30),
    ];

    for (final c in candidates) {
      final already = await _achievementDao.isUnlocked(userId, c.key);
      if (already || !c.shouldUnlock) continue;

      final ach = Achievement(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        userId: userId,
        key: c.key,
        title: c.title,
        description: c.description,
        unlockedAt: DateTime.now(),
      );
      await _achievementDao.insertAchievement(ach);
      unlocked.add(ach);
    }

    return unlocked;
  }
}

class _Candidate {
  final String key, title, description;
  final bool shouldUnlock;
  _Candidate(this.key, this.title, this.description, this.shouldUnlock);
}
