import '../database.dart';
import 'session_dao.dart';

const _achievementDefs = [
  ('first_session', 'First Seed', 'Complete your first session', 1, 'session'),
  ('ten_sessions', 'Sprout', 'Complete 10 sessions', 10, 'session'),
  ('fifty_sessions', 'Grove', 'Complete 50 sessions', 50, 'session'),
  ('hundred_sessions', 'Forest', 'Complete 100 sessions', 100, 'session'),
  ('streak_3', 'Sapling', 'Maintain a 3-day streak', 3, 'streak'),
  ('streak_7', 'Oak', 'Maintain a 7-day streak', 7, 'streak'),
  ('streak_30', 'Ancient Tree', 'Maintain a 30-day streak', 30, 'streak'),
  ('focus_1h', 'Budding', 'Focus for 1 total hour', 3600, 'focus'),
  ('focus_10h', 'Gardener', 'Focus for 10 total hours', 36000, 'focus'),
];

class AchievementDao {
  final AppDatabase _db;
  AchievementDao(this._db);

  Future<void> insertAchievement(Achievement a) =>
      _db.into(_db.achievements).insert(a);

  Future<List<Achievement>> getAchievementsByUser(String userId) =>
      (_db.select(_db.achievements)..where((a) => a.userId.equals(userId))).get();

  Future<bool> isUnlocked(String userId, String key) async {
    final all = await getAchievementsByUser(userId);
    return all.any((a) => a.key == key);
  }

  Future<int> checkAndUnlock(String userId) async {
    final sessionDao = SessionDao(_db);
    final sessions = await sessionDao.getSessionsByUser(userId);
    final completed = sessions.where((s) => s.outcome == 'completed').length;
    final totalSeconds = sessions.fold<int>(0, (s, e) => s + e.durationSeconds);
    final streak = await sessionDao.getCurrentStreak(userId);

    final existing = await getAchievementsByUser(userId);
    final existingKeys = existing.map((a) => a.key).toSet();

    int unlocked = 0;
    for (final (key, title, desc, threshold, type) in _achievementDefs) {
      if (existingKeys.contains(key)) continue;
      final actual = switch (type) {
        'session' => completed,
        'streak' => streak,
        'focus' => totalSeconds,
        _ => 0,
      };
      if (actual >= threshold) {
        await _db.into(_db.achievements).insert(Achievement(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          userId: userId,
          key: key,
          title: title,
          description: desc,
          unlockedAt: DateTime.now(),
        ));
        unlocked++;
      }
    }
    return unlocked;
  }
}
